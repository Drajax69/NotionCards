import 'dart:convert';
import 'dart:developer';
import 'package:collection/collection.dart';
import 'package:notion_card/httpService/cors_proxy_service.dart';
import 'package:notion_card/repoModels/card.dart';
import 'package:notion_card/utils/constant.dart';
import 'package:notion_card/utils/id_generator.dart';

class NotionService {
  static const String defaultVersion = "2022-06-28";

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
                  answer: answer,
                  easinessFactor: 2.5,
                  nextReview: Constants.defaultNextReview,
                  repetitionNumber: 1);
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

  static Future<List<Card>?> getNotionCards({
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
      List<Card>? cards = [];

      while (hasMore) {
        final response =
            await corsProxyService.post('$dbId/query', headers, params);
        if (response.statusCode == 200) {
          var data = json.decode(response.body);
          List<Card>? cardPage = NotionService.convertResponseBodyToDeckModel(
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
          log('[ERR! deck-controller]:\n status: ${response.statusCode}\n body: ${response.body}\n page: $pageCounter');
          return null;
        }
      }
      return cards;
    } catch (e) {
      log('Error creating deck: $e');
      return null;
    }
  }
}
