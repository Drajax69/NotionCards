import 'dart:developer';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notion_card/utils/constant.dart';

class Card {
  final String cid; // Card ID
  String question;
  String answer;
  int repetitionNumber;
  double easinessFactor;
  Timestamp nextReview;

  Card({
    required this.cid,
    required this.question,
    required this.answer,
    required this.easinessFactor,
    required this.nextReview,
    required this.repetitionNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'cid': cid,
      'question': question,
      'answer': answer,
      'repetitionNumber': repetitionNumber,
      'easinessFactor': easinessFactor,
      'nextReview': nextReview,
    };
  }

  static Card fromMap(Map<String, dynamic> map) {
    return Card(
      cid: map['cid'] ?? '',
      question: map['question'] ?? '',
      answer: map['answer'] ?? '',
      repetitionNumber: map['repetitionNumber'] ?? Constants.defaultRepetitionNumber,
      easinessFactor: map['easinessFactor'] ?? Constants.defaultEasinessFactor,
      nextReview: map['nextReview'] ?? Constants.defaultNextReview,
    );
  }

  static Card fromDocumentSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Card(
      cid: data['cid'] ?? '',
      question: data['question'] ?? '',
      answer: data['answer'] ?? '',
      easinessFactor: data['easinessFactor'] ?? Constants.defaultEasinessFactor,
      nextReview: data['nextReview'] ?? Constants.defaultNextReview,
      repetitionNumber: data['repetitionNumber'] ?? Constants.defaultRepetitionNumber,
    );
  }

  void applySRAlgirthm(String uid, String did, int confidenceLevel) async {
    const int correctThreshold = 3;
    const Duration initialInterval = Duration(days: 1);
    const Duration correctIntervalMultiplier = Duration(days: 6);
    const int maxIntervalFromReview = 20;
    if (confidenceLevel >= correctThreshold) {
      if (repetitionNumber == 0) {
        nextReview = Timestamp.fromDate(DateTime.now().add(initialInterval));
      } else if (repetitionNumber == 1) {
        nextReview =
            Timestamp.fromDate(DateTime.now().add(correctIntervalMultiplier));
      } else {
        nextReview = Timestamp.fromDate(DateTime.now().add(Duration(
            days: math.min(
                maxIntervalFromReview,
                ((nextReview.toDate().difference(DateTime.now()).inDays *
                        easinessFactor)
                    .toInt())))));
      }
      repetitionNumber++;
      if(repetitionNumber>Constants.maxRepetitionNumber){
        repetitionNumber = Constants.maxRepetitionNumber;
      }
    } else {
      repetitionNumber = 0;
      nextReview = Timestamp.fromDate(
          DateTime.now().add(initialInterval)); // Reset interval
    }
    // Should be old easiness factor + new user grade
    easinessFactor = 
        easinessFactor +
            (0.1 - (5 - confidenceLevel) * (0.08 + (5 - confidenceLevel) * 0.02));
    easinessFactor = easinessFactor < 1.3 ? 1.3 : easinessFactor;
    easinessFactor = easinessFactor > Constants.maxEasinessFactor
        ? Constants.maxEasinessFactor
        : easinessFactor;

    // Update the card in the database
    await update(uid, did);
  }

  Future<void> update(String uid, String did) async {
    try {
      log("[updating-card] $question");
      await FirebaseFirestore.instance
          .collection('decks')
          .doc(did)
          .collection('cards')
          .doc(cid)
          .update(toMap());
    } catch (e) {
      throw Exception('[ERR! card-update]: $e');
    }
  }
  flipQuestionAnswer() {
    String temp = question;
    question = answer;
    answer = temp;
  }

  @override
  String toString() {
    // return 'Card{cid: $cid, question: $question, answer: $answer, repetitionNumber: $repetitionNumber, easinessFactor: $easinessFactor, nextReview: ${nextReview.toDate()}\n';
    return question;
  }

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Card && other.cid == cid;
  }
}
