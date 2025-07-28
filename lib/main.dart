import 'package:flutter/material.dart';
import 'package:move_young/screens/mains/home_screen_new.dart';

void main() {
  runApp(const MoveYoungApp());
}

class MoveYoungApp extends StatelessWidget {
  const MoveYoungApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('🚀 MoveYoungApp is running');
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreenNew(),
    );
  }
}
