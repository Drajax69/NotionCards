# Notion Card Flutter App

This Flutter app allows users to create flashcard decks from Notion databases and study them.
Link: https://notioncards-23b9e.web.app

**Requirements from Notion**
- You need to setup a Notion Integration to your workspace to get:
  - Secret Token
  - Database ID
- You also need to add integration to pages containing the database
- How to do that: https://developers.notion.com/docs/create-a-notion-integration 
## Features

- **Authentication**: Users can log in using Firebase Authentication.
- **Decks Screen**: Users can view a list of flashcard decks they have created.
- **Add Deck**: Users can add a new deck by providing details such as name, secret, version, database ID, key header, and value header.
- **Fetch Notion Data**: The app fetches data from a specified Notion database using the provided secret, version, and database ID.
- **Card View**: Users can view individual flashcards within a deck, with the ability to flip between question and answer.
- **Next and Previous Cards**: Users can navigate between cards using the Next and Previous buttons.
- **Delete Deck**: Users can delete decks by confirming their action through a dialog.

## Dependencies

- `flutter/material.dart`: For building UI components and handling navigation.
- `firebase_auth`: For user authentication with Firebase.
- `firebase_core`: For initializing Firebase.
- `http`: For making HTTP requests to the Notion API.

## Setup

1. Clone this repository to your local machine.
2. Make sure you have Flutter installed on your machine.
3. Run `flutter pub get` to install dependencies.
4. Set up Firebase Authentication and update `firebase_options.dart` with your Firebase project configuration.
5. Run the app using `flutter run`.

## Usage

- Log in with your Firebase account.
- View existing decks on the Decks Screen.
- Add new decks by providing the necessary details.
- Navigate through flashcards within a deck using Next and Previous buttons.
- Long-press on a deck to delete it (with confirmation).

## Contributing

Contributions are welcome! Feel free to open issues or pull requests for any improvements or additional features you'd like to see in the app.


## Work in Progress
- Logout and Add deck in mobile view
- Vertical Responsiveness
- Beautify Card View Page
- Reducing image load-time from application start (logo, login, etc.)
 
