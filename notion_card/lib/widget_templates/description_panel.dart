import 'package:flutter/material.dart';
import 'package:notion_card/utils/text_styles.dart';

class DescriptionPanel extends StatelessWidget {
  final Image image;
  const DescriptionPanel({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF755DC1),
          image: DecorationImage(
            image: image.image, // Change this
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 120),
            Text(
              'Notion Cards',
              style: TextStyles.headerWhite,
            ),
            SizedBox(height: 5),
            Text(
              'Create flashcards from your notion database',
              style: TextStyles.subheaderItalic,
            ),
          ],
        ),
      ),
    );
  }
}
