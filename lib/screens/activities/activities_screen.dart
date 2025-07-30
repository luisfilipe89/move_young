
import 'package:flutter/material.dart';
import 'package:move_young/screens/activities/sport_types/basketball_courts.dart';
import 'package:move_young/screens/activities/sport_types/football_fields.dart';
import 'package:move_young/screens/activities/sport_types/fitness_stations.dart';
import 'package:move_young/screens/activities/sport_types/table_tennis.dart';
import 'package:move_young/screens/activities/sport_types/skateboarding.dart';
import 'package:move_young/widgets/custom_bottom_nav_bar.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  int selectedCategoryIndex = 0;

  final List<String> categories = ['Grouped', 'Not so Grouped', 'Radical'];

  final Map<String, List<Map<String, String>>> activities = {
    'Grouped': [
      {
        'title': 'Football',
        'image': 'assets/images/soccer.webp',
        'calories': '420Kcal/hr',
      },
      {
        'title': 'Basketball',
        'image': 'assets/images/basketball.jpg',
        'calories': '400Kcal/hr',
      },
      {
        'title': 'Tennis',
        'image': 'assets/images/tennis.jpg',
        'calories': '400Kcal/hr',
      },
      {
        'title': 'Table Tennis',
        'image': 'assets/images/tennis.webp',
        'calories': '250Kcal/hr',
      },
    ],
    'Not so Grouped': [
      {
        'title': 'Swimming',
        'image': 'assets/images/swimming.webp',
        'calories': '450Kcal/hr',
      },
      {
        'title': 'Fitness Station',
        'image': 'assets/images/fitness_station.jpg',
        'calories': '300Kcal/hr',
      },
    ],
    'Radical': [
      {
        'title': 'Skateboarding',
        'image': 'assets/images/skateboarding.webp',
        'calories': '350Kcal/hr',
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
        break;
    }
    if (screen != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen!),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No menu available for \$title')),
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () => navigateToMenu(title),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: isNetworkImage
                    ? Image.network(
                        imageUrl,
                        height: 100,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        imageUrl,
                        alignment: const Alignment(0.0, -0.5),
                        height: 100,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = categories[selectedCategoryIndex];
    final selectedActivities = activities[selectedCategory]!;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new),
                  onPressed: () => Navigator.pop(context),
                ),
                const Icon(Icons.menu, size: 28),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x26000000),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Find your activity',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: List.generate(categories.length, (index) {
                      final isSelected = index == selectedCategoryIndex;
                      return Padding(
                        padding: const EdgeInsets.only(right: 24),
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () => setState(() => selectedCategoryIndex = index),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8),
                            child: Column(
                              children: [
                                Text(
                                  categories[index],
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black.withAlpha((0.6 * 255).round()),
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
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  ...selectedActivities.map(
                    (a) => activityCard(
                      a['title']!,
                      a['image']!,
                      a['calories']!,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

    );
  }
}
