import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notion_card/controller/deck_controller.dart';
import 'package:notion_card/login.dart';
import 'package:notion_card/repoModels/deck.dart';
import 'package:notion_card/repoModels/user.dart' as model;
import 'package:notion_card/utils/network_image.dart';
import 'package:notion_card/utils/text_styles.dart';
import 'package:notion_card/views/card_screen.dart';
import 'package:notion_card/widget_templates/dialog.dart';
import 'package:notion_card/widget_templates/loading_indicator.dart';

class DecksScreen extends StatefulWidget {
  const DecksScreen({super.key, required this.user});
  final model.User user;

  @override
  State<DecksScreen> createState() => _DecksScreenState();
}

class _DecksScreenState extends State<DecksScreen> {
  List<Deck> decks = [];
  bool _isLoading = true;
  List<Deck> decksLoading = [];
  final String defaultVersion = "2022-06-28";
  late DeckController _deckController;
  final double topSpacing = 50;
  final double addDialogWidth = 500;
  final double _minDisplayPanel = 600;
  final double _minPortaitHeight = 650;
  final double _leftPanelProportion = 0.4;
  final double _minWindowHeight = 430;
  Image logo = NetworkImageConstants.getLogoDinoImage(
      width: double.infinity, height: 200);
  List<Image> loadingImages = NetworkImageConstants.getLoadingIndicatorImages();
  final double _titleListSpacing = 20;
  bool isDbTitle = true;
  bool hamburgerMenuOpen = false;

  @override
  void initState() {
    _deckController = DeckController(user: widget.user);
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

  /* UI */

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool phoneDisplay = screenWidth < _minDisplayPanel;
    bool isPortrait = screenHeight > _minPortaitHeight;
    bool showLogo = screenHeight > _minWindowHeight;
    return Scaffold(
      body: _isLoading
          ? Center(
              child: LoadingIndicator(
                images: loadingImages,
                text: 'Loading...',
              ),
            )
          : _buildDeckList(phoneDisplay, isPortrait, showLogo),
    );
  }

