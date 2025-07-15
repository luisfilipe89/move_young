import 'package:flutter/material.dart';
import 'screens//principals/home_screen_test.dart';

void main() {
  runApp(const MoveYoungApp());
}

class MoveYoungApp extends StatelessWidget {
  const MoveYoungApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MoveYoung',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Poppins',
      ),
      home: const HomeScreen(),
    );
  }
}
