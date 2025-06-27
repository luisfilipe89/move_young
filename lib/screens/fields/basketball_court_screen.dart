import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class BasketballCourtScreen extends StatefulWidget {
  const BasketballCourtScreen({super.key});

  @override
  State<BasketballCourtScreen> createState() => _BasketballCourtScreenState();
}

class _BasketballCourtScreenState extends State<BasketballCourtScreen> {
  int? _expandedIndex;

  final List<Map<String, String>> courts = [
    {
      'name': "Playground Z'uitje",
      'address': 'Westerparkstraat 4, Den Bosch',
      'gps': '51.6922, 5.2850'
    },
  ];

  void _openMap(String lat, String lng) async {
    final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=walking');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $uri';
    }
  }

  void _shareLocation(String name, String lat, String lng) {
    final message =
        "🏀 Meet me at $name! 📍 https://maps.google.com/?q=$lat,$lng";
    Share.share(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nearby Basketball Courts")),
      body: ListView.builder(
        itemCount: courts.length,
        itemBuilder: (context, index) {
          final court = courts[index];
          final isExpanded = _expandedIndex == index;
          final coords = court['gps']!.split(',');
          final lat = coords[0].trim();
          final lng = coords[1].trim();

          return Column(
            children: [
              ListTile(
                leading: const Icon(Icons.sports_basketball),
                title: Text(court['name']!),
                subtitle: Text(court['address']!),
                onTap: () {
                  setState(() {
                    _expandedIndex = isExpanded ? null : index;
                  });
                },
              ),
              if (isExpanded)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.share),
                        label: const Text("Share"),
                        onPressed: () => _shareLocation(court['name']!, lat, lng),
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
