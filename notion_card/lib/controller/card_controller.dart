import 'dart:developer';

import 'package:notion_card/repoModels/card.dart';
import 'package:notion_card/utils/constant.dart';

class CardController {
  String? japaneseToRomaji(String name) {
    List<String> characters = name.split('');

    List<String?> romajiList = characters.map((char) {
      return Constants.hiraganaDictionary[char] ??
          Constants.katakanaDictionary[char] ??
          char;
    }).toList();

    return romajiList.join();
  }

  List<Card> sortByReviewedDate(
      List<Card> cards, String uid, String did) {
    log(cards.length.toString());
    for (var card in cards) {
      int repetitions = ((card.easinessFactor) * 0.8).ceil();
      log(repetitions.toString());
      for (int i = 0; i < repetitions; i++) {
        cards.add(card); // Add a duplicate of the card
      }
    }

    cards.shuffle();

    return cards;
  }
}
