import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:move_young/services/overpass_service.dart';
import 'package:move_young/screens/maps/gmaps_screen.dart';
import 'package:move_young/utils/reverse_geocoding.dart';
import 'package:move_young/config/sport_characteristics_registry.dart';
import 'package:move_young/config/sport_display_registry.dart';
import 'package:move_young/widgets/sport_field_card.dart';
import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:move_young/theme/tokens.dart';

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

class _GenericSportScreenState extends State<GenericSportScreen>
    with AutomaticKeepAliveClientMixin {
  Set<String> _favoriteIds = {}; // ✅ Favorite locations
  List<Map<String, dynamic>> _allLocations = [];
  List<Map<String, dynamic>> _filteredLocations = [];
  bool _isLoading = true;
  String? _error;
  Position? _userPosition;
  Timer? _debounce;

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
      _favoriteIds =
          prefs.getStringList('favoriteSportLocations')?.toSet() ?? {};
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
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData({bool bypassCache = false}) async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _error = 'location_permission_required'.tr();
          _isLoading = false;
        });
        return;
      }

      _userPosition = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.best),
      );

      final locations = await OverpassService.fetchFields(
        areaName: "'s-Hertogenbosch",
        sportType: widget.sportType,
        bypassCache: bypassCache,
      );

      for (var loc in locations) {
        final lat = loc['lat'];
        final lon = loc['lon'];

        final distance = _calculateDistance(lat, lon);
        loc['distance'] = distance.isFinite ? distance : double.infinity;

        //Distance calc
        if (loc['name'] != null && loc['name'].toString().trim().isNotEmpty) {
          loc['displayName'] = loc['name'];
        } else {
          final key = '$lat,$lon';
          if (_locationCache.containsKey(key)) {
            loc['displayName'] = _locationCache[key];
          } else {
            final streetName = await getNearestStreetName(lat, lon);
            _locationCache[key] = streetName;
            loc['displayName'] = streetName;
          }
        }
      }

      locations.sort((a, b) =>
          (a['distance'] as double).compareTo(b['distance'] as double));

      setState(() {
        _allLocations = locations;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'loading_error'.tr();
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

      if (_selectedSurface != null && tags['surface'] != _selectedSurface) {
        return false;
      }

      if (_onlyLit && tags['lit'] != 'yes') {
        return false;
      }

      return true;
    }).toList();
  }

  double _calculateDistance(double? lat, double? lon) {
    if (_userPosition == null || lat == null || lon == null) {
      return double.infinity;
    }
    return Geolocator.distanceBetween(
      _userPosition!.latitude,
      _userPosition!.longitude,
      lat,
      lon,
    );
  }

  void _openDirections(String lat, String lon) async {
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lon&travelmode=walking';
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('could_not_open_maps'.tr())),
      );
    }
  }

  Future<void> _shareLocation(String name, String lat, String lon) async {
    final message = "Meet me at $name! 📍 https://maps.google.com/?q=$lat,$lon";
    await Share.share(message);
  }

  String _formatDistance(double distance) {
    if (distance == double.infinity) return 'distance_unknown'.tr();
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

  bool _truthy(String? v) {
    final s = v?.toLowerCase();
    return s == 'yes' || s == 'true' || s == '1' || s == 'y';
  }

  Widget _buildCharacteristicsRow(Map<String, dynamic> field) {
    final tags = field['tags'] as Map<String, dynamic>? ?? const {};
    final keys = SportCharacteristics.get(widget.sportType);

    final Map<String, IconData> iconMap =
        SportDisplayRegistry.getIconMap(widget.sportType.toLowerCase());

    final List<Widget> characteristics = [];

    for (final key in keys) {
      final rawValue = tags[key]?.toString();
      final String label = SportCharacteristics.labelFor(key, rawValue);
      final String labelToShow = label.isEmpty ? '-' : label;

      IconData iconData = iconMap[key] ?? Icons.info_outline;
      Color color = AppColors.grey;

      // 🔆 Special handling for 'lit'
      if (key == 'lit') {
        final isLit = _truthy(rawValue);
        iconData = isLit ? Icons.lightbulb : Icons.lightbulb_outline;
        color = isLit ? AppColors.amber : AppColors.grey;
      }

      characteristics.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 18, color: color),
          const SizedBox(width: 6),
          Text(labelToShow, style: AppTextStyles.small),
        ],
      ));
    }

    return Padding(
      padding: AppPaddings.topSuperSmall,
      child: Wrap(
        spacing: AppSpacing.content,
        runSpacing: 4,
        children: characteristics.isNotEmpty
            ? characteristics
            : [
                Text('no_characteristics_available'.tr(),
                    style: const TextStyle(color: AppColors.darkgrey)),
              ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final keys = SportCharacteristics.get(widget.sportType);
    final surfaceOptions =
        SportCharacteristics.getValues(widget.sportType, 'surface');
    final hasSurface = keys.contains('surface');
    final hasLit = keys.contains('lit');

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: AppPaddings.symmHorizontalReg,
      child: Row(
        children: [
          if (hasSurface)
            ...surfaceOptions.map((surface) {
              final labelKey =
                  SportCharacteristics.surfaceLabels[surface] ?? 'unknown';
              final label = labelKey.tr();
              final isSelected = _selectedSurface == surface;

              return Padding(
                padding: AppPaddings.rightSmall,
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
              padding: AppPaddings.rightSmall,
              child: FilterChip(
                label: Text('lit'.tr()),
                selected: _onlyLit,
                selectedColor: AppColors.lightamber,
                backgroundColor: AppColors.grey,
                showCheckmark: false,
                avatar: Icon(
                  _onlyLit ? Icons.lightbulb : Icons.lightbulb_outline,
                  color: _onlyLit ? AppColors.amber : AppColors.grey,
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

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : RefreshIndicator(
                  onRefresh: () => _loadData(bypassCache: true),
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: AppPaddings.symmReg,
                          child: Text('find_location_exercise'.tr(),
                              style: AppTextStyles.headline),
                        ),
                      ),
                      //Pinned: search + filters
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _StickyHeaderDelegate(
                          child: Column(
                            children: [
                              Padding(
                                padding: AppPaddings.symmHorizontalReg,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _searchController,
                                        decoration: InputDecoration(
                                          hintText:
                                              'search_by_name_address'.tr(),
                                          filled: true,
                                          fillColor: AppColors.lightgrey,
                                          prefixIcon: const Icon(Icons.search),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                                AppRadius.image),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                        onChanged: (value) {
                                          if (_debounce?.isActive ?? false) {
                                            _debounce!.cancel();
                                          }
                                          _debounce = Timer(
                                              const Duration(milliseconds: 300),
                                              () {
                                            setState(() {
                                              _searchQuery = value;
                                              _applyFilters();
                                            });
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: AppWidths.regular),
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
                                        children: [
                                          Icon(Icons.map),
                                          SizedBox(width: AppWidths.small),
                                          Text('show_in_map'.tr(),
                                              style: AppTextStyles.body),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: AppHeights.reg),
                              _buildFilterChips(),
                            ],
                          ),
                        ),
                      ),
                      _filteredLocations.isEmpty
                          ? SliverToBoxAdapter(
                              child: Padding(
                                padding: AppPaddings.allSuperBig,
                                child: Center(
                                  child: Text('no_fields_found'.tr(),
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.cardTitle),
                                ),
                              ),
                            )
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final field = _filteredLocations[index];
                                  final lat = field['lat'].toString();
                                  final lon = field['lon'].toString();
                                  final distance = field['distance'] as double;

                                  return SportFieldCard(
                                    field: field,
                                    isFavorite:
                                        _favoriteIds.contains('$lat,$lon'),
                                    distanceText: _formatDistance(distance),
                                    getDisplayName: _getDisplayName,
                                    characteristics:
                                        _buildCharacteristicsRow(field),
                                    onToggleFavorite: () async {
                                      final id = '$lat,$lon';
                                      await _toggleFavorite(id);
                                    },
                                    onShare: () async {
                                      final name = await _getDisplayName(field);
                                      _shareLocation(name, lat, lon);
                                    },
                                    onDirections: () =>
                                        _openDirections(lat, lon),
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

//Sticky header delegate
class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyHeaderDelegate({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      color: AppColors.white,
      surfaceTintColor: Colors.transparent,
      elevation: overlapsContent ? 4 : 0,
      child: child,
    );
  }

  @override
  double get maxExtent => 120;
  @override
  double get minExtent => 120;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
