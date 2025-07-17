import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:move_young/services/overpass_service.dart';
import 'package:move_young/screens/maps/gmaps_screen.dart';
import 'package:move_young/utils/reverse_geocoding.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:move_young/screens/mains/image_preview_screen.dart';
import 'package:move_young/config/sport_characteristics.dart';
import 'package:move_young/config/sport_display_registry.dart';
import 'package:move_young/services/cache_service.dart';
import 'package:move_young/services/favorites_service.dart';


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
  Set<String> _favoriteIds = {}; // ✅ Favorite locations
  List<Map<String, dynamic>> _allLocations = [];
  List<Map<String, dynamic>> _filteredLocations = [];
  bool _isLoading = true;
  String? _error;
  Position? _userPosition;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Map<String, String> _locationCache = {};
  final Set<String> _activeFilters = {}; // ✅ characteristic filter state

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _loadData();
  }

  Future<void> _loadFavorites() async {
    final favs = await FavoritesService.getFavorites();
    setState(() {
      _favoriteIds = favs;
    });
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
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
      );

      final cacheKey = widget.sportType;

      final cachedData = await CacheService.load(cacheKey);
      if (cachedData != null && cachedData.isNotEmpty) {
        for (var loc in cachedData) {
          final lat = loc['lat'];
          final lon = loc['lon'];
          loc['distance'] = _calculateDistance(lat, lon);
        }

        cachedData.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

        setState(() {
          _allLocations = cachedData;
          _filteredLocations = List.from(_allLocations);
          _isLoading = false;
        });

        debugPrint('Loaded ${cachedData.length} items from cache');
        return;
      }
      
      // 🌐 If no cache, fetch from Overpass
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

      // 💾 Save to cache
      await CacheService.save(cacheKey, locations);
      debugPrint('Cached ${locations.length} items for $cacheKey');
    
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

      if (_activeFilters.isNotEmpty) {
        final tags = field['tags'] ?? {};
        for (var filter in _activeFilters) {
          if (!(tags.containsKey(filter) && tags[filter] != null && tags[filter] != 'no')) {
            return false;
          }
        }
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

  Widget _buildCharacteristicsRow(Map<String, dynamic> field) {
    final tags = field['tags'] ?? {};
    final keys = SportCharacteristics.get(widget.sportType);
    final iconMap = SportDisplayRegistry.getIconMap(widget.sportType);
    final formatValue = SportDisplayRegistry.getFormatter(widget.sportType);

    final List<Widget> characteristics = [];

    for (var key in keys) {
      final rawValue = tags[key];
      final value = formatValue(key, rawValue);
      final iconData = iconMap[key]?.$1 ?? Icons.info_outline;
      final color = iconMap[key]?.$2 ?? Colors.grey;

      characteristics.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 16, color: color),
          const SizedBox(width: 4),
          Text(value, style: const TextStyle(fontSize: 14, color: Colors.black87)),
          const SizedBox(width: 12),
        ],
      ));
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(children: characteristics),
    );
  }

  Widget _buildFilterChips() {
    final keys = SportCharacteristics.get(widget.sportType);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: keys.map((key) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(key[0].toUpperCase() + key.substring(1)),
              selected: _activeFilters.contains(key),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _activeFilters.add(key);
                  } else {
                    _activeFilters.remove(key);
                  }
                  _applyFilters();
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
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
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Expanded(
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
                          const SizedBox(width: 8),
                          GestureDetector(
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
                              children: const [
                                Icon(Icons.map, color: Colors.black),
                                SizedBox(width: 4),
                                Text('Show in map', style: TextStyle(color: Colors.black)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildFilterChips(), // ✅ Characteristics Filter Chips
                    const SizedBox(height: 8),
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
                                          builder: (_) => ImagePreviewScreen(imageUrl: imageUrl),
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
                                    child:
                                        const Icon(Icons.image_not_supported, color: Colors.grey),
                                  ),
                            title: FutureBuilder<String>(
                              future: _getDisplayName(field),
                              builder: (context, snapshot) {
                                return Text(snapshot.data ?? 'Unnamed Location');
                              },
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_formatDistance(distance)),
                                const SizedBox(height: 4),
                                _buildCharacteristicsRow(field),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // ✅ Favorite Button with Animation
                               AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                                child: IconButton(
                                  key: ValueKey<bool>(_favoriteIds.contains('$lat,$lon')),
                                  icon: Icon(
                                    _favoriteIds.contains('$lat,$lon') ? Icons.favorite: Icons.favorite_border,
                                    color: _favoriteIds.contains('$lat,$lon') ? Colors.red: null,
                                  ),
                                  onPressed: () async {
                                    final id = '$lat,$lon';
                                    await FavoritesService.toggleFavorite(id);
                                    setState(() {
                                      if (_favoriteIds.contains(id)) {
                                        _favoriteIds.remove(id);
                                      } else {
                                        _favoriteIds.add(id);
                                      }
                                    });
                                  },
                                ),
                               ),

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
