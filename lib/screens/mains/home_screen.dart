import 'package:flutter/material.dart';
import 'package:move_young/screens/menus/basketball_courts.dart';
import 'package:move_young/screens/menus/football_fields.dart';
import 'package:move_young/screens/menus/fitness_stations.dart';
import 'package:move_young/screens/menus/table_tennis.dart';
import 'package:move_young/screens/menus/skateboarding.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedCategoryIndex = 0;

  final List<String> categories = ['Grouped', 'Not so Grouped', 'Radical'];

  final Map<String, List<Map<String, String>>> activities = {
    'Grouped': [
      {
        'title': 'Football',
        'image': 'assets/images/soccer.webp',
        'calories': '430Kcal/hr',
      },
      {
        'title': 'Basketball',
        'image': 'assets/images/basketball.jpg',
        'calories': '430Kcal/hr',
      },
      {
        'title': 'Tennis',
        'image': 'assets/images/tennis.jpg',
        'calories': '430Kcal/hr',
      },
      {
        'title': 'Table Tennis',
        'image': 'assets/images/tennis.webp',
        'calories': '430Kcal/hr',
      },
    ],
    'Not so Grouped': [
      {
        'title': 'Swimming',
        'image': 'assets/images/swimming.webp',
        'calories': '200Kcal/hr',
      },
      {
        'title': 'Fitness Station',
        'image': 'assets/images/fitness_station.jpg',
        'calories': '250Kcal/hr',
      },
    ],
    'Radical': [
      {
        'title': 'Skateboarding',
        'image': 'assets/images/skateboarding.webp',
        'calories': '600Kcal/hr',
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
        screen = const BasketballCourtsScreen();
        break;
      case 'fitness station':
        screen = const FitnessStationsScreen();
        break;
      case 'table tennis':
        screen = const TableTennisScreen();
        break;
      case 'skateboarding':
        screen = const SkateboardingScreen();
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
    final isNetworkImage = imageUrl.startsWith('http');
    

    return GestureDetector(
      onTap: () => navigateToMenu(title),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: isNetworkImage
                  ? Image.network(
                      imageUrl,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                    imageUrl,
                    alignment: Alignment(0.0,-0.2),
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
                              color: Colors.black.withAlpha((0.6*255).round())
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
