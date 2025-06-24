import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() => runApp(const MoveYoungApp());

class MoveYoungApp extends StatelessWidget {
  const MoveYoungApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoveYoung',
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
