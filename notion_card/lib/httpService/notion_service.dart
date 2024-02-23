import 'dart:developer';

import 'package:notion_card/repoModels/card.dart';
import 'package:notion_card/utils/id_generator.dart';

class NotionService {
  static List<Card>? convertResponseBodyToDeckModel(
      Map<String, dynamic> responseBody,
      String name,
      String key,
      String value) {
    log("[convert-to-deck] Using $name, $key, $value");
    try {
      final List<dynamic> results = responseBody['results'];
      final List<Card> cards = results.map((result) {
        final properties = result['properties'];
        final String question = properties[key]['title'][0]['plain_text'];
        final String answer = properties[value]['rich_text'][0]['plain_text'];
        return Card(
            cid: IdGenerator.getRandomString(10),
            question: question,
            answer: answer);
      }).toList();

      return cards;
    } catch (e) {
      log('Error converting response body to Deck model: $e');
      return null;
    }
  }
}
