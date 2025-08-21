import 'package:flutter/material.dart';
import 'package:move_young/models/event_model.dart';
import 'package:move_young/services/load_events_from_json.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:move_young/theme/tokens.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  Set<String> _favoriteTitles = {};
  final TextEditingController _searchController = TextEditingController();
  List<Event> allEvents = [];
  List<Event> filteredEvents = [];

  String _searchQuery = '';
  bool _showRecurring = true;
  bool _showOneTime = true;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    loadEvents();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoriteTitles = prefs.getStringList('favoriteEvents')?.toSet() ?? {};
    });
  }

  Future<void> _toggleFavorite(String title) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favoriteTitles.contains(title)) {
        _favoriteTitles.remove(title);
      } else {
        _favoriteTitles.add(title);
      }
      prefs.setStringList('favoriteEvents', _favoriteTitles.toList());
    });
  }

  Future<void> _shareEvent(Event event) async {
    final String text = (event.url?.isNotEmpty ?? false)
        ? '${event.title}\n${event.url!}'
        : event.title;
    await Share.share(text);
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = query;
        _applyFilters();
      });
    });
  }

  Future<void> _openDirections(BuildContext context, String location) async {
    final query = Uri.encodeComponent(location);
    final uri =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('could_not_open_google_maps'.tr())),
          );
        }
      });
    }
  }

  Future<void> loadEvents() async {
    final loaded = await loadEventsFromJson();
    if (!mounted) return;

    setState(() {
      allEvents = loaded;
      _applyFilters();
    });

    // Preload a few images
    for (var event in allEvents.take(5)) {
      if (event.imageUrl?.isNotEmpty ?? false) {
        precacheImage(CachedNetworkImageProvider(event.imageUrl!), context);
      }
    }
  }

  void _applyFilters() {
    final events = allEvents.where((event) {
      final queryMatch =
          event.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final isRecurring = event.isRecurring;

      if (!queryMatch) return false;
      if (isRecurring && !_showRecurring) return false;
      if (!isRecurring && !_showOneTime) return false;

      return true;
    }).toList();

    setState(() => filteredEvents = events);

    // Preload visible filtered images
    for (var event in events.take(10)) {
      if (event.imageUrl?.isNotEmpty ?? false) {
        precacheImage(CachedNetworkImageProvider(event.imageUrl!), context);
      }
    }
  }

  Widget _buildFilterChipsRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: AppPaddings.symmHorizontalReg,
      child: Row(
        children: [
          // Recurring
          Padding(
            padding: AppPaddings.rightSmall,
            child: FilterChip(
              label: Text('recurring'.tr()),
              selected: _showRecurring,
              showCheckmark: false,
              avatar: Icon(
                _showRecurring ? Icons.repeat : Icons.repeat_on_outlined,
                color: _showRecurring ? AppColors.amber : AppColors.grey,
                size: 18,
              ),
              onSelected: (selected) {
                setState(() {
                  _showRecurring = selected;
                  _applyFilters();
                });
              },
            ),
          ),

          // One-time
          Padding(
            padding: AppPaddings.rightSmall,
            child: FilterChip(
              label: Text('one_time'.tr()),
              selected: _showOneTime,
              showCheckmark: false,
              avatar: Icon(
                _showOneTime ? Icons.event_available : Icons.event_note,
                color: _showOneTime ? AppColors.amber : AppColors.grey,
                size: 18,
              ),
              onSelected: (selected) {
                setState(() {
                  _showOneTime = selected;
                  _applyFilters();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: AppColors.grey,
      highlightColor: AppColors.white,
      child: Container(
        height: AppHeights.image,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.card)),
        ),
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    return Container(
      margin: AppPaddings.symmReg,
      padding: AppPaddings.allMedium,
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: AppShadows.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (event.imageUrl?.isNotEmpty ?? false)
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.image),
              child: CachedNetworkImage(
                imageUrl: event.imageUrl!,
                height: AppHeights.image,
                width: double.infinity,
                fit: BoxFit.cover,
                fadeInDuration: Duration(milliseconds: 300),
                fadeInCurve: Curves.easeInOut,
                placeholder: (context, url) => _buildShimmerPlaceholder(),
                errorWidget: (context, url, error) => Container(
                  height: AppHeights.image,
                  color: AppColors.lightgrey,
                  child: const Icon(Icons.broken_image),
                ),
              ),
            )
          else
            Container(
              height: AppHeights.image,
              decoration: BoxDecoration(
                color: AppColors.grey,
                borderRadius: BorderRadius.circular(AppRadius.image),
              ),
              child: const Center(child: Icon(Icons.image_not_supported)),
            ),
          const SizedBox(height: AppHeights.reg),
          Text(event.title, style: AppTextStyles.cardTitle),
          const SizedBox(height: AppHeights.reg),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: AppColors.darkgrey),
              const SizedBox(width: AppWidths.small),
              Text(event.dateTime, style: AppTextStyles.small),
            ],
          ),
          const SizedBox(height: AppHeights.small),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: AppColors.darkgrey),
              const SizedBox(width: AppWidths.small),
              Expanded(
                child: Text(event.location, style: AppTextStyles.small),
              ),
            ],
          ),
          const SizedBox(height: AppHeights.small),
          Row(
            children: [
              Icon(Icons.group, size: 16, color: AppColors.darkgrey),
              const SizedBox(width: AppWidths.small),
              Text(event.targetGroup, style: AppTextStyles.small),
            ],
          ),
          const SizedBox(height: AppHeights.small),
          Row(
            children: [
              Icon(Icons.euro, size: 16, color: AppColors.darkgrey),
              const SizedBox(width: AppWidths.small),
              Text(event.cost.replaceAll('€', '').trim(),
                  style: AppTextStyles.smallMuted),
            ],
          ),
          const SizedBox(height: AppHeights.big),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(
                  _favoriteTitles.contains(event.title)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: _favoriteTitles.contains(event.title)
                      ? AppColors.red
                      : AppColors.blackIcon,
                ),
                tooltip: 'Favorite',
                onPressed: () => _toggleFavorite(event.title),
              ),
              IconButton(
                icon: const Icon(Icons.share),
                tooltip: 'Share Event',
                onPressed: () => _shareEvent(event),
              ),
              IconButton(
                icon: const Icon(Icons.directions),
                tooltip: 'Open in Maps',
                onPressed: () => _openDirections(context, event.location),
              ),
              if (event.url != null && event.url!.trim().isNotEmpty)
                ElevatedButton.icon(
                  onPressed: () async {
                    final url = event.url!.trim();
                    final uri = Uri.parse(url);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                    } else if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Could not open the enrolment page'),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.open_in_new),
                  label: Text('to_enroll'.tr()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: AppColors.white,
                    padding: AppPaddings.symmSmall,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.smallCard),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: loadEvents,
        child: CustomScrollView(
          slivers: [
            // --- Centered title ---
            SliverAppBar(
              pinned: true,
              floating: false,
              snap: false,
              elevation: 0,
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.black,
              centerTitle: true,
              title: Text('agenda'.tr()),
            ),

            // --- Subtitle (non-pinned) ---
            SliverToBoxAdapter(
              child: Padding(
                padding: AppPaddings.symmReg,
                child: Text(
                    'find_your_next_event_for_exercise'.tr(
                      args: const [], // add key to your locales
                    ),
                    textAlign: TextAlign.left,
                    style: AppTextStyles.headline),
              ),
            ),

            // --- Pinned: search + filters
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyHeaderDelegate(
                child: Column(
                  children: [
                    Padding(
                      padding: AppPaddings.symmHorizontalReg,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'search_events'.tr(),
                          filled: true,
                          fillColor: AppColors.lightgrey,
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.image),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: _onSearchChanged,
                      ),
                    ),
                    const SizedBox(height: AppHeights.reg),
                    _buildFilterChipsRow(),
                  ],
                ),
              ),
            ),

            // --- List ---
            if (filteredEvents.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: AppPaddings.allSuperBig,
                  child: Center(
                    child:
                        Text('no_events_found'.tr(), // add this key if needed
                            textAlign: TextAlign.center,
                            style: AppTextStyles.cardTitle),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildEventCard(filteredEvents[index]),
                  childCount: filteredEvents.length,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Sticky header delegate
class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _StickyHeaderDelegate({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      color: AppColors.white,
      elevation: overlapsContent ? 4 : 0,
      child: child,
    );
  }

  // Height to fit search + chips; tweak if needed
  @override
  double get maxExtent => 120;
  @override
  double get minExtent => 120;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
