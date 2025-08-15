import 'package:flutter/material.dart';
import 'package:move_young/screens/activities/sports_screens/soccer.dart';
import 'package:move_young/screens/activities/sports_screens/basketball.dart';
import 'package:move_young/screens/activities/sports_screens/tennis.dart';
import 'package:move_young/screens/activities/sports_screens/beachvolleyball.dart';
import 'package:move_young/screens/activities/sports_screens/table_tennis.dart';
import 'package:move_young/screens/activities/sports_screens/fitness.dart';
import 'package:move_young/screens/activities/sports_screens/skateboard.dart';
import 'package:move_young/screens/activities/sports_screens/bmx.dart';
import 'package:move_young/widgets/activity_category_page.dart';
import 'package:easy_localization/easy_localization.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  int selectedCategoryIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: selectedCategoryIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  final List<String> categories = ['grouped', 'not_so_grouped', 'radical'];

  final Map<String, String> categoryKeys = {
    'grouped': 'grouped',
    'not_so_grouped': 'not_so_grouped',
    'radical': 'radical',
  };

  final Map<String, List<Map<String, String>>> activities = {
    'grouped': [
      {
        'title': 'soccer',
        'image': 'assets/images/soccer.webp',
        'calories': '420Kcal/hr',
      },
      {
        'title': 'basketball',
        'image': 'assets/images/basketball.jpg',
        'calories': '400Kcal/hr',
      },
      {
        'title': 'tennis',
        'image': 'assets/images/tennis.jpg',
        'calories': '400Kcal/hr',
      },
      {
        'title': 'beachvolleyball',
        'image': 'assets/images/bvb.webp',
        'calories': '250Kcal/hr',
      },
      {
        'title': 'table_tennis',
        'image': 'assets/images/tennis.webp',
        'calories': '250Kcal/hr',
      },
    ],
    'not_so_grouped': [
      {
        'title': 'fitness',
        'image': 'assets/images/fitness_station.jpg',
        'calories': '300Kcal/hr',
      },
    ],
    'radical': [
      {
        'title': 'skateboard',
        'image': 'assets/images/skateboarding2.webp',
        'calories': '350Kcal/hr',
      },
      {
        'title': 'bmx',
        'image': 'assets/images/bmx.webp',
        'calories': '350Kcal/hr',
      },
    ],
  };

  void navigateToMenu(String title) {
    Widget? screen;

    switch (title.toLowerCase()) {
      //Grouped
      case 'soccer':
        screen = const SoccerScreen();
        break;
      case 'basketball':
        screen = const BasketballScreen();
        break;
      case 'tennis':
        screen = const TennisScreen();
        break;
      case 'beachvolleyball':
        screen = const BeachVolleyBallScreen();
        break;
      case 'table_tennis':
        screen = const TableTennisScreen();
        break;

      //Not so grouped
      case 'fitness':
        screen = const FitnessScreen();
        break;

      //Radical
      case 'skateboard':
        screen = const SkateboardScreen();
        break;
      case 'bmx':
        screen = const BmxScreen();
        break;
    }

    if (screen != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen!),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('no_menu_available'.tr(namedArgs: {'title': title}))),
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              Expanded(
                child: Container(
                  height: screenHeight * 0.85,
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
                      Text(
                        'find_your_activity'.tr(),
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
                              onTap: () {
                                setState(() => selectedCategoryIndex = index);
                                _pageController.animateToPage(
                                  index,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4.0, vertical: 8),
                                child: Column(
                                  children: [
                                    Text(
                                      categories[index].tr(),
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black
                                            .withAlpha((0.6 * 255).round()),
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
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: categories.length,
                          onPageChanged: (index) {
                            setState(() {
                              selectedCategoryIndex = index;
                            });
                          },
                          itemBuilder: (context, pageIndex) {
                            final key = categoryKeys[categories[pageIndex]];
                            final pageActivities = activities[key] ?? [];

                            return ActivityCategoryPage(
                              activities: pageActivities,
                              onTapActivity: navigateToMenu,
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
