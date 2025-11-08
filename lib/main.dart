import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // ✅ super.key

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Quest',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(), // check if user is logged in
      routes: {
      '/home': (context) => const HomePage(),
      '/login': (context) => const LoginPage(),
      },
    );
  }
}

// Wrapper to safely check login without using BuildContext across async gaps
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return const HomePage();
    } else {
      return const LoginPage();
    }
  }
}
