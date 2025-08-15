import 'package:move_young/screens/activities/sports_screens/soccer.dart';
import 'package:move_young/screens/activities/sports_screens/basketball.dart';
import 'package:move_young/screens/activities/sports_screens/tennis.dart';
import 'package:move_young/screens/activities/sports_screens/beachvolleyball.dart';
import 'package:move_young/screens/activities/sports_screens/table_tennis.dart';
import 'package:move_young/screens/activities/sports_screens/fitness.dart';
import 'package:move_young/screens/activities/sports_screens/skateboard.dart';
import 'package:move_young/screens/activities/sports_screens/bmx.dart';

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
    //Radical
    'skateboard': SkateboardDisplay.tagIcons,
    'bmx': BmxDisplay.tagIcons
  };

  static Map<String, List<dynamic>> getIconMap(String sportType) {
    return _iconMapRegistry[sportType] ?? {};
  }
}
