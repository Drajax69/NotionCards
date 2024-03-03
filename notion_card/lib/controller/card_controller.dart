import 'package:notion_card/utils/constant.dart';

class CardController {
  CardController();

  String? japaneseToRomaji(String name) {
    List<String> characters = name.split('');

    List<String?> romajiList = characters.map((char) {
      return Constants.hiraganaDictionary[char] ?? Constants.katakanaDictionary[char] ?? char;
    }).toList();

    return romajiList.join();
  }
}
