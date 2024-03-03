import 'dart:math';
import 'package:flutter/material.dart';
import 'package:notion_card/controller/card_controller.dart';
import 'package:notion_card/utils/constant.dart';
import 'package:notion_card/repoModels/deck.dart';
import 'package:notion_card/repoModels/card.dart' as repo;
import 'package:notion_card/utils/text_styles.dart';

class CardView extends StatefulWidget {
  final Deck deck;

  const CardView({Key? key, required this.deck}) : super(key: key);

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
  final _controller = CardController();

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
              icon: const Icon(Icons.tips_and_updates),
              tooltip: "Toggle Hiragana View",
              onPressed: _toggleHiraganaView,
              color: showHiragana ? Colors.yellow : Colors.grey,
            ),
            IconButton(
              icon: const Icon(Icons.color_lens),
              onPressed: _showColorPicker,
            ),
          ],
        ),
        body: GestureDetector(
          // Swipe gesture detection
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity! > 0) {
              _showPreviousCard();
            } else if (details.primaryVelocity! < 0) {
              // Swiped from right to left
              _showNextCard();
            }
          },
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxHeight: screenHeight * 0.5,
                maxWidth: max(screenWidth * 0.5, _minCardWidth),
              ),
              child: PageView.builder(
                itemCount: cards.length,
                controller: PageController(initialPage: currentIndex),
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                    isFlipped = false;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildFlashcard(index);
                },
              ),
            ),
          ),
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
              duration: const Duration(milliseconds: 200),
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
                                color: Colors.grey, // Adjust color as needed
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

  void _showNextCard() {
    if (currentIndex < cards.length - 1) {
      setState(() {
        currentIndex++;
        isFlipped = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          showCloseIcon: true,
          duration: Duration(seconds: 1),
          content: Text('End of deck'),
        ),
      );
    }
  }

  void _showPreviousCard() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        isFlipped = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          showCloseIcon: true,
          duration: Duration(seconds: 1),
          content: Text('Start of deck'),
        ),
      );
    }
  }

  void _flipCard() {
    setState(() {
      isFlipped = !isFlipped;
    });
  }
}
