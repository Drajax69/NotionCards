import 'package:flutter/material.dart';

class TextStyles {
  static const TextStyle headerPurple = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Color.fromARGB(255, 188, 106, 202),
    fontFamily: 'Poppins',
    letterSpacing: 1.2,
  );

  static const TextStyle headerBlack = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
    fontFamily: 'Poppins',
    letterSpacing: 1.2,
  );

  static const TextStyle cardHeaderBlack = TextStyle(
    fontSize: 35,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
    fontFamily: 'Poppins',
    letterSpacing: 1.2,
  );

  static const TextStyle cardTextFont = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w400,
    color: Colors.black87,
    fontFamily: 'Poppins',
    letterSpacing: 1.2,
  );

    static const TextStyle cardIndexingFont = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Colors.black87,
    fontFamily: 'Poppins',
    letterSpacing: 1.2,
  );

  static const TextStyle headerWhite = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontFamily: 'Poppins',
  );

  static const TextStyle headerWhiteWithBorder = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontFamily: 'Poppins',
    shadows: [
      Shadow(
        offset: Offset(-1, -1),
        color: Colors.grey,
      ),
      Shadow(
        offset: Offset(1, -1),
        color: Colors.grey,
      ),
      Shadow(
        offset: Offset(1, 1),
        color: Colors.grey,
      ),
      Shadow(
        offset: Offset(-1, 1),
        color: Colors.grey,
      ),
    ],
  );

  static const TextStyle loginWhite = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontFamily: 'Poppins',
  );

  static const TextStyle subHeader = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
    fontFamily: 'Roboto',
  );

  static const TextStyle bodyRegular = TextStyle(
    fontSize: 16,
    color: Colors.black87,
    fontFamily: 'Roboto',
  );

  static const TextStyle subheaderItalic = TextStyle(
    fontSize: 20,
    fontStyle: FontStyle.italic,
    color: Colors.white,
    fontFamily: 'Poppins',
  );

  static const TextStyle bodyBold = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontFamily: 'Roboto',
  );

  static const TextStyle iconText = TextStyle(
    fontSize: 16,
    color: Color.fromARGB(255, 85, 85, 85),
    fontFamily: 'Roboto',
  );

  static const TextStyle link = TextStyle(
    fontSize: 16,
    color: Colors.blue,
    decoration: TextDecoration.underline,
    fontFamily: 'Roboto',
  );
}
