import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
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
    if (cards.isEmpty) return;
    try {
      for (final card in cards) {
        // log("creating card: ${card.question}");
        final cardRef = FirebaseFirestore.instance
            .collection('decks')
            .doc(did)
            .collection('cards')
            .doc(card.cid);
        await cardRef.set(card.toMap());
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
}
