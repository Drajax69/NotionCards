# Notion Card Flutter App

Latest version: 1.3.1

This Flutter app allows users to create flashcard decks from Notion databases and study them.
Link: https://notioncards-23b9e.web.app

**Requirements from Notion**

- You need to setup a Notion Integration to your workspace to get:
  - Secret Token
  - Database ID
- You also need to add integration to pages containing the database
- See https://developers.notion.com/docs/create-a-notion-integration for more

## Features

- **Authentication**: Users can log in using Firebase Authentication.
- **Decks Screen**: Users can view a list of flashcard decks they have created.

  - Users can add a deck using any columns from their Notion database (need to specify if not using database title as questions)
  - Users can create a reversed deck where all the questions and answers are swapped
  - Users can update their decks at any time
  - Users can delete decks without affecting Notion database
  - Expertise on decks - Using weighted calculations on repetitions, easiness, confidence, etc.
- **Card View**: Users can view individual flashcards within a deck, with the ability to flip between question and answer.

  - Users can specify what colour they want their cards to be (9 options).
  - Swipable and can be viewed using any device (i.e phone, tablet, laptop...).
  - Cards in a deck are randomized for a better learning experience.
  - Hiragana and Katakana can be translated to romaji directly through translator toggle
  - Users can fill out their confidence level for each card to apply *Spaced Repetition* to their learning

## Dependencies

- `flutter/material.dart`: For building UI components and handling navigation.
- `firebase_auth`: For user authentication with Firebase.
- `firebase_core`: For initializing Firebase.
- `http`: For making HTTP requests to the Notion API.
- `tts`: Text-to-Speech for Pronunciation practice

## Setup

1. Clone this repository to your local machine.
2. Make sure you have Flutter installed on your machine.
3. Run `flutter pub get` to install dependencies.
4. Set up Firebase Authentication and update `firebase_options.dart` with your Firebase project configuration.
5. Set *devEnv* NetworkImageConstants to **true**
6. Run the app using `flutter run`.

## Contributing

Contributions are welcome! Feel free to open issues or pull requests for any improvements or additional features you'd like to see in the app.
