import 'package:easy_localization/easy_localization.dart';

//Declares which attributes (filters/labels) each sport uses

class SportCharacteristics {
  static const Map<String, List<String>> registry = {
    //Grouped
    'soccer': ['surface', 'lit'],
    'basketball': ['surface', 'lit', 'hoops'],
    'tennis': ['surface', 'lit'], //to confirm these are free and public
    'beachvolleyball': ['surface', 'lit'],
    'table_tennis': ['indoor', 'covered'],
    //Not so grouped

    //Radical
    'skateboard': ['surface'],
    'fitness': ['equipment'],
  };

  //Raw OSM values
  static const Map<String, Map<String, List<String>>> values = {
    //Grouped
    'soccer': {
      'surface': ['grass', 'artificial_turf']
    },
    'basketball': {
      'surface': ['asphalt', 'concrete', 'plastic']
    },
    'tennis': {},
    'beachvolleyball': {
      'surface': ['sand']
    },
    'table_tennis': {},
    //Not so grouped
    'fitness': {},
    //Radical
    'skateboard': {
      'surface': ['concrete', 'wood']
    },
    'bmx': {},
  };

  static const Map<String, String> surfaceLabels = {
    'grass': 'grass',
    'artificial_turf': 'artificial_turf',
    'asphalt': 'asphalt',
    'concrete': 'concrete',
    'plastic': 'plastic',
    'wood': 'wood',
    'sand': 'sand'
  };

  static const Map<String, String> litLabels = {
    'yes': 'lit',
    'no': 'not_lit',
  };

  static List<String> get(String sportType) => registry[sportType] ?? [];
  static List<String> getValues(String sportType, String key) =>
      values[sportType]?[key] ?? [];

  static String labelFor(String key, String? value) {
    if (value == null || value.isEmpty) return 'unknown'.tr();
    if (key == 'surface') {
      final tKey = surfaceLabels[value] ?? 'unknown';
      return tKey.tr();
    }
    if (key == 'lit') {
      final tKey = litLabels[value] ?? 'unknown';
      return tKey.tr();
    }

    return value.tr();
  }
}
