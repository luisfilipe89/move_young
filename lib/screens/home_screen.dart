import 'package:flutter/material.dart';
import '../widgets/activity_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF5B2B),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF5B2B),
        elevation: 0,
        title: const Text(
          "LET’S GET MOVING,\nDEN BOSCH!",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            ActivityCard(
              title: "Urban Dance Class",
              subtitle: "Near you",
              buttonText: "JOIN",
              icon: Icons.directions_run,
              backgroundColor: Colors.deepPurple,
              onPressed: () {},
            ),
            ActivityCard(
              title: "Bike Challenge with Friends",
              subtitle: "Track miles ridden over a week",
              buttonText: "LEARN MORE",
              icon: Icons.pedal_bike,
              backgroundColor: Colors.orange,
              onPressed: () {},
            ),
            ActivityCard(
              title: "Free Basketball Court",
              subtitle: "Open Today",
              buttonText: "JOIN",
              icon: Icons.sports_basketball,
              backgroundColor: Colors.teal,
              onPressed: () {},
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        backgroundColor: const Color(0xFFFFEFD2),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: "Progress"),
          BottomNavigationBarItem(icon: Icon(Icons.flag), label: "Challenges"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
