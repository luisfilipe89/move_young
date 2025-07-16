import 'package:flutter/material.dart';
import 'package:move_young/screens/menus/widgets/generic_sport_screen.dart';

class FootballFieldScreen extends StatelessWidget {
  const FootballFieldScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GenericSportScreen(
      title: 'Football Fields',
      sportType: 'soccer',
    );
  }
}
