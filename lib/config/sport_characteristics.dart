class SportCharacteristics {
  // Which characteristics each sport uses
  static final Map<String, List<String>> registry = {
    'soccer': ['surface', 'lit'],
    'basketball': ['surface', 'lit', 'hoops'],
    'table_tennis': ['indoor', 'covered'],
    'skateboard': ['surface'],
    'fitness': ['equipment'],
  };

  // The possible values for each characteristic per sport
  static final Map<String, Map<String, List<String>>> values = {
    'soccer': {
      'surface': ['grass', 'artificial_turf'],
    },
    'basketball': {
      'surface': ['asphalt', 'concrete', 'plastic'],
    },
    'skateboard': {
      'surface': ['concrete', 'wood'],
    },
    // Add more sports here as needed
  };

  static final Map<String, String> surfaceLabels = {
    'grass': 'Grass',
    'artifical_turf': 'Artificial',
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

  static String getSurfaceLabel(String surfaceKey) {
    return surfaceLabels[surfaceKey] ??
        surfaceKey.replaceAll('_', ' ').capitalize();
  }
}

extension StringCasingExtension on String {
  String capitalize() =>
      isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : '';
}

