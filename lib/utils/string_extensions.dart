// lib/utils/string_extensions.dart
extension StringCasing on String {
  String capitalize() {
    if (isEmpty) return this;
    return split(' ')
        .map((word) =>
            word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '')
        .join(' ');
  }
}
