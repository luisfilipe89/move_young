import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class LiveFootballFieldScreen extends StatefulWidget {
  const LiveFootballFieldScreen({super.key});

  @override
  State<LiveFootballFieldScreen> createState() => _LiveFootballFieldScreenState();
}

class _LiveFootballFieldScreenState extends State<LiveFootballFieldScreen> {
  List<Map<String, String>> _fields = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    fetchFootballFields();
  }

  Future<void> fetchFootballFields() async {
    const overpassUrl = "https://overpass-api.de/api/interpreter";
    const query = """
    [out:json][timeout:25];
    area["name"="'s-Hertogenbosch"]->.searchArea;
    (
      node["leisure"="pitch"]["sport"="soccer"]["access"!="private"](area.searchArea);
      way["leisure"="pitch"]["sport"="soccer"]["access"!="private"](area.searchArea);
    );
    out center tags;
    """;

    try {
      final response = await http.post(
        Uri.parse(overpassUrl),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {'data': query},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final elements = jsonData['elements'] as List<dynamic>;

        setState(() {
          _fields = elements.map<Map<String, String>>((element) {
            final tags = element['tags'] ?? {};
            final name = tags['name'] ?? 'Unnamed Field';
            final lat = element['lat'] ?? element['center']?['lat'];
            final lon = element['lon'] ?? element['center']?['lon'];
            return {
              'name': name,
              'lat': lat.toString(),
              'lon': lon.toString(),
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load data. Server error.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error fetching data: $e';
        _isLoading = false;
      });
    }
  }

  void _openDirections(String lat, String lon) async {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lon&travelmode=walking';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Google Maps')),
      );
    }
  }

  void _shareLocation(String name, String lat, String lon) {
    final message = "Meet me at $name! 📍 https://maps.google.com/?q=$lat,$lon";
    Share.share(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Live Football Fields")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView.builder(
                  itemCount: _fields.length,
                  itemBuilder: (context, index) {
                    final field = _fields[index];
                    return ListTile(
                      title: Text(field['name']!),
                      subtitle: Text('${field['lat']}, ${field['lon']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.share),
                            onPressed: () => _shareLocation(
                                field['name']!, field['lat']!, field['lon']!),
                          ),
                          IconButton(
                            icon: const Icon(Icons.directions),
                            onPressed: () => _openDirections(
                                field['lat']!, field['lon']!),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
