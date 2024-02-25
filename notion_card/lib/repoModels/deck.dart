import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'card.dart'; // Import your Card class

class Deck {
  final String name;
  final String did; // Deck ID
  final String dbId; // Database ID
  final int length;
  final String secretToken;
  final bool reversible;
  final String keyHeader;
  final String valueHeader;

  Deck({ required this.length,
    required this.name,
    required this.did,
    required this.dbId,
    required this.secretToken,
    required this.reversible,
    required this.keyHeader,
    required this.valueHeader,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'did': did,
      'dbId': dbId,
      'secretToken': secretToken,
      'reversible': reversible,
      'keyHeader': keyHeader,
      'valueHeader': valueHeader,
      'length': length,
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
      reversible: data['reversible'] ?? false,
      keyHeader: data['keyHeader'] ?? '',
      valueHeader: data['valueHeader'] ?? '',
    );
  }

  static Deck fromMap(Map<String, dynamic> map) {
    return Deck(
      name: map['name'] ?? '',
      did: map['did'] ?? '',
      dbId: map['dbId'] ?? '',
      secretToken: map['secretToken'] ?? '',
      reversible: map['reversible'] ?? false,
      keyHeader: map['keyHeader'] ?? '',
      valueHeader: map['valueHeader'] ?? '',
      length: map['length'] ?? 0,
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

  Future<void> createCards(List<Card> cards) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      for (final card in cards) {
        final cardRef = FirebaseFirestore.instance
            .collection('decks')
            .doc(did)
            .collection('cards')
            .doc(card.cid);
        batch.set(cardRef, card.toMap());
      }
      await batch.commit();
    } catch (e) {
      log('Error creating cards: $e');
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

  Future<List<Card>> getCards() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('decks')
          .doc(did)
          .collection('cards')
          .get();
      return snapshot.docs.map((e) => Card.fromDocumentSnapshot(e)).toList();
    } catch (e) {
      log('Error getting cards: $e');
      return [];
    }
  }
}
