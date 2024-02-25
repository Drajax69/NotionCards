import 'dart:convert';
import 'dart:developer';

import 'package:notion_card/httpService/cors_proxy_service.dart';
import 'package:notion_card/httpService/notion_service.dart';
import 'package:notion_card/repoModels/card.dart' as repo;
import 'package:notion_card/repoModels/deck.dart';
import 'package:notion_card/repoModels/user.dart';

import '../utils/id_generator.dart';

class DeckController {
  final User user;
  static const String defaultVersion = "2022-06-28";

  DeckController({required this.user});

  Future<Deck?> createDeck({
    required String name,
    required String dbId,
    required String secretToken,
    required bool reversible,
    required String keyHeader,
    required String valueHeader,
  }) async {
    try {
      log("[deck-controller] Creating deck with name: $name");
      final Map<String, String> headers = {
        'Authorization': 'Bearer $secretToken',
        'Notion-Version': defaultVersion,
        'Content-Type': 'application/json',
        'X-REQUESTED-WITH': '*'
      };

      CorsProxyService corsProxyService =
          CorsProxyService(baseUrl: 'https://api.notion.com/v1/databases/');

      final response = await corsProxyService.post('$dbId/query', headers);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        List<repo.Card>? cards = NotionService.convertResponseBodyToDeckModel(
            data, name, keyHeader, valueHeader);
        print(cards?.length);
        if (cards == null) {
          return null;
        }
        Deck deck = Deck(
          name: name,
          did: IdGenerator.getRandomString(10),
          dbId: dbId,
          secretToken: secretToken,
          reversible: reversible,
          keyHeader: keyHeader,
          valueHeader: valueHeader,
          length: cards.length,
        );
        deck.createCards(cards);
        user.createDeckRepo(deck);
        return deck;
      } else {
        log('Failed to create deck: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('Error creating deck: $e');
      return null;
    }
  }

  Future<Deck?> updateDeck(Deck deck) async {
    try {
      user.deleteDeckRepo(deck);
      Deck? updatedDeck = await createDeck(
        name: deck.name,
        dbId: deck.dbId,
        secretToken: deck.secretToken,
        reversible: deck.reversible,
        keyHeader: deck.keyHeader,
        valueHeader: deck.valueHeader,
      );

      return updatedDeck;
    } catch (e) {
      log('Error updating deck: $e');
      return null;
    }
  }

  void deleteDeck(Deck deck) {
    user.deleteDeckRepo(deck);
  }

  // Future<bool> _fetchNotionData(String name, String secret, String version,
  //     String dbID, String keyHeader, String valueHeader) async {
  //   try {
  //     final Map<String, String> headers = {
  //       'Authorization': 'Bearer $secret',
  //       'Notion-Version': version,
  //       'Content-Type': 'application/json',
  //       'X-REQUESTED-WITH': '*'
  //     };

  //     CorsProxyService corsGateway =
  //         CorsProxyService(baseUrl: 'https://api.notion.com/v1/databases/');

  //     final response = await corsGateway.post('$dbID/query', headers);

  //     if (response.statusCode == 200) {
  //       var data = json.decode(response.body);
  //       log('Fetched data: $data');
  //       _createDeck(data, name, dbID, secret, false, keyHeader,
  //           valueHeader); // Reversibility logic
  //       return true;
  //     } else {
  //       log('Failed to fetch decks: ${response.statusCode}');
  //       _showDialogError();
  //     }
  //   } catch (e) {
  //     log('Error fetching data: $e');
  //     _showDialogError();
  //   }
  //   return false;
  // }
}
