import 'package:move_young/screens/activities/sport_types/football_fields.dart';
import 'package:move_young/screens/activities/sport_types/basketball_courts.dart';
import 'package:move_young/screens/activities/sport_types/table_tennis.dart';
import 'package:easy_localization/easy_localization.dart';

class SportDisplayRegistry {
  static final Map<String, Map<String, List<dynamic>>> _iconMapRegistry = {
    'soccer': FootballFieldDisplay.tagIcons,
    'basketball': BasketballFieldDisplay.tagIcons,
    'table_tennis': TableTennisDisplay.tagIcons,
  };

  static final Map<String, String Function(String, String?)>
      _formatterRegistry = {
    'soccer': FootballFieldDisplay.formatValue,
    'basketball': BasketballFieldDisplay.formatValue,
    'table_tennis': TableTennisDisplay.formatValue,
  };

  static Map<String, List<dynamic>> getIconMap(String sportType) {
    return _iconMapRegistry[sportType] ?? {};
  }

  static String Function(String, String?) getFormatter(String sportType) {
    return _formatterRegistry[sportType] ??
        (key, value) => (value ?? 'unknown').tr();
  }
}
