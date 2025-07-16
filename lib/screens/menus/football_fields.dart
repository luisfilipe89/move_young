import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:move_young/services/overpass_service.dart';
import 'package:move_young/screens/maps/generic_map_screen.dart';

class FootballFieldScreen extends StatefulWidget {
  const FootballFieldScreen({super.key});

  @override
  State<FootballFieldScreen> createState() => _FootballFieldScreenState();
}

class _FootballFieldScreenState extends State<FootballFieldScreen> {
  List<Map<String, dynamic>> _allFields = [];
  List<Map<String, dynamic>> _filteredFields = [];
  bool _isLoading = true;
  String? _error;
  Position? _userPosition;

  bool _onlyGrass = false;
  bool _onlyArtificial = false;
  bool _onlyLit = false;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      await Geolocator.requestPermission();
      _userPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final fields = await OverpassService.fetchFields(
        areaName: "'s-Hertogenbosch",
        sportType: "soccer",
      );

      for (var field in fields) {
        final lat = field['lat'];
        final lon = field['lon'];

        if (field['name'] == null || field['name'].toString().trim().isEmpty) {
          field['name'] = '${lat.toStringAsFixed(5)}, ${lon.toStringAsFixed(5)}';
        }

        field['distance'] = _calculateDistance(lat, lon);
      }

      fields.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

      setState(() {
        _allFields = fields;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load data: $e';
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    _filteredFields = _allFields.where((field) {
      final surface = (field['surface'] ?? '').toLowerCase();
      final lit = field['lit'] == 'yes';
      final name = (field['name'] ?? '').toLowerCase();
      final address = (field['addr:street'] ?? '').toLowerCase();

      if (_onlyGrass && surface != 'grass') return false;
      if (_onlyArtificial && surface != 'artificial_turf') return false;
      if (_onlyLit && !lit) return false;

      if (_searchQuery.isNotEmpty &&
          !name.contains(_searchQuery.toLowerCase()) &&
          !address.contains(_searchQuery.toLowerCase())) {
        return false;
      }

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
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
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
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search fields...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
              _applyFilters();
            });
          },
        ),
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
            icon: Icon(_onlyArtificial ? Icons.extension : Icons.extension_outlined),
            tooltip: "Toggle Artificial Turf",
            onPressed: () {
              setState(() {
                _onlyArtificial = !_onlyArtificial;
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
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: _filteredFields.length,
                  itemBuilder: (context, index) {
                    final field = _filteredFields[index];
                    final name = field['name'];
                    final lat = field['lat'].toString();
                    final lon = field['lon'].toString();
                    final distance = field['distance'] as double;
                    final surface = field['surface'] ?? 'Unknown';
                    final lit = field['lit'] == 'yes';

                    return ListTile(
                      title: Text(name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_formatDistance(distance)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                surface.toLowerCase() == 'grass'
                                    ? Icons.grass
                                    : surface.toLowerCase() == 'artificial_turf'
                                        ? Icons.extension
                                        : Icons.sports_soccer,
                                size: 16,
                                color: Colors.green,
                              ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GenericMapScreen(
                title: 'Football Fields',
                locations: _filteredFields,
              ),
            ),
          );
        },
        tooltip: 'View All on Map',
        child: const Icon(Icons.map),
      ),
    );
  }
}
