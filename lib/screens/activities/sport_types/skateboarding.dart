import 'package:flutter/material.dart';
import 'package:move_young/screens/activities/sport_types/generic_sport_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class SkateboardingScreen extends StatelessWidget {
  const SkateboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GenericSportScreen(
      title: 'skateboarding_parks'.tr(),
      sportType: 'skateboard',
    );
  }
}
