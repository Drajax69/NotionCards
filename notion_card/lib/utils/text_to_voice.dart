import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeech {
  static final TextToSpeech _instance = TextToSpeech._internal();

  factory TextToSpeech() => _instance;

  TextToSpeech._internal();

  final FlutterTts _flutterTts = FlutterTts();

  Future<void> speak(String text) async {
    String languageCode = _getLanguageCode(text);
    await _flutterTts.setLanguage(languageCode);
    await _flutterTts.setPitch(1);
    await _flutterTts.setSpeechRate(0.8);
    await _flutterTts.speak(text);
  }

  String _getLanguageCode(String text) {
    {
      String languageCodes = 'ja-JP';

      final RegExp english = RegExp(r'^[a-zA-Z]+');
      final RegExp japanese = RegExp(r'^[\u3040-\u30FF]+');
      final RegExp korean = RegExp(r'^[\uAC00-\uD7AF]+');
      final RegExp french = RegExp(r'^[\u00C0-\u017F]+');
      final RegExp spanish = RegExp(
          r'[\u00C0-\u024F\u1E00-\u1EFF\u2C60-\u2C7F\uA720-\uA7FF\u1D00-\u1D7F]+');

      if (japanese.hasMatch(text)) languageCodes = 'ja-JP';
      if (english.hasMatch(text)) languageCodes = 'en-US';
      if (korean.hasMatch(text)) languageCodes = 'ko-KR';
      if (french.hasMatch(text)) languageCodes = 'fr-FR';
      if (spanish.hasMatch(text)) languageCodes = 'es-ES';

      return languageCodes;
    }
  }
}
