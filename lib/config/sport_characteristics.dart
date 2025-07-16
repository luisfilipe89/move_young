class SportCharacteristics {
  static Map<String, List<String>> registry = {
    'soccer': ['surface', 'lit'],
    'basketball': ['surface', 'lit', 'basket'],
    'skateboard': ['surface'],
    'fitness': ['equipment'],
    'table_tennis': ['covered'],
    // etc.
  };

  static List<String> get(String sportType) {
    return registry[sportType] ?? [];
  }
}
