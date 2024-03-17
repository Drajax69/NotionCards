import 'dart:developer';
import 'package:notion_card/httpService/notion_service.dart';
import 'package:notion_card/repoModels/card.dart' as repo;
import 'package:notion_card/repoModels/deck.dart';
import 'package:notion_card/repoModels/user.dart';
import '../utils/id_generator.dart';

class DeckController {
  final User user;

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
    List<repo.Card>? cards = await NotionService.getNotionCards(
        name: name,
        dbId: dbId,
        secretToken: secretToken,
        keyHeader: keyHeader,
        valueHeader: valueHeader,
        isDbTitle: isDbTitle);
    if (cards == null) {
      return null;
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
    await deck.createCards(cards);
    await user.createDeckRepo(deck);
    return deck;
  }

  Future<Deck?> updateDeck(Deck deck) async {
    try {
      log("[update-deck] Started update...");

      List<repo.Card> originalCards = await deck.getCards();
      List<repo.Card>? newCards = await NotionService.getNotionCards(
          name: deck.name,
          dbId: deck.dbId,
          secretToken: deck.secretToken,
          keyHeader: deck.keyHeader,
          valueHeader: deck.valueHeader,
          isDbTitle: deck.isDbTitle);
      log("[update-deck] Created updatedDeck");

      if (newCards == null) {
        return null;
      }

      log("[update-deck] Started update algorithm");

      Map<String, repo.Card> updatedCardsMap = {};
      for (int j = 0; j < newCards.length; j++) {
        updatedCardsMap[newCards[j].question] = newCards[j];
      }
      List<int> removeOGIndexes = [];
      for (int i = 0; i < originalCards.length; i++) {
        String question = originalCards[i].question;
        if (updatedCardsMap.containsKey(question)) {
          if (originalCards[i].answer != updatedCardsMap[question]!.answer) {
            originalCards[i].answer = updatedCardsMap[question]!.answer;
          }
          // Remove card if it's already updated
          updatedCardsMap.remove(question);
        } else {
          // Remove if card does not exist in updated deck
          removeOGIndexes.add(i);
        }
      }
      originalCards.removeWhere((element) =>
          removeOGIndexes.contains(originalCards.indexOf(element)));
      log("[update-deck] Finished update algorithm");

      // Add all remaining cards as they did not exist in original deck
      originalCards.addAll(updatedCardsMap.values);
      deck.length = originalCards.length;
      await deck.deleteAllCards();
      log("[update-deck] Recreating original cards");

      await deck.createCards(originalCards);
      await deck.updateLength(user.uid);
      log("[update-deck] Finished update");

      // print(await originalDeck.getCards());

      return deck;
    } catch (e) {
      log('[ERR! update-deck]: $e');
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
