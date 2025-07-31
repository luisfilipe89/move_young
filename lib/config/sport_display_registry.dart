import 'package:flutter/material.dart';
import 'package:move_young/screens/activities/sport_types/football_fields.dart';
import 'package:move_young/screens/activities/sport_types/basketball_courts.dart';
import 'package:move_young/screens/activities/sport_types/table_tennis.dart';

class SportDisplayRegistry {
  static final Map<String, TagIconConfig> _iconMapRegistry = {
    'soccer': FootballFieldDisplay.tagIcons,
    'basketball': BasketballFieldDisplay.tagIcons,
    'table_tennis': TableTennisDisplay.tagIcons,
  };

  static final Map<String, TagFormatter> _formatterRegistry = {
    'soccer': FootballFieldDisplay.formatValue,
    'basketball': BasketballFieldDisplay.formatValue,
    'table_tennis': TableTennisDisplay.formatValue,
  };

  static TagIconConfig getIconMap(String sportType) {
    return _iconMapRegistry[sportType] ?? {};
  }

  static TagFormatter getFormatter(String sportType) {
    return _formatterRegistry[sportType] ?? (key, value) => value ?? 'Unknown';
  }
}
