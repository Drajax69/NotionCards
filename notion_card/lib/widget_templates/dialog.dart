import 'package:flutter/material.dart';

class DialogManager {
  static void show(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF755DC1),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF393939),
                fontSize: 16,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Color(0xFF755DC1),
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static Future<bool?> showConfirmDialog(
      BuildContext context, String title, String message) {
    return showDialog<bool?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF755DC1),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF393939),
                fontSize: 16,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text(
                'Yes',
                style: TextStyle(
                  color: Color(0xFF755DC1),
                  fontSize: 16,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                'No',
                style: TextStyle(
                  color: Color(0xFF755DC1),
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
