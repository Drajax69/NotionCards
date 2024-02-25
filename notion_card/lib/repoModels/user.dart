import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'deck.dart';

class User {
  final String uid;
  final Timestamp creationTimestamp;
  final String name;

  User( {required this.name,
    required this.uid,
    
    required this.creationTimestamp,
  });

  static Future<User?> getUser(String uid) async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (snapshot.exists) {
        log("[getUser] User found for uid: $uid");

        return User.fromDocumentSnapshot(snapshot);
      } else {
        log("[getUser] User not found for uid: $uid");
        return null;
      }
    } catch (e) {
      log('Error getting user: $e');
      return null;
    }
  }

  Future<void> saveToFirestore() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(toMap());
    } catch (e) {
      log('Error saving user to Firestore: $e');
    }
  }

  static Future<void> createUser(User user) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(user.toMap());
    } catch (e) {
      log('Error creating user: $e');
    }
  }

  // Add a method to create a deck for the user
  Future<void> createDeckRepo(Deck deck) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('decks')
          .doc(deck.did)
          .set(deck.toMap());
    } catch (e) {
      log('Error creating deck: $e');
    }
  }

  Future<void> deleteDeckRepo(Deck deck) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('decks')
          .doc(deck.did)
          .delete();
    } catch (e) {
      log('Error deleting deck: $e');
    }
  }

  Future<void> updateDeckRepo(Deck deck) async {
    /* Update the deck in the user's collection by fetching from data notion */
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('decks')
          .doc(deck.did)
          .update(deck.toMap());
    } catch (e) {
      log('Error updating deck: $e');
    }
  }

  Future<List<Deck>> getDecks() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('decks')
          .get();
      return snapshot.docs.map((e) => Deck.fromDocumentSnapshot(e)).toList();
    } catch (e) {
      log('Error getting decks: $e');
      return [];
    }
  }

  static User fromDocumentSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return User(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      creationTimestamp: data['creationTimestamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'creationTimestamp': creationTimestamp,
      'name': name,
    };
  }
}
