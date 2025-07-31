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
    'table_tennis':{},
    'fitness':{},
    // Add more sports here as needed
  };

  static const Map<String, String> surfaceLabels = {
    'grass': 'Grass',
    'artificial_turf': 'Artificial',
    'asphalt': 'Asphalt',
    'concrete': 'Concrete',
    'plastic': 'Plastic',
    'wood': 'Wood',
  };

  static List<String> get(String sportType) {
    return registry[sportType] ?? [];
  }

  static List<String> getValues(String sportType, String key) {
    return values[sportType]?[key] ?? [];
  }

  static String getLabel(String key, Map<String, String> labels) {
    return labels[key] ?? key.replaceAll('_', ' ').capitalize();
  }
}

extension StringCasingExtension on String {
  String capitalize() {
    return split(' ')
        .map((word) =>
            word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
        .join(' ');
  }
}

