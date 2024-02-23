import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:notion_card/httpService/notion_service.dart';
import 'package:notion_card/repoModels/card.dart' as repo;
import 'package:notion_card/repoModels/deck.dart';
import 'package:notion_card/repoModels/user.dart';
import 'package:notion_card/utils/id_generator.dart';
import 'package:notion_card/views/card_screen.dart';
import 'package:notion_card/widget_templates/dialog.dart';

class DecksScreen extends StatefulWidget {
  const DecksScreen({Key? key, required this.user}) : super(key: key);
  final User user;

  @override
  State<DecksScreen> createState() => _DecksScreenState();
}

class _DecksScreenState extends State<DecksScreen> {
  List<Deck> decks = [];
  bool _isLoading = true;

  @override
  void initState() {
    _fetchDecks();
    super.initState();
  }

  _fetchDecks() async {
    decks = await widget.user.getDecks();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards Decks'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildDeckList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddDeckDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDeckList() {
    return ListView.builder(
      itemCount: decks.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CardView(deck: decks[index]),
              ),
            );
          },
          child: Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(
                decks[index].name,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Tap to view cards'),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  _confirmDeleteDeck(decks[index]);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showAddDeckDialog(BuildContext context) async {
    String secret = '';
    String version = '';
    String dbID = '';
    String keyHeader = '';
    String valueHeader = '';
    String name = '';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Deck'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  decoration: const InputDecoration(labelText: 'Name'),
                  onChanged: (value) {
                    name = value;
                  },
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Secret'),
                  onChanged: (value) {
                    secret = value;
                  },
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Version'),
                  onChanged: (value) {
                    version = value;
                  },
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'DB ID'),
                  onChanged: (value) {
                    dbID = value;
                  },
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Key Header'),
                  onChanged: (value) {
                    keyHeader = value;
                  },
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Value Header'),
                  onChanged: (value) {
                    valueHeader = value;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                _fetchNotionData(
                    name, secret, version, dbID, keyHeader, valueHeader);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _createDeck(data, String name, String dbId, String secretToken,
      bool reversible, String keyHeader, String valueHeader) {
    List<repo.Card>? cards = NotionService.convertResponseBodyToDeckModel(
        data, name, keyHeader, valueHeader);
    if (cards == null) {
      _showDialogError();
      return;
    }
    Deck deck = Deck(
      name: name,
      did: IdGenerator.getRandomString(10),
      dbId: dbId,
      secretToken: secretToken,
      reversible: reversible,
      keyHeader: keyHeader,
      valueHeader: valueHeader,
    );
    widget.user.createDeckRepo(deck);
    deck.createCards(cards);

    setState(() {
      decks.add(deck);
    });
  }

  _deleteDeck(Deck deck) {
    widget.user.deleteDeckRepo(deck);
    setState(() {
      decks.removeWhere((d) => d.did == deck.did);
    });
  }

  Future<void> _fetchNotionData(String name, String secret, String version,
      String dbID, String keyHeader, String valueHeader) async {
    final Map<String, String> headers = {
      'Authorization': 'Bearer $secret',
      'Notion-Version': version,
      'Content-Type': 'application/json',
      "Access-Control-Allow-Origin": "*",
      'Accept': '*/*',
      "Access-Control-Allow-Methods": "POST, GET, OPTIONS, PUT, DELETE, HEAD",
    };

    final response = await http.post(
      Uri.https("api.notion.com", "v1/databases/$dbID/query"),
      headers: headers,
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      log('Fetched data: $data');
      _createDeck(data, name, dbID, secret, false, keyHeader,
          valueHeader); // Reversibility logic
    } else {
      log('Failed to fetch decks: ${response.statusCode}');
      _showDialogError();
    }
  }

  _showDialogError() {
    DialogManager.show(context, 'Error', 'Failed to fetch decks');
  }

  Future<void> _confirmDeleteDeck(Deck deck) async {
    bool? result = await DialogManager.showConfirmDialog(
      context,
      'Delete Deck',
      'Are you sure you want to delete ${deck.name}?',
    );

    if (result == true) {
      _deleteDeck(deck);
    }
  }
}
