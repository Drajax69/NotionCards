import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notion_card/utils/constant.dart';
import 'card.dart'; // Import your Card class

class Deck {
  final String name;
  final String did; // Deck ID
  final String dbId; // Database ID
  int length;
  final String secretToken;
  final bool isDbTitle;
  final bool isReversed;
  final String keyHeader;
  final String valueHeader;

  Deck({
    required this.length,
    required this.name,
    required this.isReversed,
    required this.did,
    required this.dbId,
    required this.secretToken,
    required this.isDbTitle,
    required this.keyHeader,
    required this.valueHeader,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'did': did,
      'dbId': dbId,
      'secretToken': secretToken,
      'isDbTitle': isDbTitle,
      'keyHeader': keyHeader,
      'valueHeader': valueHeader,
      'length': length,
      'isReversed': isReversed,
    };
  }

  static Deck fromDocumentSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Deck(
      length: data['length'] ?? 0,
      name: data['name'] ?? '',
      did: data['did'] ?? '',
      dbId: data['dbId'] ?? '',
      secretToken: data['secretToken'] ?? '',
      isDbTitle: data['isDbTitle'] ?? false,
      keyHeader: data['keyHeader'] ?? '',
      valueHeader: data['valueHeader'] ?? '',
      isReversed: data['isReversed'] ?? true,
    );
  }

  static Deck fromMap(Map<String, dynamic> map) {
    return Deck(
      name: map['name'] ?? '',
      did: map['did'] ?? '',
      dbId: map['dbId'] ?? '',
      secretToken: map['secretToken'] ?? '',
      isDbTitle: map['isDbTitle'] ?? false,
      keyHeader: map['keyHeader'] ?? '',
      valueHeader: map['valueHeader'] ?? '',
      length: map['length'] ?? 0,
      isReversed: map['isReversed'] ?? true,
    );
  }

  Deck copyWith({
    String? name,
    String? did,
    String? dbId,
    int? length,
    String? secretToken,
    bool? isDbTitle,
    bool? isReversed,
    String? keyHeader,
    String? valueHeader,
  }) {
    return Deck(
      name: name ?? this.name,
      did: did ?? this.did,
      dbId: dbId ?? this.dbId,
      length: length ?? this.length,
      secretToken: secretToken ?? this.secretToken,
      isDbTitle: isDbTitle ?? this.isDbTitle,
      isReversed: isReversed ?? this.isReversed,
      keyHeader: keyHeader ?? this.keyHeader,
      valueHeader: valueHeader ?? this.valueHeader,
    );
  }

  Future<void> createCard(Card card) async {
    try {
      await FirebaseFirestore.instance
          .collection('decks')
          .doc(did)
          .collection('cards')
          .doc(card.cid)
          .set(card.toMap());
    } catch (e) {
      log('Error creating card: $e');
    }
  }

  Future<void> updateLength(String uid) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('decks')
          .doc(did)
          .update({'length': length});
    } catch (e) {
      log('[ERR! update-length]: $e');
    }
  }

  Future<void> createCards(List<Card> cards) async {
    // Batching using 10 cards at a time to speed process
    int batchSize = 10;
    if (cards.isEmpty) return;
    try {
      int index = 0;
      while (index < cards.length) {
        final batch = FirebaseFirestore.instance.batch();
        final endIndex = (index + batchSize < cards.length)
            ? index + batchSize
            : cards.length;
        for (int i = index; i < endIndex; i++) {
          final card = cards[i];
          final cardRef = FirebaseFirestore.instance
              .collection('decks')
              .doc(did)
              .collection('cards')
              .doc(card.cid);
          batch.set(cardRef, card.toMap());
        }
        await batch.commit();
        index += batchSize;
      }
    } catch (e) {
      log('[ERR! create-cards]: $e');
    }
  }

  Future<void> deleteCard(Card card) async {
    try {
      await FirebaseFirestore.instance
          .collection('decks')
          .doc(did)
          .collection('cards')
          .doc(card.cid)
          .delete();
    } catch (e) {
      log('Error deleting card: $e');
    }
  }

  Future<void> deleteAllCards() async {
    try {
      await FirebaseFirestore.instance
          .collection('decks')
          .doc(did)
          .collection('cards')
          .get()
          .then((snapshot) {
        for (DocumentSnapshot doc in snapshot.docs) {
          doc.reference.delete();
        }
      });
    } catch (e) {
      log('Error deleting cards: $e');
    }
  }

  Future<List<Card>> getCards() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('decks')
          .doc(did)
          .collection('cards')
          .orderBy('nextReview')
          .get();
      return snapshot.docs.map((e) => Card.fromDocumentSnapshot(e)).toList();
    } catch (e) {
      log('[ERR! get-cards]s: $e');
      return [];
    }
  }

  Future<double> getExpertise() async {
    /* 
    We treat expertise on a card as a function of repititions and easiness factor 
    */
    double total = 0;
    try {
      log('[get-expertise]: Getting cards');
      List<Card> cards = await getCards();
      if (cards.isEmpty) return 0.0;

      for (Card card in cards) {
        total +=
            calculateProficiency(card.easinessFactor, card.repetitionNumber);
      }
      return total / cards.length;
    } catch (e) {
      log('[ERR! get-expertise]: $e');
      return 0.0;
    }
  }

  double calculateProficiency(double easinessFactor, int repetitionNumber) {
    /* Calculating proficiency with params:
   * EF weight: 0.25
   * Rep weight: 0.75
   * I have chosen these weights as I believe repetition is a much strong indicator of proficiency
   */
    double normalizedEF = easinessFactor / Constants.maxEasinessFactor;
    double normalizedRep = repetitionNumber / Constants.maxRepetitionNumber;
    double proficiencyScore = (0.25 * normalizedEF) + (0.75 * normalizedRep);
    double scaledProficiency = proficiencyScore * 100.0;
    return scaledProficiency.clamp(0.0, 100.0);
  }
}
