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
    required String keyHeader,
    required String valueHeader,
    required bool isDbTitle,
    bool isReversed = false,
  }) async {
    try {
      log("[deck-controller] Creating deck with name: $name");
      final Map<String, String> headers = {
        'Authorization': 'Bearer $secretToken',
        'Notion-Version': defaultVersion,
        'Content-Type': 'application/json',
        'X-REQUESTED-WITH': '*'
      };
      final Map<String, String> params = {};
      int pageCounter = 0;
      bool hasMore = true;
      CorsProxyService corsProxyService =
          CorsProxyService(baseUrl: 'https://api.notion.com/v1/databases/');
      List<repo.Card>? cards = [];

      while (hasMore) {
        final response =
            await corsProxyService.post('$dbId/query', headers, params);
        if (response.statusCode == 200) {
          var data = json.decode(response.body);
          List<repo.Card>? cardPage =
              NotionService.convertResponseBodyToDeckModel(
                  data, name, keyHeader, valueHeader, isDbTitle, isReversed);
          if (cardPage == null) {
            return null;
          }
          cards.addAll(cardPage);
          hasMore = data['has_more'];
          if (hasMore) {
            params['start_cursor'] = data['next_cursor'];
          }
          pageCounter++;
          log("[deck-controller] Retrieved page $pageCounter");
        } else {
          log('Failed to create deck: ${response.statusCode} for page $pageCounter');
          return null;
        }
      }

      Deck deck = Deck(
        name: name,
        did: IdGenerator.getRandomString(10),
        dbId: dbId,
        secretToken: secretToken,
        isDbTitle: isDbTitle,
        keyHeader: keyHeader,
        valueHeader: valueHeader,
        length: cards.length,
        isReversed: isReversed,
      );
      deck.createCards(cards);
      user.createDeckRepo(deck);
      return deck;
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
        isDbTitle: deck.isDbTitle,
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

  Future<Deck?> generateReversed(Deck deck) async {
    Deck? reversedDeck = await createDeck(
        name: "${deck.name} (reversed)",
        dbId: deck.dbId,
        secretToken: deck.secretToken,
        keyHeader: deck.valueHeader,
        valueHeader: deck.keyHeader,
        isDbTitle: deck.isDbTitle,
        isReversed: true);
    return reversedDeck;
  }
}
