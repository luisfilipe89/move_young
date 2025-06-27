import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class OutdoorFitnessScreen extends StatefulWidget {
  const OutdoorFitnessScreen({super.key});

  @override
  State<OutdoorFitnessScreen> createState() => _OutdoorFitnessScreenState();
}

class _OutdoorFitnessScreenState extends State<OutdoorFitnessScreen> {
  int? _expandedIndex;

  final List<Map<String, String>> zones = [
    {
      'name': 'Fitness Park Paleiskwartier',
      'address': 'Hoflaan 4, 5223 Den Bosch',
      'gps': '51.6901, 5.2750'
    },
    {
      'name': 'Outdoor Gym Maaspoort',
      'address': 'Sportlaan 30, 5235 Den Bosch',
      'gps': '51.7220, 5.2950'
    },
  ];

  void _openMap(String lat, String lng) async {
    final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=walking');

    if (await canLaunchUrl(uri)) {
      final success = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Google Maps')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid location or URL')),
      );
    }
  }

  void _shareLocation(String name, String lat, String lng) {
    final message = "Let’s train at $name! 📍 https://maps.google.com/?q=$lat,$lng";
    Share.share(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Outdoor Fitness Zones")),
      body: ListView.builder(
        itemCount: zones.length,
        itemBuilder: (context, index) {
          final zone = zones[index];
          final isExpanded = _expandedIndex == index;
          final coords = zone['gps']!.split(',');
          final lat = coords[0].trim();
          final lng = coords[1].trim();

          return Column(
            children: [
              ListTile(
                leading: const Icon(Icons.fitness_center),
                title: Text(zone['name']!),
                subtitle: Text(zone['address']!),
                onTap: () {
                  setState(() {
                    _expandedIndex = isExpanded ? null : index;
                  });
                },
              ),
              if (isExpanded)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.share),
                        label: const Text("Share"),
                        onPressed: () => _shareLocation(zone['name']!, lat, lng),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.directions),
                        label: const Text("Directions"),
                        onPressed: () => _openMap(lat, lng),
                      ),
                    ],
                  ),
                ),
              const Divider(height: 1),
            ],
          );
        },
      ),
    );
  }
}
