import 'package:flutter/material.dart';
import 'package:move_young/screens/activities/sport_types/football_fields.dart';
import 'package:move_young/screens/activities/sport_types/basketball_courts.dart';
import 'package:move_young/screens/activities/sport_types/table_tennis.dart';


typedef TagIconConfig = Map<String, (IconData, Color)>;
typedef TagFormatter = String Function(String key, String? value);

class SportDisplayRegistry {
  static TagIconConfig getIconMap(String sportType) {
    switch (sportType) {
      case 'soccer':
        return FootballFieldDisplay.tagIcons;
      case 'basketball':
        return BasketballFieldDisplay.tagIcons;
      case 'table_tennis':
        return TableTennisDisplay.tagIcons;
      default:
        return {};
    }
  }

  static TagFormatter getFormatter(String sportType) {
    switch (sportType) {
      case 'soccer':
        return FootballFieldDisplay.formatValue;
      case 'basketball':
        return BasketballFieldDisplay.formatValue;
      case 'table_tennis':
        return TableTennisDisplay.formatValue;
      default:
        return (key, value) => value ?? 'Unknown';
    }
  }
}
