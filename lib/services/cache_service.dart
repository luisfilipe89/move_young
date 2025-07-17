import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const _cacheKeyPrefix = 'overpass_cache_';

  static Future<void> save(String key, List<Map<String, dynamic>> data) async {
    final prefs = await SharedPreferences.getInstance();
    final encodedData = jsonEncode(data);
    await prefs.setString(_cacheKeyPrefix + key, encodedData);
  }

  static Future<List<Map<String, dynamic>>?> load(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_cacheKeyPrefix + key);
    if (jsonString == null) return null;
    final List<dynamic> decoded = jsonDecode(jsonString);
    return decoded.cast<Map<String, dynamic>>();
  }

  static Future<void> clear(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKeyPrefix + key);
  }
}
