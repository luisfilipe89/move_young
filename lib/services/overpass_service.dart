import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OverpassService {
  static const _cacheDuration = Duration(hours: 6);

  static Future<List<Map<String, dynamic>>> fetchFields({
    required String areaName,
    required String sportType,
  }) async {
    final cacheKey = 'fields_${areaName}_$sportType';
    final cached = await _getCachedData(cacheKey);
    if (cached != null) return cached;

    final query = """
    [out:json][timeout:25];
    area["name"="$areaName"]->.searchArea;
    (
      node["leisure"="pitch"]["sport"="$sportType"]["access"!="private"](area.searchArea);
      way["leisure"="pitch"]["sport"="$sportType"]["access"!="private"](area.searchArea);
    );
    out center tags;
    """;

    final response = await http.post(
      Uri.parse('https://overpass-api.de/api/interpreter'),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {'data': query},
    );

    if (response.statusCode != 200) {
      throw Exception('Overpass API error: ${response.statusCode}');
    }

    final parsed = _parseOverpassData(response.body);
    await _cacheData(cacheKey, parsed);
    return parsed;
  }

  static Future<List<Map<String, dynamic>>> fetchFitnessStations({
    required String areaName,
  }) async {
    final cacheKey = 'fitness_${areaName}';
    final cached = await _getCachedData(cacheKey);
    if (cached != null) return cached;

    final query = """
    [out:json][timeout:25];
    area["name"="$areaName"]->.searchArea;
    (
      node["leisure"="fitness_station"]["access"!="private"](area.searchArea);
      way["leisure"="fitness_station"]["access"!="private"](area.searchArea);
    );
    out center tags;
    """;

    final response = await http.post(
      Uri.parse('https://overpass-api.de/api/interpreter'),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {'data': query},
    );

    if (response.statusCode != 200) {
      throw Exception('Overpass API error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    final elements = data['elements'] as List<dynamic>;

    final parsed = elements.map<Map<String, dynamic>>((element) {
      final tags = element['tags'] ?? {};
      return {
        'name': tags['name'] ?? 'Unnamed Station',
        'lat': element['lat'] ?? element['center']?['lat'],
        'lon': element['lon'] ?? element['center']?['lon'],
        'equipment': tags['equipment'],
        'outdoor': tags['outdoor'],
        'tags': tags,
      };
    }).where((e) => e['lat'] != null && e['lon'] != null).toList();

    await _cacheData(cacheKey, parsed);
    return parsed;
  }

  static Future<List<Map<String, dynamic>>> fetchMultipleFields({
    required String areaName,
    required List<String> sportTypes,
  }) async {
    final cacheKey = 'multi_${areaName}_${sportTypes.join("_")}';
    final cached = await _getCachedData(cacheKey);
    if (cached != null) return cached;

    final sportFilters = sportTypes.map((sport) {
      return '''
      node["leisure"="pitch"]["sport"="$sport"]["access"!="private"](area.searchArea);
      way["leisure"="pitch"]["sport"="$sport"]["access"!="private"](area.searchArea);
      ''';
    }).join();

    final query = """
    [out:json][timeout:25];
    area["name"="$areaName"]->.searchArea;
    (
      $sportFilters
    );
    out center tags;
    """;

    final response = await http.post(
      Uri.parse('https://overpass-api.de/api/interpreter'),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {'data': query},
    );

    if (response.statusCode != 200) {
      throw Exception('Overpass API error: ${response.statusCode}');
    }

    final parsed = _parseOverpassData(response.body);
    await _cacheData(cacheKey, parsed);
    return parsed;
  }

  static List<Map<String, dynamic>> _parseOverpassData(String responseBody) {
    final data = jsonDecode(responseBody);
    final elements = data['elements'] as List<dynamic>;

    return elements.map<Map<String, dynamic>>((element) {
      final tags = element['tags'] ?? {};
      return {
        'name': tags['name'] ?? 'Unnamed Field',
        'lat': element['lat'] ?? element['center']?['lat'],
        'lon': element['lon'] ?? element['center']?['lon'],
        'surface': tags['surface'],
        'lit': tags['lit'],
        'tags': tags,
      };
    }).where((e) => e['lat'] != null && e['lon'] != null).toList();
  }

  static Future<void> _cacheData(String key, List<Map<String, dynamic>> data) async {
    final prefs = await SharedPreferences.getInstance();
    final entry = {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'expiry': DateTime.now().add(_cacheDuration).millisecondsSinceEpoch,
      'data': data,
    };
    prefs.setString(key, jsonEncode(entry));
  }

  static Future<List<Map<String, dynamic>>?> _getCachedData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(key);
    if (jsonString == null) return null;

    final Map<String, dynamic> json = jsonDecode(jsonString);
    final now = DateTime.now().millisecondsSinceEpoch;
    if (json['expiry'] < now) return null;

    final List<dynamic> rawData = json['data'];
    return rawData.map<Map<String, dynamic>>((item) {
      return {
        ...item,
        'lat': item['lat'] is double ? item['lat'] : double.tryParse(item['lat'].toString()),
        'lon': item['lon'] is double ? item['lon'] : double.tryParse(item['lon'].toString()),
      };
    }).where((e) => e['lat'] != null && e['lon'] != null).toList();
  }
}
