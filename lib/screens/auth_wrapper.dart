import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Decides if you go to login page or home screen
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return const HomeScreen(); // You're logged in, go to home
    } else {
      return const LoginPage(); // Not logged in, show login
    }
  }
}