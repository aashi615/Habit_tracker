import 'package:flutter/material.dart';
import 'package:habit_tracker/views/welcome_page.dart';
import 'package:habit_tracker/views/Splash_Page.dart'; // Add this line
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Habitué',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(), // Set splash screen as the initial screen
      routes: {
        '/welcome': (context) => WelcomeScreen(),
      },
    );
  }
}
