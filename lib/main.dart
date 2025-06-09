import 'package:e_learnning/firebase_options.dart';
import 'package:e_learnning/homescreen/homescreen.dart';
import 'package:e_learnning/screens/splashscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Widget _getInitialScreen() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // User is already signed in
      return HomeScreen();
    } else {
      // User is not signed in
      return Splashscreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'e-learnning',
      home: _getInitialScreen(),
    );
  }
}
