import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/overpass_service.dart';
import '../maps/generic_map_screen.dart';

class FitnessStationScreen extends StatefulWidget {
  const FitnessStationScreen({super.key});

  @override
  State<FitnessStationScreen> createState() => _FitnessStationScreenState();
}

class _FitnessStationScreenState extends State<FitnessStationScreen> {
  List<Map<String, dynamic>> _allStations = [];
  List<Map<String, dynamic>> _filteredStations = [];
  bool _isLoading = true;
  String? _error;
  Position? _userPosition;

  TextEditingController _searchController = TextEditingController();
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

      final stations = await OverpassService.fetchFitnessStations(
        areaName: "'s-Hertogenbosch",
      );

      for (var station in stations) {
        final lat = station['lat'];
        final lon = station['lon'];

        if (station['name'] == null || station['name'].toString().trim().isEmpty) {
          station['name'] = '${lat.toStringAsFixed(5)}, ${lon.toStringAsFixed(5)}';
        }

        station['distance'] = _calculateDistance(lat, lon);
      }

      stations.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

      setState(() {
        _allStations = stations;
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
    _filteredStations = _allStations.where((station) {
      final name = (station['name'] ?? '').toLowerCase();
      final equipment = (station['equipment'] ?? '').toLowerCase();

      if (_searchQuery.isNotEmpty &&
          !name.contains(_searchQuery.toLowerCase()) &&
          !equipment.contains(_searchQuery.toLowerCase())) {
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
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Google Maps')),
      );
    }
  }

  void _shareLocation(String name, String lat, String lon) {
    final message = "Let's work out here! 💪 $name 📍 https://maps.google.com/?q=$lat,$lon";
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
            hintText: 'Search fitness stations...',
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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: _filteredStations.length,
                  itemBuilder: (context, index) {
                    final station = _filteredStations[index];
                    final name = station['name'];
                    final lat = station['lat'].toString();
                    final lon = station['lon'].toString();
                    final distance = station['distance'] as double;
                    final equipment = station['equipment'] ?? 'General Fitness';

                    return ListTile(
                      title: Text(name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_formatDistance(distance)),
                          const SizedBox(height: 4),
                          Text('Equipment: $equipment'),
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
                title: 'Fitness Stations',
                locations: _filteredStations,
              ),
            ),
          );
        },
        child: const Icon(Icons.map),
        tooltip: 'View All on Map',
      ),
    );
  }
}
