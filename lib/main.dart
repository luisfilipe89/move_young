import 'package:flutter/material.dart';
import 'package:move_young/screens/main_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MainScaffold(), // ← ensure this is your real entry screen
    );
  }
}
