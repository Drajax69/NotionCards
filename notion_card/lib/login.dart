import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notion_card/register.dart';
import 'package:notion_card/repoModels/user.dart' as model;
import 'package:notion_card/views/deck_screen.dart';
import 'package:notion_card/widget_templates/dialog.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late model.User user;
  bool _isLoading = false;

  Future<void> _signInWithEmailAndPassword() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      user = await _fetchCurrentUser(userCredential.user?.uid ?? "FAILED_UID");
      setState(() {
        user = user;
      });

      if (userCredential.user != null) {
        _goDecks();
      }
    } catch (e) {
      _showLoginFailDialog();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  _fetchCurrentUser(String uid) async {
    await model.User.getUser(uid).then((value) => {
          setState(() {
            user = value!; // Throws if uid mismatched
          })
        });
  }

  _goDecks() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => DecksScreen(
                user: user,
              )),
    );
  }

  _goRegister() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  _showLoginFailDialog() {
    DialogManager.show(context, 'Login Error', 'Incorrect credentials');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
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
                    onPressed: _signInWithEmailAndPassword,
                    child: const Text('Sign In'),
                  ),
            const SizedBox(height: 16.0),
            TextButton(
              onPressed: () {
                _goRegister();
              },
              child: const Text('Go to Register'),
            ),
          ],
        ),
      ),
    );
  }
}
