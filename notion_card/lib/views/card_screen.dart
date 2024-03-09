import 'dart:math';
import 'package:flutter/material.dart';
import 'package:notion_card/controller/card_controller.dart';
import 'package:notion_card/utils/constant.dart';
import 'package:notion_card/repoModels/deck.dart';
import 'package:notion_card/repoModels/card.dart' as repo;
import 'package:notion_card/utils/text_styles.dart';
import 'package:notion_card/utils/text_to_voice.dart';

class CardView extends StatefulWidget {
  final Deck deck;

  const CardView({super.key, required this.deck});

  @override
  State<CardView> createState() => _CardViewState();
}

class _CardViewState extends State<CardView> {
  late List<repo.Card> cards;
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

  @override
  void initState() {
    super.initState();
    _fetchCards();
    cardColor =
        colorOptions[0]; // Initialize card color with the first color option
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
                  return _buildFlashcard(index);
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

  Widget _buildFlashcard(int index) {
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
                                fontSize: 16, // Adjust as needed
                                color: const Color.fromARGB(
                                    255, 50, 49, 49), // Adjust color as needed
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
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
    cards = await widget.deck.getCards();
    cards.shuffle();
    setState(() {
      isLoading = false;
    });
  }

  void _flipCard() {
    setState(() {
      isFlipped = !isFlipped;
    });
  }
}
