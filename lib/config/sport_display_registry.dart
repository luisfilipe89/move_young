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
import 'package:move_young/screens/activities/sports_screens/motocross.dart';

class SportDisplayRegistry {
  static final Map<String, Map<String, List<dynamic>>> _iconMapRegistry = {
    //Grouped
    'soccer': SoccerDisplay.tagIcons,
    'basketball': BasketballDisplay.tagIcons,
    'tennis': TennisDisplay.tagIcons,
    'beachvolleyball': BeachVolleyBallDisplay.tagIcons,
    'table_tennis': TableTennisDisplay.tagIcons,
    //Not so Grouped
    'fitness': FitnessDisplay.tagIcons,
    'climbing': ClimbingDisplay.tagIcons,
    'canoeing': CanoingDisplay.tagIcons,
    //Radical
    'skateboard': SkateboardDisplay.tagIcons,
    'bmx': BmxDisplay.tagIcons,
    'motocross': MotocrossDisplay.tagIcons
  };

  static Map<String, List<dynamic>> getIconMap(String sportType) {
    return _iconMapRegistry[sportType] ?? {};
  }
}
