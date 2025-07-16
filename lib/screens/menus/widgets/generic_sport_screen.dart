import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:move_young/services/overpass_service.dart';
import 'package:move_young/utils/reverse_geocoding.dart';
import 'package:move_young/screens/maps/generic_map_screen.dart';
import 'package:move_young/screens/mains/image_preview_screen.dart';

class GenericSportScreen extends StatefulWidget {
  final String title;
  final String sportType;

  const GenericSportScreen({
    super.key,
    required this.title,
    required this.sportType,
  });

  @override
  State<GenericSportScreen> createState() => _GenericSportScreenState();
}

class _GenericSportScreenState extends State<GenericSportScreen> {
  List<Map<String, dynamic>> _allLocations = [];
  List<Map<String, dynamic>> _filteredLocations = [];
  bool _isLoading = true;
  String? _error;
  Position? _userPosition;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Map<String, String> _locationCache = {};

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

      final locations = await OverpassService.fetchFields(
        areaName: "'s-Hertogenbosch",
        sportType: widget.sportType,
      );

      for (var loc in locations) {
        final lat = loc['lat'];
        final lon = loc['lon'];
        loc['distance'] = _calculateDistance(lat, lon);
      }

      locations.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

      setState(() {
        _allLocations = locations;
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
    _filteredLocations = _allLocations.where((field) {
      final name = (field['name'] ?? '').toLowerCase();
      final address = (field['addr:street'] ?? '').toLowerCase();

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

  Future<String> _getDisplayName(Map<String, dynamic> loc) async {
    if (loc['name'] != null && loc['name'].toString().trim().isNotEmpty) {
      return loc['name'];
    }

    final lat = loc['lat'];
    final lon = loc['lon'];
    final key = '$lat,$lon';

    if (_locationCache.containsKey(key)) {
      return _locationCache[key]!;
    }

    final streetName = await getNearestStreetName(lat, lon);
    _locationCache[key] = streetName;
    return streetName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        backgroundColor: Colors.black87,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      child: Text(
                        'Find location for your exercise',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w300,
                          fontFamily: 'Poppins',
                          color: Colors.black,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.left,
                        softWrap: true,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by name or address...',
                          filled: true,
                          fillColor: Colors.grey[200],
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                            _applyFilters();
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 24.0, top: 12.0, bottom: 8.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GenericMapScreen(
                                title: widget.title,
                                locations: _filteredLocations,
                              ),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.map, color: Colors.black),
                            SizedBox(width: 6),
                            Text(
                              'Show in map',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Poppins',
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: _filteredLocations.length,
                        itemBuilder: (context, index) {
                          final field = _filteredLocations[index];
                          final lat = field['lat'].toString();
                          final lon = field['lon'].toString();
                          final distance = field['distance'] as double;
                          final imageUrl = field['tags']?['image'];

                          return ListTile(
                            leading: imageUrl != null
                                ? GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              ImagePreviewScreen(imageUrl: imageUrl),
                                        ),
                                      );
                                    },
                                    child: CachedNetworkImage(
                                      imageUrl: imageUrl,
                                      width: 100,
                                      height: 70,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          const Center(child: CircularProgressIndicator()),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.broken_image),
                                    ),
                                  )
                                : Container(
                                    width: 100,
                                    height: 70,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image_not_supported, color: Colors.grey),
                                  ),
                            title: FutureBuilder<String>(
                              future: _getDisplayName(field),
                              builder: (context, snapshot) {
                                return Text(snapshot.data ?? 'Unnamed Location');
                              },
                            ),
                            subtitle: Text(_formatDistance(distance)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.share),
                                  onPressed: () async {
                                    final name = await _getDisplayName(field);
                                    _shareLocation(name, lat, lon);
                                  },
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
                    ),
                  ],
                ),
    );
  }
}
