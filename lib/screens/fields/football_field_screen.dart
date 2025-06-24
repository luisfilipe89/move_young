import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class FootballFieldScreen extends StatefulWidget {
  const FootballFieldScreen({super.key});

  @override
  State<FootballFieldScreen> createState() => _FootballFieldScreenState();
}

class _FootballFieldScreenState extends State<FootballFieldScreen> {
  int? _expandedIndex;

  final List<Map<String, String>> fields = [
    {
      'name': 'Football Field Zuiderpark',
      'address': 'Parklaan 12, Den Bosch',
      'gps': '51.6882, 5.2921'
    },
    {
      'name': 'Westside Kickabout Court',
      'address': 'Burgemeesterlaan 7, Den Bosch',
      'gps': '51.6891, 5.2855'
    },
    {
      'name': 'Kanaalzone Sportveld',
      'address': 'Kanaalweg 25, Den Bosch',
      'gps': '51.6907, 5.2789'
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
        "Meet me at $name! 📍 https://maps.google.com/?q=$lat,$lng";
    Share.share(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nearby Football Fields")),
      body: ListView.builder(
        itemCount: fields.length,
        itemBuilder: (context, index) {
          final field = fields[index];
          final isExpanded = _expandedIndex == index;
          final coords = field['gps']!.split(',');
          final lat = coords[0].trim();
          final lng = coords[1].trim();

          return Column(
            children: [
              ListTile(
                leading: const Icon(Icons.location_on),
                title: Text(field['name']!),
                subtitle: Text(field['address']!),
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
                        onPressed: () => _shareLocation(field['name']!, lat, lng),
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
