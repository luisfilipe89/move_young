import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

class LiveFootballFieldScreen extends StatefulWidget {
  const LiveFootballFieldScreen({super.key});

  @override
  State<LiveFootballFieldScreen> createState() => _LiveFootballFieldScreenState();
}

class _LiveFootballFieldScreenState extends State<LiveFootballFieldScreen> {
  List<Map<String, dynamic>> _allFields = [];
  List<Map<String, dynamic>> _filteredFields = [];
  bool _isLoading = true;
  String? _error;
  Position? _userPosition;

  // Filter states
  bool _onlyGrass = false;
  bool _onlyLit = false;
  bool _onlyArtificialTurf = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await Geolocator.requestPermission();
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      _userPosition = position;
      await fetchFootballFields();
    } catch (e) {
      setState(() {
        _error = 'Could not get user location: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> fetchFootballFields() async {
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
        Uri.parse("https://overpass-api.de/api/interpreter"),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {'data': query},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final elements = jsonData['elements'] as List<dynamic>;

        final fields = elements.map<Map<String, dynamic>>((element) {
          final tags = element['tags'] ?? {};
          final name = tags['name'] ?? 'Unnamed Field';
          final surface = tags['surface'];
          final lit = tags['lit'];
          final lat = element['lat'] ?? element['center']?['lat'];
          final lon = element['lon'] ?? element['center']?['lon'];
          final distance = _calculateDistance(lat, lon);

          return {
            'name': name,
            'lat': lat.toString(),
            'lon': lon.toString(),
            'distance': distance,
            'surface': surface,
            'lit': lit,
          };
        }).toList();

        fields.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

        setState(() {
          _allFields = fields;
          _applyFilters();
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

  void _applyFilters() {
    _filteredFields = _allFields.where((field) {
      final surface = field['surface']?.toLowerCase();
      final isGrass = surface == 'grass';
      final isArtificial = surface != null && surface.contains('artificial');
      final isLit = field['lit'] == 'yes';

      if (_onlyGrass && !isGrass) return false;
      if (_onlyArtificialTurf && !isArtificial) return false;
      if (_onlyLit && !isLit) return false;
      return true;
    }).toList();
  }

  double _calculateDistance(double? lat, double? lon) {
    if (_userPosition == null || lat == null || lon == null) return double.infinity;
    return Geolocator.distanceBetween(
      _userPosition!.latitude,
      _userPosition!.longitude,
      lat,
      lon,
    );
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

  String _formatDistance(double distance) {
    return distance < 1000
        ? '${distance.toStringAsFixed(0)} m away'
        : '${(distance / 1000).toStringAsFixed(1)} km away';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Football Fields"),
        actions: [
          IconButton(
            icon: Icon(_onlyGrass ? Icons.grass : Icons.grass_outlined),
            tooltip: "Toggle Grass",
            onPressed: () {
              setState(() {
                _onlyGrass = !_onlyGrass;
                _applyFilters();
              });
            },
          ),
          IconButton(
            icon: Icon(_onlyArtificialTurf ? Icons.extension : Icons.extension_outlined),
            tooltip: "Toggle Artificial Turf",
            onPressed: () {
              setState(() {
                _onlyArtificialTurf = !_onlyArtificialTurf;
                _applyFilters();
              });
            },
          ),
          IconButton(
            icon: Icon(_onlyLit ? Icons.lightbulb : Icons.lightbulb_outline),
            tooltip: "Toggle Lit Fields",
            onPressed: () {
              setState(() {
                _onlyLit = !_onlyLit;
                _applyFilters();
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView.builder(
                  itemCount: _filteredFields.length,
                  itemBuilder: (context, index) {
                    final field = _filteredFields[index];
                    final name = field['name'];
                    final lat = field['lat']!;
                    final lon = field['lon']!;
                    final distance = field['distance'] as double;
                    final surface = field['surface'] ?? 'Unknown';
                    final lit = field['lit'] == 'yes';
                    final distanceStr = _formatDistance(distance);

                    final surfaceLower = surface.toLowerCase();

                    Icon surfaceIcon;
                    if (surfaceLower == 'grass') {
                      surfaceIcon = const Icon(Icons.grass, size: 16, color: Colors.green);
                    } else if (surfaceLower.contains('artificial')) {
                      surfaceIcon = const Icon(Icons.extension, size: 16, color: Colors.green);
                    } else {
                      surfaceIcon = const Icon(Icons.sports_soccer, size: 16, color: Colors.lightBlueAccent);
                    }

                    return ListTile(
                      title: Text(name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(distanceStr),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              surfaceIcon,
                              const SizedBox(width: 4),
                              Text(surface),
                              const SizedBox(width: 12),
                              Icon(
                                lit ? Icons.lightbulb : Icons.lightbulb_outline,
                                size: 16,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(lit ? 'Lit' : 'Unlit'),
                            ],
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.share),
                            onPressed: () => _shareLocation(name, lat, lon),
                          ),
                          IconButton(
                            icon: const Icon(Icons.directions),
                            onPressed: () => _openDirections(lat, lon),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
