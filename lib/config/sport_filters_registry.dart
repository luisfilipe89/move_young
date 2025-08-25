//How to render filters
import 'package:flutter/material.dart';
import 'package:move_young/config/sport_characteristics_registry.dart';

enum FilterType { toggle, choice }

class ChoiceOption {
  final String value;
  final String label;
  final Color? accentColor;
  const ChoiceOption({required this.value, required this.label, this.accentColor});
}

class FilterDefinition {
  final String key;
  final FilterType type;
  final List<ChoiceOption> options;
  final Color? accentColor;


  const FilterDefinition({
    required this.key,
    required this.type,
    this.options = const [],
    this.accentColor,
  });
}

class SportFiltersRegistry {
  static const Set<String> _toggleKeys = {'lit'};
  
  static Color? _filterAccent(String sportType, String key) {
    // Example: generic defaults per filter (used as fallback when option lacks accent)
    if (key == 'surface') return Colors.green;
    if (key == 'lit') return Colors.amber;
    return null;
  }

  static Color? _optionAccent(String sportType, String key, String value) {
    // Example: fine-grained accents for specific option values
    if (key == 'surface') {
      if (value == 'grass') return Colors.green;
      if (value == 'artificial_turf') return Colors.green.shade700;
    }
    return null;
  }

  static List<FilterDefinition> buildForSport(String sportType) {
    final attrs = SportCharacteristics.get(sportType);
    if (attrs.isEmpty) return const [];

    return attrs.map((key) {
      if (_toggleKeys.contains(key)) {
        return FilterDefinition(key: key, type: FilterType.toggle,accentColor: _filterAccent(sportType, key),);
      }

      final rawValues = SportCharacteristics.getValues(sportType, key);
      final opts = rawValues.map((v) {
        final label = SportCharacteristics.labelFor(key, v);
        return ChoiceOption(value: v, label: label,accentColor: _optionAccent(sportType, key, v),);
      }).toList();

      return FilterDefinition(
        key: key,
        type: FilterType.choice,
        options: opts,
        accentColor: _filterAccent(sportType, key),
      );
    }).toList();
  }
}

class FilterSelection {
  final Map<String, String?> choiceSelections;
  final Map<String, bool> toggles;

  FilterSelection({
    Map<String, String?>? choiceSelections,
    Map<String, bool>? toggles,
  })  : choiceSelections = choiceSelections ?? {},
        toggles = toggles ?? {};

  FilterSelection copyWith({
    Map<String, String?>? choiceSelections,
    Map<String, bool>? toggles,
  }) {
    return FilterSelection(
      choiceSelections: choiceSelections ?? this.choiceSelections,
      toggles: toggles ?? this.toggles,
    );
  }
}

bool matchesFilters({
  required String sportType,
  required Map<String, dynamic> location,
  required FilterSelection selection,
}) {
  final tags = (location['tags'] ?? {}) as Map<String, dynamic>;
  final attrs = SportCharacteristics.get(sportType);

  for (final key in attrs) {
    if (selection.toggles[key] == true) {
      if (key == 'lit') {
        final v = (tags['lit'] ?? '').toString();
        if (v != 'yes') return false;
      }
      continue;
    }

    final selected = selection.choiceSelections[key];
    if (selected != null && selected.isNotEmpty) {
      final tagVal = (tags[key] ?? '').toString();
      if (tagVal != selected) return false;
    }
  }

  return true;
}
