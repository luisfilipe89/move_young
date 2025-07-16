import 'package:flutter/material.dart';
import 'package:move_young/screens/menus/basketball_courts.dart';
import 'package:move_young/screens/menus/fitness_outdoor.dart';
import 'package:move_young/screens/menus/fitness_station.dart';
import 'package:move_young/screens/menus/football_fields.dart';
import 'package:move_young/screens/menus/games_corners.dart';
import 'package:move_young/screens/menus/skate_bmx_parks.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedCategoryIndex = 0;

  final List<String> categories = ['Group Activities', 'Individual', 'Intensive'];

  final Map<String, List<Map<String, String>>> activities = {
    'Group Activities': [
      {
        'title': 'Football',
        'image': 'assets/images/soccer.webp',
        'calories': '430Kcal/hr',
      },
      {
        'title': 'Basketball',
        'image': 'assets/images/basketball5.webp',
        'calories': '430Kcal/hr',
      },
      {
        'title': 'Tennis',
        'image': 'assets/images/tennis.webp',
        'calories': '430Kcal/hr',
      },
    ],
    'Individual': [
      {
        'title': 'Swimming',
        'image': 'assets/images/swimming.webp',
        'calories': '200Kcal/hr',
      },
      {
        'title': 'Fitness Station',
        'image': 'assets/images/fitness.webp',
        'calories': '250Kcal/hr',
      },
    ],
    'Intensive': [
      {
        'title': 'Crossfit',
        'image': 'https://placehold.co/400x200?text=Crossfit',
        'calories': '600Kcal/hr',
      },
      {
        'title': 'Boxing',
        'image': 'https://placehold.co/400x200?text=Boxing',
        'calories': '700Kcal/hr',
      },
    ],
  };

  void navigateToMenu(String title) {
    Widget? screen;

    switch (title.toLowerCase()) {
      case 'football':
        screen = const FootballFieldScreen();
        break;
      case 'basketball':
        screen = const BasketballCourtScreen();
        break;
      case 'fitness station':
        screen = const FitnessStationScreen();
        break;
      case 'games corner':
        screen = const GamesCornerScreen();
        break;
      default:
        break;
    }
    if (screen != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen!),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No menu available for $title')),
      );
    }
  }

  
  Widget flameWithText(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('🔥', style: TextStyle(fontSize: 14)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black54,
            fontWeight: FontWeight.w400,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Widget activityCard(String title, String imageUrl, String calories) {
    return GestureDetector(
      onTap: () => navigateToMenu(title),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imageUrl,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                flameWithText(calories),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = categories[selectedCategoryIndex];
    final selectedActivities = activities[selectedCategory]!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: ListView(
            children: [
              const SizedBox(height: 16),

              // Top icons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Icon(Icons.arrow_back_ios_new, size: 24),
                  Icon(Icons.menu, size: 28),
                ],
              ),

              const SizedBox(height: 32),

              // Title
              const Text(
                'Find your',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w300,
                  fontFamily: 'Poppins',
                ),
              ),
              const Text(
                'activity',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                ),
              ),

              const SizedBox(height: 24),

              // Category Tabs
              Row(
                children: List.generate(categories.length, (index) {
                  final isSelected = index == selectedCategoryIndex;
                  return GestureDetector(
                    onTap: () => setState(() => selectedCategoryIndex = index),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 24),
                      child: Column(
                        children: [
                          Text(
                            categories[index],
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              color: Colors.black.withOpacity(isSelected ? 1.0 : 0.5),
                            ),
                          ),
                          if (isSelected)
                            Container(
                              margin: const EdgeInsets.only(top: 6),
                              width: 20,
                              height: 2,
                              color: Colors.black,
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 24),

              // Cards
              ...selectedActivities.map((a) => activityCard(
                    a['title']!,
                    a['image']!,
                    a['calories']!,
                  )),
            ],
          ),
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black45,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
        ],
      ),
    );
  }
}
