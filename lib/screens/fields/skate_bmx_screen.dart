import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:move_young/services/overpass_service.dart';
import 'package:move_young/screens/maps/generic_map_screen.dart';

class SkateBmxScreen extends StatefulWidget {
  const SkateBmxScreen({super.key});

  @override
  State<SkateBmxScreen> createState() => _SkateBmxScreenState();
}

class _SkateBmxScreenState extends State<SkateBmxScreen> {
  List<Map<String, dynamic>> _allFields = [];
  List<Map<String, dynamic>> _filteredFields = [];
  bool _isLoading = true;
  String? _error;
  Position? _userPosition;

  bool _onlySkateboarding = false;
  bool _onlyBmx = false;

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

      final all = await OverpassService.fetchMultipleFields(
        areaName: "'s-Hertogenbosch",
        sportTypes: ["skateboard", "bmx"],
      );

      for (var field in all) {
        final lat = field['lat'];
        final lon = field['lon'];
        final tags = field['tags'] ?? {};

        field['sport'] = tags['sport'] ?? 'unknown';

        if (field['name'] == null || field['name'].toString().trim().isEmpty) {
          field['name'] = '${lat.toStringAsFixed(5)}, ${lon.toStringAsFixed(5)}';
        }

        field['distance'] = _calculateDistance(lat, lon);
      }

      all.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

      setState(() {
        _allFields = all;
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
      final sport = (field['sport'] ?? '').toLowerCase();
      final name = (field['name'] ?? '').toLowerCase();
      final address = (field['addr:street'] ?? '').toLowerCase();

      if (_onlySkateboarding && sport != 'skateboard') return false;
      if (_onlyBmx && sport != 'bmx') return false;

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
    final message = "Meet me at $name! 🛹 https://maps.google.com/?q=$lat,$lon";
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
            hintText: 'Search spots...',
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
            icon: Icon(_onlySkateboarding ? Icons.directions_run : Icons.directions_run_outlined),
            tooltip: "Toggle Skateboard",
            onPressed: () {
              setState(() {
                _onlySkateboarding = !_onlySkateboarding;
                _applyFilters();
              });
            },
          ),
          IconButton(
            icon: Icon(_onlyBmx ? Icons.pedal_bike : Icons.pedal_bike_outlined),
            tooltip: "Toggle BMX",
            onPressed: () {
              setState(() {
                _onlyBmx = !_onlyBmx;
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
                    final sport = (field['sport'] ?? 'unknown').toString();

                    IconData icon;
                    Color iconColor;

                    switch (sport) {
                      case 'skateboard':
                        icon = Icons.directions_run;
                        iconColor = Colors.orange;
                        break;
                      case 'bmx':
                        icon = Icons.pedal_bike;
                        iconColor = Colors.green;
                        break;
                      default:
                        icon = Icons.place;
                        iconColor = Colors.grey;
                    }

                    return ListTile(
                      title: Text(name),
                      subtitle: Text('${_formatDistance(distance)} • ${sport.replaceAll("_", " ")}'),
                      leading: Icon(icon, color: iconColor),
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
                title: 'Skateboard & BMX',
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
