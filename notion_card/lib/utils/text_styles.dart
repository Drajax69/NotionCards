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

  static const TextStyle headerWhite = TextStyle(
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

  static const TextStyle bodyItalic = TextStyle(
    fontSize: 16,
    fontStyle: FontStyle.italic,
    color: Colors.black87,
    fontFamily: 'Roboto',
  );

  static const TextStyle bodyBold = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
    fontFamily: 'Roboto',
  );

  static const TextStyle link = TextStyle(
    fontSize: 16,
    color: Colors.blue,
    decoration: TextDecoration.underline,
    fontFamily: 'Roboto',
  );
}
