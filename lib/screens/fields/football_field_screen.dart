import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FootballFieldScreen extends StatelessWidget {
  const FootballFieldScreen({super.key});

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nearby Football Fields"),
      ),
      body: ListView.builder(
        itemCount: fields.length,
        itemBuilder: (context, index) {
          final field = fields[index];
          final coords = field['gps']!.split(',');
          final lat = coords[0].trim();
          final lng = coords[1].trim();

          return ListTile(
            leading: const Icon(Icons.location_on),
            title: Text(field['name']!),
            subtitle: Text("${field['address']} • GPS: ${field['gps']}"),
            onTap: () {
              _openMap(lat, lng);
            },
          );
        },
      ),
    );
  }
}

Future<void> _openMap(String lat, String lng) async {
  final uri = Uri.parse(
    'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=walking',
  );
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch $uri';
  }
}
