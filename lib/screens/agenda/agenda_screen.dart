import 'package:flutter/material.dart';
import 'package:move_young/models/event_model.dart';
import 'package:move_young/services/event_loader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:move_young/constants.dart';
import 'dart:async';





class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  Set<String> _favoriteTitles = {}; // ✅ Favorite locations
  final TextEditingController _searchController = TextEditingController();
  List<Event> allEvents = [];
  List<Event> filteredEvents = [];

  String _searchQuery = '';
  String _sortOption = 'Date';
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
    final String text;
    
    if (event.url?.isNotEmpty ?? false) {
      text = '${event.title}\n${event.url!}';
    } else {
      text = event.title;
    }

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


  Future<void> _openDirections(String location) async {
    final query = Uri.encodeComponent(location);
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Google Maps')),
      );
    }
  }

  Future<void> loadEvents() async {
    final loaded = await loadEventsFromJson();
    setState(() {
      allEvents = loaded;
      _applyFilters();
    });

    //Preload few images from the full list
    for (var event in allEvents.take(5)) {
      if (event.imageUrl?.isNotEmpty ?? false) {
        precacheImage(CachedNetworkImageProvider(event.imageUrl!), context);
      }
    }
  }

  void _applyFilters() {
    List<Event> events = allEvents.where((event) {
      final queryMatch = event.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final isRecurring = event.isRecurring;

      if (!queryMatch) return false;
      if (isRecurring && !_showRecurring) return false;
      if (!isRecurring && !_showOneTime) return false;

      return true;
    }).toList();

    //Sorting
    if (_sortOption == 'Date') {
      events.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    } else if (_sortOption == 'Age Group') {
      events.sort((a, b) => a.targetGroup.compareTo(b.targetGroup));
    }
    // Setstate
    setState(() {
      filteredEvents = events;
    });

    //Preload only visible filtered events (first 10 max)
    for (var event in events.take(10)) {
      if (event.imageUrl?.isNotEmpty ?? false) {
        precacheImage(CachedNetworkImageProvider(event.imageUrl!), context);
      }
    }
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          DropdownButton<String>(
            value: _sortOption,
            items: ['Date', 'Age Group']
                .map((e) => DropdownMenuItem(value: e, child: Text('Sort by $e')))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _sortOption = value;
                  _applyFilters();
                });
              }
            },
          ),
          const SizedBox(width: 12),
          FilterChip(
            label: const Text('Recurring'),
            selected: _showRecurring,
            onSelected: (selected) {
              setState(() {
                _showRecurring = selected;
                _applyFilters();
              });
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('One-time'),
            selected: _showOneTime,
            onSelected: (selected) {
              setState(() {
                _showOneTime = selected;
                _applyFilters();
              });
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey,
      highlightColor: Colors.white,
      child: Container(
        height:kImageHeight,
        width:double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(12))
        ),
      ),
    );
  }
  
  Widget _buildEventCard(Event event) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: kCardPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kCardRadius),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Event Image
            if (event.imageUrl?.isNotEmpty ?? false)
              ClipRRect(
                borderRadius: BorderRadius.circular(kImageRadius),
                child: CachedNetworkImage(
                  imageUrl: event.imageUrl!,
                  height:kImageHeight,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  //Smooth fade in
                  fadeInDuration: kFadeDuration,
                  fadeInCurve: Curves.easeInOut,
                  //Shimmer
                  placeholder: (context, url) => _buildShimmerPlaceholder(),
                  //Shown if image fails to load
                  errorWidget: (context, url, error) => Container(
                    height: kImageHeight,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image),
                  ),
                ),
              )
            else
              Container(
                height: kImageHeight,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(kImageRadius),
                ),
                child: const Center(child: Icon(Icons.image_not_supported)),
              ),
            const SizedBox(height:8),
              
            //Event info
            Text(
              event.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),  
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[700]),
                const SizedBox(width: 4),
                Text(event.dateTime, style: const TextStyle(color: Colors.black54)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[700]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(event.location, style: const TextStyle(color: Colors.black54)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.group, size: 16, color: Colors.grey[700]),
                const SizedBox(width:4),
                Text(event.targetGroup, style: const TextStyle(fontSize:13)),
              ],
            ),
            const SizedBox(height:4),
            Row(
              children: [
                Icon(Icons.euro, size: 16, color: Colors.grey[700]),
                const SizedBox(width: 4),
                Text(
                  event.cost.replaceAll('€','').trim(), 
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),  
            const SizedBox(height:12),
            // Action Buttons + Enrol
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(
                    _favoriteTitles.contains(event.title) ? Icons.favorite: Icons.favorite_border,
                    color: _favoriteTitles.contains(event.title) ? Colors.red : Colors.black,
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
                  onPressed: () => _openDirections(event.location),
                ),
                if (event.url != null && event.url!.trim().isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: () async{
                      final url = event.url!.trim();
                      final uri = Uri.parse(url);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not open the enrolment page')),
                      );
                    }
                  },
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Inschrijven'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
            SliverAppBar(
              pinned: true,
              floating: false,
              snap: false,
              elevation: 0,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              title: const Text('Agenda'),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search events...',
                    filled: true,
                    fillColor: Colors.grey[200],
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(kImageRadius),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),
            ),
            SliverToBoxAdapter(child: _buildFilterChips()),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final event = filteredEvents[index];
                  return _buildEventCard(event);
                },
                childCount: filteredEvents.length,
              ),
            )
          ],
        ),
      ),
    );
  }
}