  Widget? _buildFloatingActionButtons(bool phoneDisplay) {
    if (!phoneDisplay) {
      return null;
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          mini: true,
          onPressed: () {
            setState(() {
              hamburgerMenuOpen = !hamburgerMenuOpen;
            });
          },
          child: Icon(hamburgerMenuOpen ? Icons.close : Icons.menu),
        ),
        const SizedBox(height: 16.0),
        AnimatedContainer(
          duration: const Duration(milliseconds: 0),
          height: hamburgerMenuOpen ? 192.0 : 0.0,
          child: Column(
            children: [
              FloatingActionButton(
                mini: true,
                heroTag: 'logout',
                onPressed: _logout,
                child: const Icon(Icons.logout),
              ),
              const SizedBox(height: 16),
              FloatingActionButton(
                mini: true,
                heroTag: 'info',
                onPressed: __showInfoDialog,
                child: const Icon(Icons.info),
              ),
              const SizedBox(height: 16),
              FloatingActionButton(
                mini: true,
                heroTag: 'add',
                onPressed: _showAddDeckDialog,
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeckList(bool phoneDisplay, bool isPortrait, bool showLogo) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Side: Divider with Welcome Message
        if (!phoneDisplay)
          Container(
            padding: EdgeInsets.symmetric(
                vertical: isPortrait ? topSpacing : 10, horizontal: 20),
            width: MediaQuery.of(context).size.width *
                _leftPanelProportion, // Adjust width as needed
            color: const Color.fromARGB(255, 169, 175, 238),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image(
                    image: logo.image,
                    height: isPortrait ? 200 : 100,
                  ),
                ),
                if (showLogo) const SizedBox(height: 10),
                if (showLogo)
                  Text(
                    'Welcome, ${widget.user.name}',
                    style: isPortrait
                        ? TextStyles.headerWhiteWithBorder
                        : TextStyles.headerWhiteWithBorder
                            .copyWith(fontSize: 35),
                  ),
                const SizedBox(height: 20),
                // Add Deck Gesture
                GestureDetector(
                  onTap: () {
                    _showAddDeckDialog();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.add),
                        const SizedBox(width: 8),
                        Text(
                          'Add Deck',
                          style: TextStyles.iconText.copyWith(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isPortrait) const Spacer(),
                // Info and Logout
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.info),
                      onPressed: __showInfoDialog,
                    ),
                    GestureDetector(
                      onTap: __showInfoDialog,
                      child: const Text(
                        "How to use",
                        style: TextStyles.iconText,
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: _logout,
                    ),
                    GestureDetector(
                      onTap: _logout,
                      child: const Text(
                        "Logout",
                        style: TextStyles.iconText,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        // Right Side: Deck List
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: topSpacing),
                Center(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Spacer(),
                              Text(
                                phoneDisplay || !showLogo
                                    ? '${widget.user.name.split(' ').first}\'s Decks'
                                    : 'Your Decks',
                                style: TextStyles.headerBlack,
                              ),
                              const Spacer(),
                              _buildFloatingActionButtons(phoneDisplay) ??
                                  const SizedBox(),
                            ]))),
                SizedBox(height: _titleListSpacing),
                if (decks.isEmpty)
                  const Center(child: Text('Add your first deck!')),
                for (int index = 0; index < decks.length; index++)
                  GestureDetector(
                    onTap: () {
                      decksLoading.contains(decks[index])
                          ? _showUpdateLoadingDialog()
                          : Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CardView(
                                  deck: decks[index],
                                  user: widget.user,
                                ),
                              ),
                            );
                    },
                    child: Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text(
                          '${decks[index].name} (${decks[index].length})',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text('Tap to view cards'),
                        trailing: decksLoading.contains(decks[index])
                            ? const Text("loading...")
                            : (decks[index].isReversed)
                                ? PopupMenuButton(
                                    itemBuilder: (BuildContext context) =>
                                        <PopupMenuEntry>[
                                          PopupMenuItem(
                                            child: ListTile(
                                              leading: const Icon(Icons.delete),
                                              title: const Text('Delete'),
                                              onTap: () {
                                                Navigator.pop(
                                                    context); // Close the menu
                                                _confirmDeleteDeck(
                                                    decks[index]);
                                              },
                                            ),
                                          ),
                                        ])
                                : PopupMenuButton(
                                    itemBuilder: (BuildContext context) =>
                                        <PopupMenuEntry>[
                                      PopupMenuItem(
                                        child: ListTile(
                                          leading: const Icon(Icons.update),
                                          title: const Text('Update'),
                                          onTap: () {
                                            Navigator.pop(
                                                context); // Close the menu
                                            _updateDeck(decks[index]);
                                          },
                                        ),
                                      ),
                                      PopupMenuItem(
                                        child: ListTile(
                                          leading: const Icon(Icons.swap_horiz),
                                          title: const Text(
                                              'Generate Reversed Cards'),
                                          onTap: () {
                                            Navigator.pop(
                                                context); // Close the menu
                                            _generateReversed(decks[index]);
                                          },
                                        ),
                                      ),
                                      PopupMenuItem(
                                        child: ListTile(
                                          leading: const Icon(Icons.delete),
                                          title: const Text('Delete'),
                                          onTap: () {
                                            Navigator.pop(
                                                context); // Close the menu
                                            _confirmDeleteDeck(decks[index]);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /* Logic functions */

  _logout() {
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  _showAddDeckDialog() {
    String secret = '';
    String dbID = '';
    String keyHeader = '';
    String valueHeader = '';
    String name = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Deck'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(height: 10),
                TextField(
                  decoration: const InputDecoration(labelText: 'Deck name'),
                  onChanged: (value) {
                    name = value;
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  decoration: const InputDecoration(labelText: 'Auth Secret'),
                  onChanged: (value) {
                    secret = value;
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  decoration:
                      const InputDecoration(labelText: 'Notion Database ID'),
                  onChanged: (value) {
                    dbID = value;
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  decoration:
                      const InputDecoration(labelText: 'Question header'),
                  onChanged: (value) {
                    keyHeader = value;
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  decoration: const InputDecoration(labelText: 'Answer header'),
                  onChanged: (value) {
                    valueHeader = value;
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return Checkbox(
                          value: isDbTitle,
                          onChanged: (value) {
                            setState(() {
                              isDbTitle = value!;
                            });
                          },
                        );
                      },
                    ),
                    const Text('DB title matches deck title?', softWrap: true),
                  ],
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
                _createDeck(name, dbID, secret, isDbTitle, keyHeader,
                    valueHeader, isDbTitle);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  __showInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Info'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildInfoText(
                  '- This is a flashcard app that uses Notion as a database.',
                ),
                _buildInfoText(
                  '- You can add a deck by providing the name, secret, version, database ID, key header, and value header.',
                ),
                _buildInfoText(
                  '- You need a notion integration to be able to fetch data from notion.',
                ),
                _buildInfoText(
                  '- Deleting a deck here will not delete the notion database.',
                ),
                _buildInfoText(
                  '- Click update deck whenever you update the notion database.',
                ),
                _buildInfoText(
                  '- Reversed decks cannot be updated or reversed again. If you want to update then you can either delete re-create it or delete, update the original deck and then generate reversed cards again.',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        text,
        style: TextStyles.bodyRegular,
      ),
    );
  }

  _createDeck(String name, String dbID, String secretToken, bool reversible,
      String keyHeader, String valueHeader, bool isDbTitle) async {
    setState(() {
      _isLoading = true;
    });
    Deck? deck = await _deckController.createDeck(
      name: name,
      dbId: dbID,
      secretToken: secretToken,
      isDbTitle: isDbTitle,
      keyHeader: keyHeader,
      valueHeader: valueHeader,
    );

    if (deck != null) {
      widget.user.createDeckRepo(deck);
      if (mounted) {
        setState(() {
          decks.insert(0, deck);
        });
      }
      setState(() {
        _isLoading = false;
      });
    } else {
      _showDialogError();
    }
  }

  _updateDeck(Deck deck) async {
    setState(() {
      decksLoading.add(deck);
    });
    Deck? updatedDeck = await _deckController.updateDeck(deck);
    if (updatedDeck != null) {
      setState(() {
        decks[decks.indexWhere((d) => d.did == deck.did)] = updatedDeck;
      });
    } else {
      _showDialogUpdateError();
    }
    setState(() {
      decksLoading.removeWhere((d) => d.did == deck.did);
    });
  }

  _generateReversed(Deck deck) async {
    setState(() {
      _isLoading = true;
    });
    Deck? reversedDeck = await _deckController.generateReversed(deck);
    if (reversedDeck != null) {
      setState(() {
        decks.add(reversedDeck);
      });
      setState(() {
        _isLoading = false;
      });
    } else {
      _showDialogUpdateError();
    }
  }

  _deleteDeck(Deck deck) {
    _deckController.deleteDeck(deck);
    if (mounted) {
      setState(() {
        decks.removeWhere((d) => d.did == deck.did);
      });
    }
  }

  _showDialogError() {
    DialogManager.show(context, 'Error',
        'Failed to fetch decks. Please ensure the details are correct.');
  }

  _showDialogUpdateError() {
    DialogManager.show(context, 'Error', 'Failed to update deck. Try again.');
  }

  _showUpdateLoadingDialog() {
    DialogManager.show(context, 'Please wait',
        'This deck is loading. Please do not exit app or refresh the page.');
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
