import 'dart:convert';
import 'package:http/http.dart' as http;

class OverpassService {
  static Future<List<Map<String, dynamic>>> fetchFields({
    required String areaName,
    required String sportType,
  }) async {
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

    final data = jsonDecode(response.body);
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
}
