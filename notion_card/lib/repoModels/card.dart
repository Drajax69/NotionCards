import 'package:cloud_firestore/cloud_firestore.dart';

class Card {
  final String cid; // Card ID
  final String question;
  final String answer;

  Card({
    required this.cid,
    required this.question,
    required this.answer,
  });

  Map<String, dynamic> toMap() {
    return {
      'cid': cid,
      'question': question,
      'answer': answer,
    };
  }

  static Card fromMap(Map<String, dynamic> map) {
    return Card(
      cid: map['cid'] ?? '',
      question: map['question'] ?? '',
      answer: map['answer'] ?? '',
    );
  }

  static Card fromDocumentSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Card(
      cid: data['cid'] ?? '',
      question: data['question'] ?? '',
      answer: data['answer'] ?? '',
    );
  }
}
