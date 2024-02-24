import 'dart:convert';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notion_card/httpService/cors_gateway_service.dart';
import 'package:notion_card/httpService/notion_service.dart';
import 'package:notion_card/login.dart';
import 'package:notion_card/repoModels/card.dart' as repo;
import 'package:notion_card/repoModels/deck.dart';
import 'package:notion_card/repoModels/user.dart' as model;
import 'package:notion_card/utils/id_generator.dart';
import 'package:notion_card/utils/text_styles.dart';
import 'package:notion_card/views/card_screen.dart';
import 'package:notion_card/widget_templates/dialog.dart';

class DecksScreen extends StatefulWidget {
  const DecksScreen({Key? key, required this.user}) : super(key: key);
  final model.User user;

  @override
  State<DecksScreen> createState() => _DecksScreenState();
}

class _DecksScreenState extends State<DecksScreen> {
  List<Deck> decks = [];
  bool _isLoading = true;
  final String defaultVersion = "2022-06-28";

  @override
  void initState() {
    _fetchDecks();
    super.initState();
  }

  _fetchDecks() async {
    decks = await widget.user.getDecks();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 120,
        title: const Text('Flashcards Decks', style: TextStyles.headerBlack),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              __showInfoDialog();
            },
          ),
          const SizedBox(
            width: 10,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _logout();
            },
          ),
        ],
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

  _logout() {
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
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
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Tap to view cards'),
                  trailing: PopupMenuButton(
                    itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                      PopupMenuItem(
                        child: ListTile(
                          leading: const Icon(Icons.update),
                          title: const Text('Update'),
                          onTap: () {
                            Navigator.pop(context); // Close the menu
                            _updateDeck(decks[index]);
                          },
                        ),
                      ),
                      PopupMenuItem(
                        child: ListTile(
                          leading: const Icon(Icons.delete),
                          title: const Text('Delete'),
                          onTap: () {
                            Navigator.pop(context); // Close the menu
                            _confirmDeleteDeck(decks[index]);
                          },
                        ),
                      ),
                    ],
                  ),
                )));
      },
    );
  }

  Future<void> _showAddDeckDialog(BuildContext context) async {
    String secret = '';
    String version = defaultVersion; // default
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
                  decoration: InputDecoration(
                      labelText: 'Version', hintText: defaultVersion),
                  onChanged: (value) {
                    version = value;
                  },
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Database ID'),
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

  __showInfoDialog() {
    DialogManager.show(
      context,
      'Info',
      ' - This is a flashcard app that uses Notion as a database. \n'
          ' - You can add a deck by providing the name, secret, version, database ID, key header, and value header.  \n'
          ' - You need a notion integration to be able to fetch data from notion.\n'
          ' - Deleting a deck here will not delete the notion database.  \n'
          ' - Click update deck whenever you update the notion database.  \n'
          ' - Contact dev at amriteshdasgupta@gmail.com.  \n',
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
    if (mounted) {
      setState(() {
        decks.add(deck);
      });
    }
  }

  _updateDeck(Deck deck) async {
    // await _deleteDeck(deck);

    // bool fetchSuccess = await _fetchNotionData(deck.name, deck.secretToken,
    //     defaultVersion, deck.dbId, deck.keyHeader, deck.valueHeader);

    if (mounted) {
      setState(() {
        decks.add(deck);
      });
    }
  }

  _deleteDeck(Deck deck) {
    widget.user.deleteDeckRepo(deck);
    if (mounted) {
      setState(() {
        decks.removeWhere((d) => d.did == deck.did);
      });
    }
  }

  Future<bool> _fetchNotionData(String name, String secret, String version,
      String dbID, String keyHeader, String valueHeader) async {
    try {
      final Map<String, String> headers = {
        'Authorization': 'Bearer $secret',
        'Notion-Version': version,
        'Content-Type': 'application/json',
        'X-REQUESTED-WITH': '*'
        // No need for Access-Control-Allow-Origin header
        // No need for Access-Control-Allow-Methods header
      };

      CorsGatewayService corsGateway =
          CorsGatewayService('https://api.notion.com/v1/databases/');

      final response = await corsGateway.post('$dbID/query', headers);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        log('Fetched data: $data');
        _createDeck(data, name, dbID, secret, false, keyHeader,
            valueHeader); // Reversibility logic
        return true;
      } else {
        log('Failed to fetch decks: ${response.statusCode}');
        _showDialogError();
      }
    } catch (e) {
      log('Error fetching data: $e');
      _showDialogError();
    }
    return false;
  }

  _showDialogError() {
    DialogManager.show(
        context, 'Error', 'Failed to fetch decks. Please double check one of ');
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
