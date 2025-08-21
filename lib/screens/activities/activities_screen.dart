import 'package:flutter/material.dart';
import 'package:move_young/screens/activities/sports_screens/soccer.dart';
import 'package:move_young/screens/activities/sports_screens/basketball.dart';
import 'package:move_young/screens/activities/sports_screens/tennis.dart';
import 'package:move_young/screens/activities/sports_screens/beachvolleyball.dart';
import 'package:move_young/screens/activities/sports_screens/table_tennis.dart';
import 'package:move_young/screens/activities/sports_screens/fitness.dart';
import 'package:move_young/screens/activities/sports_screens/climbing.dart';
import 'package:move_young/screens/activities/sports_screens/skateboard.dart';
import 'package:move_young/screens/activities/sports_screens/bmx.dart';
import 'package:move_young/widgets/activity_category_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:move_young/theme/tokens.dart';

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

  final List<String> categories = ['grouped', 'individual', 'intensive'];

  final Map<String, String> categoryKeys = {
    'grouped': 'grouped',
    'individual': 'individual',
    'intensive': 'intensive',
  };

  final Map<String, List<Map<String, String>>> activities = {
    'grouped': [
      {
        'title': 'soccer',
        'image': 'assets/images/soccer.webp',
        'calories': '420Kcal/hr',
        'align': '0,-0.4'
      },
      {
        'title': 'basketball',
        'image': 'assets/images/basketball.jpg',
        'calories': '400Kcal/hr',
        'align': '0,-0.4'
      },
      {
        'title': 'tennis',
        'image': 'assets/images/tennis.jpg',
        'calories': '400Kcal/hr',
        'align': '0,-0.4'
      },
      {
        'title': 'beachvolleyball',
        'image': 'assets/images/bvb.webp',
        'calories': '250Kcal/hr',
        'align': '0,-0.4'
      },
      {
        'title': 'table_tennis',
        'image': 'assets/images/tennis.webp',
        'calories': '250Kcal/hr',
      },
    ],
    'individual': [
      {
        'title': 'fitness',
        'image': 'assets/images/fitness_station.jpg',
        'calories': '300Kcal/hr',
        'align': '0,-0.4'
      },
      {
        'title': 'climbing',
        'image': 'assets/images/climbing.webp',
        'calories': '300Kcal/hr',
        'align': '0,-0.4'
      },
      {
        'title': 'canoeing',
        'image': 'assets/images/canoeing.webp',
        'calories': '300Kcal/hr',
        'align': '0,0.2'
      }
    ],
    'intensive': [
      {
        'title': 'skateboard',
        'image': 'assets/images/skateboarding2.webp',
        'calories': '350Kcal/hr',
        'align': '0,-0.4'
      },
      {
        'title': 'bmx',
        'image': 'assets/images/bmx.webp',
        'calories': '350Kcal/hr',
        'align': '0,-0.4'
      },
      {
        'title': 'motocross',
        'image': 'assets/images/motocross.webp',
        'calories': '350Kcal/hr',
        'align': '0,-0.1'
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
      case 'climbing':
        screen = const ClimbingScreen();
        break;
      //Intensive
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
        const Text('🔥', style: AppTextStyles.body),
        const SizedBox(width: AppWidths.small),
        Text(text, style: AppTextStyles.small),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: AppPaddings.symmHorizontalReg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppHeights.superbig),
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
              const SizedBox(height: AppHeights.superbig),
              Expanded(
                child: Container(
                  padding: AppPaddings.allSuperBig,
                  decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius:
                          BorderRadius.circular(AppRadius.bigContainer),
                      boxShadow: AppShadows.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('find_your_activity'.tr(),
                          style: AppTextStyles.huge),
                      const SizedBox(height: AppHeights.superHuge),
                      Row(
                        children: List.generate(categories.length, (index) {
                          final isSelected = index == selectedCategoryIndex;
                          return Padding(
                            padding: AppPaddings.rightSuperBig,
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
                                padding: AppPaddings.symmSpecial,
                                child: Column(
                                  children: [
                                    Text(categories[index].tr(),
                                        style: AppTextStyles.special),
                                    if (isSelected)
                                      Container(
                                        margin: AppPaddings.topSmall,
                                        width: AppWidths.huge,
                                        height: 2,
                                        color: AppColors.blackIcon,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: AppHeights.superHuge),
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
