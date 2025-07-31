import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:move_young/services/overpass_service.dart';
import 'package:move_young/screens/maps/gmaps_screen.dart';
import 'package:move_young/utils/reverse_geocoding.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:move_young/config/sport_characteristics.dart';
import 'package:move_young/config/sport_display_registry.dart';



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
  String? _selectedSurface;
  bool _onlyLit = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _loadData();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoriteIds = prefs.getStringList('favoriteSportLocations')?.toSet() ?? {};
    });
  }

  Future<void> _toggleFavorite(String id) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favoriteIds.contains(id)) {
        _favoriteIds.remove(id);
      } else {
        _favoriteIds.add(id);
      }
      prefs.setStringList('favoriteSportLocations', _favoriteIds.toList());
    });
  }
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        setState((){
          _error = 'Location permission is required to show nearby fields.';
          _isLoading = false;
        });
        return;
      }
      
      _userPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
      );

      final locations = await OverpassService.fetchFields(
        areaName: "'s-Hertogenbosch",
        sportType: widget.sportType,
      );

      for (var loc in locations) {
        final lat = loc['lat'];
        final lon = loc['lon'];

        final distance = _calculateDistance(lat,lon);
        loc['distance'] = distance.isFinite ? distance: double.infinity;

        //Distance calc
        if (loc['name'] != null && loc['name'].toString().trim().isNotEmpty) {
          loc['displayName'] = loc['name'];
        } else {
          final key = '$lat,$lon';
          if (_locationCache.containsKey(key)) {
            loc['displayName'] = _locationCache[key];
          } else {
            final streetName = await getNearestStreetName(lat,lon);
            _locationCache[key] = streetName;
            loc['displayName'] = streetName;
          }
        }
      }

      locations.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

      setState(() {
        _allLocations = locations;
        _applyFilters();
        _isLoading = false;
      });
    
    } catch (e) {
      setState(() {
        _error = 'Something went wrong while loading data';
        _isLoading = false;
      });
      debugPrint('Error in _loadData: $e');
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

      final tags = field['tags'] ?? {};

      if (_selectedSurface != null &&
          tags['surface'] != _selectedSurface) {
        return false;
      }

      if(_onlyLit && tags['lit'] != 'yes') {
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

  Future<void> _shareLocation(String name, String lat, String lon) async {
    final message = "Meet me at $name! 📍 https://maps.google.com/?q=$lat,$lon";
    await Share.share(message);
  }

  
  String _formatDistance(double distance) {
    if (distance == double.infinity) return 'Distance unknown';
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

      IconData iconData;
      Color color = iconMap[key]?.$2 ?? Colors.grey;

      if (key == 'lit'){
        iconData = (rawValue =='yes') ? Icons.lightbulb: Icons.lightbulb_outline;
        color = Colors.amber;
      } else {
        iconData = iconMap[key]?.$1 ?? Icons.info_outline;
        color = iconMap[key]?.$2 ?? Colors.grey;
      }
      
      characteristics.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 16, color: color),
          const SizedBox(width: 4),
          Text(value, style: const TextStyle(fontSize: 16, color: Colors.black87)),
          const SizedBox(width: 12),
        ],
      ));
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 12,
        runSpacing: 4,
        children: characteristics.isNotEmpty
            ? characteristics
            : [Text('No characteristics available', style: TextStyle(color: Colors.grey[600]))],
      ),
    );
  }

  Widget _buildFilterChips() {
    final keys = SportCharacteristics.get(widget.sportType);
    final surfaceOptions = SportCharacteristics.getValues(widget.sportType,'surface');
    final hasSurface = keys.contains('surface');
    final hasLit = keys.contains('lit');

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if(hasSurface)
            ...surfaceOptions.map((surface) {
              final label = SportCharacteristics.getLabel(surface,SportCharacteristics.surfaceLabels);
              final isSelected = _selectedSurface == surface;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(label),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedSurface = selected ? surface : null;
                      _applyFilters();
                    });
                  },  
                ),
              );
            }),

          if (hasLit)
             Padding(
               padding:const EdgeInsets.only(right: 8),
               child: FilterChip(
                 label: const Text('Lit'),
                 selected: _onlyLit,
                 selectedColor: Colors.amber[200],
                 backgroundColor: Colors.grey[200],
                 showCheckmark: false,
                 avatar: Icon(
                  _onlyLit ? Icons.lightbulb : Icons.lightbulb_outline,
                  color: _onlyLit ? Colors.amber[600] : Colors.grey,
                  size: 18,
                 ),
                 onSelected: (selected) {
                   setState(() {
                    _onlyLit = selected;
                    _applyFilters();
                  });
                },
              ),
            ),
        ],
      ),
    );
  }      

  Widget _buildActionIcon({
  required IconData icon,
  required VoidCallback onPressed,
  Color color = Colors.black,
  String? tooltip,
}) {
  return IconButton(
    icon: Icon(icon, size: 24, color: color),
    tooltip: tooltip,
    splashRadius: 24,
    onPressed: onPressed,
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: const Padding(  
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _StickyHeaderDelegate(
                        child: Column(
                          children: [
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
                          _buildFilterChips(),
                        ],
                      ),
                    ),
                  ),
                    SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context,index) {
                        final field = _filteredLocations[index];
                        final lat = field['lat'].toString();
                        final lon = field['lon'].toString();
                        final distance = field['distance'] as double;
                        final imageUrl = field['tags']?['image'];

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //Image
                                  if (imageUrl != null)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: CachedNetworkImage(
                                        imageUrl: imageUrl,
                                        height: 140,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => const SizedBox(
                                          height: 140,
                                          child: Center(child: CircularProgressIndicator()),
                                        ),
                                        errorWidget: (context, url, error) => Container(
                                          height: 140,
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.broken_image),
                                        ),
                                      ),
                                    )
                                  else  
                                    Container(
                                      height: 140,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Center(child: Icon(Icons.image_not_supported)),
                                    ),
                                  const SizedBox(height: 2),

                                  //Title
                                  FutureBuilder<String>(
                                    future: _getDisplayName(field),
                                    builder: (context, snapshot) {
                                      return Text(
                                        snapshot.data ?? 'Unnamed Field',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Poppins',
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 4),

                                  //Distance
                                  Text(
                                    _formatDistance(distance),
                                    style: const TextStyle(color: Colors.black54),
                                  ),
                                  const SizedBox(height: 8),

                                  //Build Characteristics          
                                  _buildCharacteristicsRow(field),
                                  const SizedBox(height: 6),

                                  //Action Buttons
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top:4),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          _buildActionIcon(
                                            icon: _favoriteIds.contains('$lat,$lon') ? Icons.favorite : Icons.favorite_border,
                                            color: _favoriteIds.contains('$lat,$lon') ? Colors.red : Colors.black,
                                            tooltip: 'Favorite',
                                            onPressed: () async {
                                            final id = '$lat,$lon';
                                            await _toggleFavorite(id);
                                            },
                                          ),
                                          _buildActionIcon(
                                            icon: Icons.share,
                                            tooltip: 'Share Location',
                                            onPressed: () async {
                                            final name = await _getDisplayName(field);
                                            _shareLocation(name, lat, lon);
                                            },
                                          ),
                                          _buildActionIcon(
                                            icon: Icons.directions,
                                            tooltip: 'Directions',
                                            onPressed: () => _openDirections(lat, lon),
                                          ),
                                        ],
                                      ),  
                                    ),
                                  ),  
                                ],
                              ),
                            ),
                          ),
                        );
                      },  
                      childCount: _filteredLocations.length,
                    ),
                  ),   
                ],
              ),
            ),
          );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyHeaderDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      color: Colors.white,
      elevation: overlapsContent ? 4 : 0,
      child: child,
    );
  }

  @override
  double get maxExtent => 120;
  @override
  double get minExtent => 120;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}
