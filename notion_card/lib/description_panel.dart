import 'package:flutter/material.dart';
import 'package:notion_card/utils/text_styles.dart';

class DescriptionPanel extends StatelessWidget {
  const DescriptionPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF755DC1),
          image: DecorationImage(
            image: AssetImage('loginbg.png'), // Change this
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(height: 120),
            const Text(
              'NotionCards   ',
              style: TextStyles.headerWhite,
            ),
            const SizedBox(height: 160),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBulletPoint('Connect your Notion database with ease'),
                _buildBulletPoint('Streamline the flashcard creation process'),
                _buildBulletPoint('Create decks from multiple databases'),
                _buildBulletPoint('Embed link directly into Notion'),
                _buildBulletPoint(
                    'Effortlessly manage and organize your flashcards'),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '\u2022',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ],
    );
  }
}
