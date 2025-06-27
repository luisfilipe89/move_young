import 'dart:convert';
import 'package:http/http.dart' as http;

class OverpassService {
  static Future<List<Map<String, dynamic>>> fetchSoccerFields() async {
    final query = """
      [out:json][timeout:25];
      area["name"="'s-Hertogenbosch"]->.searchArea;
      (
        node["leisure"="pitch"]["sport"="soccer"](area.searchArea);
        way["leisure"="pitch"]["sport"="soccer"](area.searchArea);
      );
      out center tags;
    """;

    final response = await http.post(
      Uri.parse('https://overpass-api.de/api/interpreter'),
      body: {'data': query},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final elements = data['elements'] as List<dynamic>;

      return elements.map<Map<String, dynamic>>((e) {
        final tags = e['tags'] ?? {};
        final name = _getDisplayName(tags);

        return {
          'id': e['id'],
          'lat': e['lat'] ?? e['center']?['lat'],
          'lon': e['lon'] ?? e['center']?['lon'],
          'name': name,
          'tags': tags,
        };
      }).toList();
    } else {
      throw Exception('Failed to fetch soccer fields');
    }
  }

  static String _g_