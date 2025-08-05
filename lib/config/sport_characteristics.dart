import 'package:easy_localization/easy_localization.dart';

class SportCharacteristics {
  // Which characteristics each sport uses
  static const Map<String, List<String>> registry = {
    'soccer': ['surface', 'lit'],
    'basketball': ['surface', 'lit', 'hoops'],
    'table_tennis': ['indoor', 'covered'],
    'skateboard': ['surface'],
    'fitness': ['equipment'],
  };

  // The possible values for each characteristic per sport
  static const Map<String, Map<String, List<String>>> values = {
    'soccer': {
      'surface': ['grass', 'artificial_turf'],
    },
    'basketball': {
      'surface': ['asphalt', 'concrete', 'plastic'],
    },
    'skateboard': {
      'surface': ['concrete', 'wood'],
    },
    'table_tennis': {},
    'fitness': {},
    // Add more sports here as needed
  };

  static const Map<String, String> surfaceLabels = {
    'grass': 'grass',
    'artificial_turf': 'artificial_turf',
    'asphalt': 'asphalt',
    'concrete': 'concrete',
    'plastic': 'plastic',
    'wood': 'wood',
  };

  static const Map<String, String> litLabels = {
    'yes': 'lit',
    'no': 'not_lit',
  };

  static List<String> get(String sportType) {
    return registry[sportType] ?? [];
  }

  static List<String> getValues(String sportType, String key) {
    return values[sportType]?[key] ?? [];
  }

  static String getLabel(String key, Map<String, String> labels) {
    final translationKey = labels[key] ?? 'unknown';
    return translationKey.tr();
  }
}
