import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:notion_card/login.dart';
import 'package:notion_card/views/deck_screen.dart';
import 'firebase_options.dart';
import 'package:notion_card/repoModels/user.dart' as model;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const NotionCards());
}

class NotionCards extends StatelessWidget {
  const NotionCards({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NotionCards',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder<model.User?>(
        future: _fetchCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While waiting for the future to complete, you can show a loading indicator
            return const SizedBox(
                height: 20,
                width: 20,
                child: Center(child: CircularProgressIndicator()));
          } else {
            if (snapshot.hasError) {
              // If an error occurred during fetching user data, display an error message
              return Text('Error: ${snapshot.error}');
            } else {
              // If user data is successfully fetched, display the appropriate screen
              final user = snapshot.data;
              return user != null ? DecksScreen(user: user) : const LoginPage();
            }
          }
        },
      ),
    );
  }

  Future<model.User?> _fetchCurrentUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      return await model.User.getUser(currentUser.uid);
    }
    return null;
  }
}


// curl -X POST 'https://api.notion.com/v1/databases/c125b18abaee487f8380ba20e1a9f629/query' \
//   -H 'Authorization: Bearer 'secret_TxGjOD26XUKPaTsCNwY5XdRaANtvHVywJVzK9mQERjV'' \
//   -H 'Notion-Version: 2022-06-28' \
//   -H "Content-Type: application/json" 
