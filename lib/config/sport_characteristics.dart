class SportCharacteristics {
  static final Map<String, List<String>> registry = {
    'soccer': ['surface', 'lit'],
    'basketball': ['surface', 'lit', 'hoops'],
    'table_tennis': ['indoor','covered'],
    'skateboard': ['surface'],
    'fitness': ['equipment']
  };

  static List<String> get(String sportType) {
    return registry[sportType] ?? [];
  }
}
