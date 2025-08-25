//Define which icons to show

import 'package:flutter/material.dart';
import 'package:move_young/screens/activities/sports_screens/soccer.dart';
import 'package:move_young/screens/activities/sports_screens/basketball.dart';
import 'package:move_young/screens/activities/sports_screens/tennis.dart';
import 'package:move_young/screens/activities/sports_screens/beachvolleyball.dart';
import 'package:move_young/screens/activities/sports_screens/table_tennis.dart';
import 'package:move_young/screens/activities/sports_screens/fitness.dart';
import 'package:move_young/screens/activities/sports_screens/climbing.dart';
import 'package:move_young/screens/activities/sports_screens/canoeing.dart';
import 'package:move_young/screens/activities/sports_screens/skateboard.dart';
import 'package:move_young/screens/activities/sports_screens/bmx.dart';

class SportDisplayRegistry {
  // Build once; no getters that reconstruct by calling back into sports.
  static const Map<String, Map<String, IconData>> _iconMaps = {
    'soccer': SoccerDisplay.tagIcons,
    'basketball': BasketballDisplay.tagIcons,
    'tennis': TennisDisplay.tagIcons,
    'beachvolleyball': BeachVolleyBallDisplay.tagIcons,
    'table_tennis': TableTennisDisplay.tagIcons,
    //Individual
    'fitness': FitnessDisplay.tagIcons,
    'climbing': ClimbingDisplay.tagIcons,
    'canoeing': CanoingDisplay.tagIcons,
    //Intensive
    'skateboard': SkateboardDisplay.tagIcons,
    'bmx': BmxDisplay.tagIcons,
  };

  static Map<String, IconData> getIconMap(String sport) =>
      _iconMaps[sport] ?? const {};
      
  static IconData? iconFor(String sport, String key, [String? value]) {
    final composed =
        value != null ? '${key}_$value' : key; // e.g. surface_grass
    return _iconMaps[sport]?[composed];
  }
}
