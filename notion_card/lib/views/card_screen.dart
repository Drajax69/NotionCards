import 'dart:async';
import 'package:flutter/material.dart';
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
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchCards();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Cards'),
        ),
        body: const Center(child: Text('No cards found')),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Cards'),
        ),
        body: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.2,
                ),
                Text("${currentIndex + 1}/${cards.length}",
                    style: TextStyles.bodyRegular),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 1000),
                  child: _buildFlashcard(),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _showPreviousCard,
                      child: const Text('Previous'),
                    ),
                    ElevatedButton(
                      onPressed: _showNextCard,
                      child: const Text('Next'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildFlashcard() {
    return GestureDetector(
      onTap: _flipCard,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5,
        height: MediaQuery.of(context).size.height * 0.5,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Container(
              key: ValueKey<int>(isFlipped ? 1 : 0),
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  isFlipped
                      ? cards[currentIndex].answer
                      : cards[currentIndex].question,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
