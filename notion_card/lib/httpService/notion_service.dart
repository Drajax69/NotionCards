import 'dart:developer';
import 'package:collection/collection.dart';
import 'package:notion_card/repoModels/card.dart';
import 'package:notion_card/utils/id_generator.dart';

class NotionService {
  static List<Card>? convertResponseBodyToDeckModel(
      Map<String, dynamic> responseBody,
      String name,
      String key,
      String value,
      bool isDbTitle,
      bool isReversed) {
    try {
      final List<dynamic> results = responseBody['results'];
      final List<Card> cards = results
          .map((result) {
            try {
              final properties = result['properties'];
              final String question = (isDbTitle && !isReversed)
                  ? properties[key]['title'][0]['plain_text']
                  : properties[key]['rich_text'][0]['plain_text'];
              final String answer = (isReversed && isDbTitle)
                  ? properties[value]['title'][0]['plain_text']
                  : properties[value]['rich_text'][0]['plain_text'];
              return Card(
                  cid: IdGenerator.getRandomString(10),
                  question: question,
                  answer: answer);
            } catch (e) {
              log('[ERR! notion-service]: $e');
            }
          })
          .whereNotNull()
          .toList();
      return cards;
    } catch (e) {
      log('[ERR! notion-service]: $e');
      return null;
    }
  }
}
