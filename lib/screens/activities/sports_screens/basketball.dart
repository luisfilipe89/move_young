import 'package:flutter/material.dart';
import 'package:move_young/screens/activities/sports_screens/generic_sport_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class BasketballScreen extends StatelessWidget {
  const BasketballScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GenericSportScreen(
      title: 'basketball_courts'.tr(),
      sportType: 'basketball',
    );
  }
}

class BasketballDisplay {
  static const Map<String, IconData> tagIcons = {
    'surface': Icons.park,
    'artificial_turf': Icons.sports_basketball,
    'lit': Icons.lightbulb,
  };
}
