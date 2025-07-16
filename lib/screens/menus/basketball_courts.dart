import 'package:flutter/material.dart';
import 'package:move_young/screens/menus/widgets/generic_sport_screen.dart';

class BasketballCourtsScreen extends StatelessWidget {
  const BasketballCourtsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GenericSportScreen(
      title: 'Basketball Courts',
      sportType: 'basketball',
    );
  }
}
