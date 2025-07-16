import 'package:flutter/material.dart';

class FitnessOutdoorScreen extends StatelessWidget {
  const FitnessOutdoorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness Outdoor Zones'),
      ),
      body: const Center(
        child: Text(
          'Fitness outdoor locations coming soon!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
