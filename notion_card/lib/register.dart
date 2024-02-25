import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notion_card/widget_templates/description_panel.dart';
import 'package:notion_card/login.dart';
import 'package:notion_card/utils/network_image.dart';
import 'package:notion_card/views/deck_screen.dart';
import 'package:notion_card/widget_templates/dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notion_card/repoModels/user.dart' as model;

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  late model.User user;
  bool _isLoading = true;
  final double _showLeftWidthThreshold = 720;
  final double _showLeftHeightThreshold = 550;
  final double _showLoginWidthThreshold = 300;
  late Image image = Image.network(
    NetworkImageConstants.loginBackgroundDinoUrl, // Replace with your image URL
  );

  @override
  initState() {
    super.initState();
    _loadImage();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

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
        model.User user = model.User(
            uid: uid,
            creationTimestamp: Timestamp.now(),
            name: _nameController.text);
        model.User.createUser(user);
        setState(() {
          this.user = user;
          _goDecks();
        });
      }
    } catch (e) {
      log(e.toString());
      _showRegistrationFailDialog();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  _loadImage() async {
    Image imageLoad = Image.network(
      NetworkImageConstants
          .loginBackgroundDinoUrl, // Replace with your image URL
    );
    setState(() {
      image = imageLoad;
      _isLoading = false;
    });
  }

  _goDecks() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DecksScreen(
          user: user,
        ),
      ),
    );
  }

  _showRegistrationFailDialog() {
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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (screenWidth > _showLeftWidthThreshold &&
              screenHeight > _showLeftHeightThreshold)
            DescriptionPanel(image: image),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Center(
                child: SizedBox(
                  width: 500,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Register',
                        style: TextStyle(
                          color: Color(0xFF755DC1),
                          fontSize: 27,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 50),
                      TextField(
                        controller: _emailController,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF393939),
                          fontSize: 13,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(
                            color: Color(0xFF755DC1),
                            fontSize: 15,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(
                              width: 1,
                              color: Color(0xFF837E93),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(
                              width: 1,
                              color: Color(0xFF9F7BFF),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextField(
                        controller: _passwordController,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF393939),
                          fontSize: 13,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(
                            color: Color(0xFF755DC1),
                            fontSize: 15,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(
                              width: 1,
                              color: Color(0xFF837E93),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(
                              width: 1,
                              color: Color(0xFF9F7BFF),
                            ),
                          ),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 25),
                      TextField(
                        controller: _nameController,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF393939),
                          fontSize: 13,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          labelStyle: TextStyle(
                            color: Color(0xFF755DC1),
                            fontSize: 15,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(
                              width: 1,
                              color: Color(0xFF837E93),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(
                              width: 1,
                              color: Color(0xFF9F7BFF),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _registerWithEmailAndPassword,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF9F7BFF),
                                  ),
                                  child: const Text(
                                    'Register',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          if (screenWidth > _showLoginWidthThreshold)
                            const Text(
                              'Already have an account?',
                              style: TextStyle(
                                color: Color(0xFF837E93),
                                fontSize: 13,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          const SizedBox(width: 2.5),
                          InkWell(
                            onTap: _goLogin,
                            child: const Text(
                              'Log In',
                              style: TextStyle(
                                color: Color(0xFF755DC1),
                                fontSize: 13,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
