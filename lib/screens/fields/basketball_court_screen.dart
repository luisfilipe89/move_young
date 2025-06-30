import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/overpass_service.dart';
import '../maps/generic_map_screen.dart';

class BasketballCourtScreen extends StatefulWidget {
  const BasketballCourtScreen({super.key});

  @override
  State<BasketballCourtScreen> createState() => _BasketballCourtScreenState();
}

class _BasketballCourtScreenState extends State<BasketballCourtScreen> {
  List<Map<String, dynamic>> _allCourts = [];
  List<Map<String, dynamic>> _filteredCourts = [];
  bool _isLoading = true;
  String? _error;
  Position? _userPosition;

  bool _onlyConcrete = false;
  bool _onlyLit = false;

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

      final courts = await OverpassService.fetchFields(
        areaName: "'s-Hertogenbosch",
        sportType: "basketball",
      );

      print('✅ Fetched ${courts.length} courts from Overpass');
      for (var c in courts) {
        print("📍 ${c['name']} - lat: ${c['lat']}, lon: ${c['lon']}");
      }

      for (var court in courts) {
        final lat = court['lat'];
        final lon = court['lon'];

        if (court['name'] == null || court['name'].toString().trim().isEmpty) {
          court['name'] = '${lat.toStringAsFixed(5)}, ${lon.toStringAsFixed(5)}';
        }

        court['distance'] = _calculateDistance(lat, lon);
      }

      courts.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

      setState(() {
        _allCourts = courts;
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
    print("🔍 Applying filters on ${_allCourts.length} courts");

    _filteredCourts = _allCourts.where((court) {
      final surface = (court['surface'] ?? '').toLowerCase();
      final lit = court['lit'] == 'yes';
      final name = (court['name'] ?? '').toLowerCase();
      final address = (court['addr:street'] ?? '').toLowerCase();

      if (_onlyConcrete && surface != 'concrete') return false;
      if (_onlyLit && !lit) return false;

      if (_searchQuery.isNotEmpty &&
          !name.contains(_searchQuery.toLowerCase()) &&
          !address.contains(_searchQuery.toLowerCase())) {
        return false;
      }

      return true;
    }).toList();

    print("✅ After filters: ${_filteredCourts.length} courts remain");
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
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search courts...',
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
            icon: Icon(_onlyConcrete ? Icons.stop : Icons.stop_outlined),
            tooltip: "Toggle Concrete Surface",
            onPressed: () {
              setState(() {
                _onlyConcrete = !_onlyConcrete;
                _applyFilters();
              });
            },
          ),
          IconButton(
            icon: Icon(_onlyLit ? Icons.lightbulb : Icons.lightbulb_outline),
            tooltip: "Toggle Lit Courts",
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
                  itemCount: _filteredCourts.length,
                  itemBuilder: (context, index) {
                    final court = _filteredCourts[index];
                    final name = court['name'];
                    final lat = court['lat'].toString();
                    final lon = court['lon'].toString();
                    final distance = court['distance'] as double;
                    final surface = court['surface'] ?? 'Unknown';
                    final lit = court['lit'] == 'yes';
                    final hoops = court['tags']?['hoops'] ?? 'Unknown';

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
                                surface.toLowerCase() == 'concrete'
                                    ? Icons.stop
                                    : Icons.sports_basketball,
                                size: 16,
                                color: Colors.orange,
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
                              const SizedBox(width: 12),
                              const Icon(Icons.sports_basketball, size: 16, color: Colors.orange),
                              const SizedBox(width: 4),
                              Text('$hoops hoops'),
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
          print('📤 Sending ${_filteredCourts.length} courts to map');
          for (var c in _filteredCourts) {
            print("🗺 ${c['name']} - lat: ${c['lat']}, lon: ${c['lon']}");
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GenericMapScreen(
                title: 'Basketball Courts',
                locations: _filteredCourts,
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
