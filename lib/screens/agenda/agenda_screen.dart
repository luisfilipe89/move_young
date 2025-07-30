import 'package:flutter/material.dart';
import 'package:move_young/models/event_model.dart';
import 'package:move_young/services/event_loader.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Event> allEvents = [];
  List<Event> filteredEvents = [];

  String _searchQuery = '';
  String _sortOption = 'Date';
  bool _showRecurring = true;
  bool _showOneTime = true;

  @override
  void initState() {
    super.initState();
    loadEvents();
  }

  Future<void> loadEvents() async {
    final loaded = await loadEventsFromJson();
    setState(() {
      allEvents = loaded;
      _applyFilters();
    });
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

    if (_sortOption == 'Date') {
      events.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    } else if (_sortOption == 'Age Group') {
      events.sort((a, b) => a.targetGroup.compareTo(b.targetGroup));
    }

    setState(() {
      filteredEvents = events;
    });
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

  Widget _buildEventCard(Event event) {
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
              //Event Image
              if (event.imageUrl != null && event.imageUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    event.imageUrl!,
                    height:140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 140,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const SizedBox(
                        height: 140,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                  )
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
              const SizedBox(height:8),
              
              //Event info
              Text(event.title,style: const TextStyle(fontSize: 16,fontWeight: FontWeight.bold,fontFamily: 'Poppins')),
              const SizedBox(height: 8),
              Text(event.dateTime, style: const TextStyle(color: Colors.black54)),
              Text(event.location, style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 4),
              Text(event.targetGroup, style: const TextStyle(fontSize:13)),
              const SizedBox(height:4),
              Text(event.cost, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
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
