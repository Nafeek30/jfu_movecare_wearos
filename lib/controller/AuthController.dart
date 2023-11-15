import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jfu_movecare_wearos/views/HomeScreen.dart';
import 'package:jfu_movecare_wearos/views/LoginScreen.dart';

class AuthController {
  final FirebaseAuth auth = FirebaseAuth.instance;

  /// Login function using email and password. You can sign up on the phone using the move care app.
  void login(BuildContext context, String email, String password) async {
    try {
      await auth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((value) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ),
        );
      });
    } catch (error) {
      Fluttertoast.showToast(
          msg: error.toString(),
          backgroundColor: Colors.red,
          textColor: Colors.white);
    }
  }

  /// Sign out using Firebase and go to the [Login] screen
  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut().then((value) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    });
  }
}
