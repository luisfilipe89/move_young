import 'package:flutter/material.dart';

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
          return ListTile(
            leading: const Icon(Icons.location_on),
            title: Text(field['name']!),
            subtitle: Text("${field['address']} • GPS: ${field['gps']}"),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Opening map for ${field['name']}...")),
              );
            },
          );
        },
      ),
    );
  }
}
