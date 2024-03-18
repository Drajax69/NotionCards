import 'dart:async';
import 'dart:math';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:notion_card/controller/card_controller.dart';
import 'package:notion_card/repoModels/user.dart';
import 'package:notion_card/utils/constant.dart';
import 'package:notion_card/repoModels/deck.dart';
import 'package:notion_card/repoModels/card.dart' as repo;
import 'package:notion_card/utils/text_styles.dart';
import 'package:notion_card/utils/text_to_voice.dart';
import 'package:notion_card/widget_templates/dialog.dart';
import 'package:notion_card/widget_templates/difficulty_selector.dart';

class CardView extends StatefulWidget {
  final Deck deck;
  final User user;
  final Function callback;
  const CardView(
      {super.key,
      required this.deck,
      required this.user,
      required this.callback});

  @override
  State<CardView> createState() => _CardViewState();
}

class _CardViewState extends State<CardView> {
  late List<repo.Card> cards;
  List<repo.Card> toUpdateCards = [];
  Timer? _updateTimer;
  bool isLoading = true;
  int currentIndex = 0;
  bool isFlipped = false;
  final double _toolbarHeight = 100;
  final double _minCardWidth = 300;
  late Color cardColor;
  List<Color> colorOptions = Constants.cardColorOptions;
  bool showHiragana = false;
  final CardController _controller = CardController();
  final TextToSpeech _tts = TextToSpeech();
  final PageController _pageController = PageController(initialPage: 0);
  final int _transitionDurationMs = 300;
  final double _bottomPadding = 25;
  final double _interIconSpacing = 10;
  final Duration _updateDuration = const Duration(seconds: 2);
  List<int> sliderValues = []; // Stores answers
  List<SelectorButton> selectedOptions = [
    SelectorButton(
      title: '1',
      color: const Color.fromARGB(255, 98, 6, 6),
      width: 40, // Width of the button
    ),
    SelectorButton(
      title: '2',
      color: const Color.fromARGB(255, 225, 80, 28),
      width: 40, // Width of the button
    ),
    SelectorButton(
      title: '3',
      color: const Color.fromARGB(255, 106, 105, 105),
      width: 40, // Width of the button
    ),
    SelectorButton(
      title: '4',
      color: Colors.green,
      width: 40, // Width of the button
    ),
    SelectorButton(
      title: '5',
      color: const Color.fromARGB(255, 2, 86, 5),
      width: 40, // Width of the button
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fetchCards();
    startUpdateTimer();
    toUpdateCards = [];
    cardColor =
        colorOptions[0]; // Initialize card color with the first color option
  }

  @override
  void dispose() {
    super.dispose();
    cancelUpdateTimer();
  }

  void cancelUpdateTimer() {
    _updateTimer?.cancel();
  }

  void startUpdateTimer() {
    _updateTimer = Timer.periodic(_updateDuration, (timer) {
      // dev.log(sliderValues.toString());
      _updateCards();
    });
  }

  /* UI */

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool fullView = screenWidth > Constants.phoneWidth;
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.deck.name,
            style: TextStyles.cardHeaderBlack,
          ),
          toolbarHeight: _toolbarHeight,
        ),
        body: const Center(child: Text('No cards found')),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              widget.callback(widget
                  .deck); 
              Navigator.of(context)
                  .pop(); 
            },
          ),
          toolbarHeight: _toolbarHeight,
          title: Center(
            child: Text(
              widget.deck.name,
              style: fullView
                  ? TextStyles.headerBlack
                  : TextStyles.cardHeaderPhoneBlack,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.info),
              onPressed: __showInfoDialog,
            ),
            SizedBox(width: _interIconSpacing),
            IconButton(
              icon: Text(
                showHiragana ? 'あ' : 'abc',
                style: TextStyles.toggleFont, // Adjust font size as needed
              ),
              tooltip:
                  showHiragana ? "Toggle Hiragana View" : "Toggle ABC View",
              onPressed: _toggleHiraganaView,
              color: showHiragana ? Colors.yellow : Colors.grey,
            ),
            SizedBox(width: _interIconSpacing),
            IconButton(
              icon: const Icon(Icons.color_lens),
              onPressed: _showColorPicker,
            ),
            SizedBox(width: _interIconSpacing)
          ],
        ),
        body: GestureDetector(
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxHeight: screenHeight * 0.5,
                maxWidth: max(screenWidth * 0.5, _minCardWidth),
              ),
              child: PageView.builder(
                itemCount: cards.length,
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                    isFlipped = false;
                    showHiragana = false;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildFlashcard(index, screenWidth);
                },
              ),
            ),
          ),
        ),
        bottomNavigationBar: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              padding: EdgeInsets.only(bottom: _bottomPadding),
              onPressed: () {
                _pageController.previousPage(
                  duration: Duration(milliseconds: _transitionDurationMs),
                  curve: Curves.ease,
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              padding: EdgeInsets.only(bottom: _bottomPadding),
              onPressed: () {
                _pageController.nextPage(
                  duration: Duration(milliseconds: _transitionDurationMs),
                  curve: Curves.ease,
                );
              },
            ),
          ],
        ),
      );
    }
  }

  Widget _buildFlashcard(int index, double screenWidth) {
    return GestureDetector(
        onTap: _flipCard,
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Card(
              color: cardColor,
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 0),
                child: Container(
                  key: ValueKey<int>(isFlipped ? 1 : 0),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isFlipped
                                  ? cards[index].answer
                                  : cards[index].question,
                              textAlign: TextAlign.center,
                              style: TextStyles.cardTextFont,
                            ),
                            if (showHiragana)
                              Text(
                                isFlipped
                                    ? _toRomaji(cards[index].answer)
                                    : _toRomaji(cards[index].question),
                                textAlign: TextAlign.center,
                                style: TextStyles.cardTextFont.copyWith(
                                  fontSize: 16,
                                  color: const Color.fromARGB(255, 50, 49, 49),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "${index + 1}/${cards.length}",
                            style: TextStyles.cardIndexingFont,
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.volume_up),
                            onPressed: () {
                              _tts.speak(
                                isFlipped
                                    ? cards[index].answer
                                    : cards[index].question,
                              );
                            },
                          ),
                        ],
                      ),
                      // Choose confidence level
                      if (screenWidth > _minCardWidth)
                        DifficultySelector(
                            index: sliderValues[index] > 0
                                ? sliderValues[index]
                                : 0, // Index of the selector
                            onChanged: (value) {
                              setState(() {
                                sliderValues[index] = value;
                                if (toUpdateCards.contains(cards[index])) {
                                  toUpdateCards.remove(cards[index]);
                                }
                                toUpdateCards.add(cards[index]);
                              });
                            },
                            selectorButtons: selectedOptions),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }

  Future<void>? _updateCards() async {
    for (repo.Card card in toUpdateCards) {
      int cardIndex = cards.indexWhere((element) => element.cid == card.cid);
      card.applySRAlgirthm(
          widget.user.uid, widget.deck.did, sliderValues[cardIndex]);
    }
    setState(() {
      toUpdateCards = [];
    });
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Select Card Color'),
          content: SizedBox(
            width: 300, // Adjust the width as needed
            height: 300, // Adjust the height as needed
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              childAspectRatio: 1.0,
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
              children: colorOptions.map((color) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      cardColor = color;
                    });
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        color: Colors.black,
                        width: 0.5,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  __showInfoDialog() {
    DialogManager.show(context, 'How to use',
        '- Select a card to flip it\n- Tap the speaker icon to hear the pronunciation\n- Select a confidence level for spaced repetition\n- The card color can be changed from the top right corner\n- Hiragana to Romaji can be toggled from the top right corner');
  }

  /* Logic functions */

  _toggleHiraganaView() {
    setState(() {
      showHiragana = !showHiragana;
    });
  }

  _toRomaji(String hiragana) {
    String romaji = _controller.japaneseToRomaji(hiragana) ?? '';
    return romaji;
  }

  void _fetchCards() async {
    dev.log("Fetching cards for deck: ${widget.deck.name}");
    List<repo.Card> sortedCards = await widget.deck.getCards();
    setState(() {
      cards = sortedCards;
      sliderValues = List.filled(cards.length, -1);
      isLoading = false;
    });
  }

  void _flipCard() {
    setState(() {
      isFlipped = !isFlipped;
    });
  }
}
