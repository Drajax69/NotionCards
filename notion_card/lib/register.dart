import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notion_card/repoModels/user.dart' as model;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notion_card/login.dart';
import 'package:notion_card/views/deck_screen.dart';
import 'package:notion_card/widget_templates/dialog.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late model.User user;
  bool _isLoading = false;


  Future<void> _registerWithEmailAndPassword() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (userCredential.user != null) {
        final uid = userCredential.user?.uid ?? "FAILED_UID";
        model.User user =
            model.User(uid: uid, creationTimestamp: Timestamp.now());
        model.User.createUser(user);
        setState(() {
          this.user = user;
        });
        _goDecks();
      }
    } catch (e) {
      // Show error message in snackbar or dialog
      log(e.toString());
      _showLoginFailDialog();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  _goDecks() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => DecksScreen(user: user,)),
    );
  }

  _showLoginFailDialog() {
    DialogManager.show(
        context, 'Registration Error', 'Could not register user');
  }

  _goLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16.0),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _registerWithEmailAndPassword,
                    child: const Text('Register'),
                  ),
            const SizedBox(height: 16.0),
            TextButton(
              onPressed: () {
                _goLogin();
              },
              child: const Text('Go to Register'),
            ),
          ],
        ),
      ),
    );
  }
}
