import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:move_young/models/activity.dart';
import 'package:move_young/widgets/activity_category_page.dart';
import 'package:move_young/theme/tokens.dart';

// sport screens
import 'package:move_young/screens/activities/sports_screens/soccer.dart';
import 'package:move_young/screens/activities/sports_screens/basketball.dart';
import 'package:move_young/screens/activities/sports_screens/tennis.dart';
import 'package:move_young/screens/activities/sports_screens/beachvolleyball.dart';
import 'package:move_young/screens/activities/sports_screens/table_tennis.dart';
import 'package:move_young/screens/activities/sports_screens/fitness.dart';
import 'package:move_young/screens/activities/sports_screens/climbing.dart';
import 'package:move_young/screens/activities/sports_screens/skateboard.dart';
import 'package:move_young/screens/activities/sports_screens/bmx.dart';

typedef ScreenBuilder = Widget Function();

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  int selectedCategoryIndex = 0;
  late final PageController _pageController;

  double _dragDx = 0; // track horizontal drag distance on the tabs row
  bool _animating = false;

  Future<void> _goToPage(int index) async {
    if (!_pageController.hasClients) return;

    // Use the controller’s page (more reliable than selectedCategoryIndex)
    final current = _pageController.page?.round() ?? selectedCategoryIndex;

    if (_animating || index == current) return;
    _animating = true;
    try {
      await _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } finally {
      _animating = false;
    }
  }

  final List<String> categories = const ['grouped', 'individual', 'intensive'];

  final Map<String, List<Activity>> activities = const {
    'grouped': [
      Activity(
        key: 'soccer',
        image: 'assets/images/soccer.webp',
        kcalPerHour: 420,
        align: Alignment(0, -0.4),
      ),
      Activity(
        key: 'basketball',
        image: 'assets/images/basketball.jpg',
        kcalPerHour: 400,
        align: Alignment(0, -0.4),
      ),
      Activity(
        key: 'tennis',
        image: 'assets/images/tennis.jpg',
        kcalPerHour: 420,
        align: Alignment(0, -0.4),
      ),
      Activity(
        key: 'beachvolleyball',
        image: 'assets/images/bvb.webp',
        kcalPerHour: 250,
        align: Alignment(0, -0.4),
      ),
      Activity(
        key: 'table_tennis',
        image: 'assets/images/tennis.webp',
        kcalPerHour: 250,
        align: Alignment(0, -0.4),
      ),
    ],
    'individual': [
      Activity(
        key: 'fitness',
        image: 'assets/images/fitness_station.jpg',
        kcalPerHour: 300,
        align: Alignment(0, -0.4),
      ),
      Activity(
        key: 'climbing',
        image: 'assets/images/climbing.webp',
        kcalPerHour: 300,
        align: Alignment(0, -0.4),
      ),
      Activity(
        key: 'canoeing',
        image: 'assets/images/canoeing.webp',
        kcalPerHour: 300,
        align: Alignment(0, 0.02),
      ),
    ],
    'intensive': [
      Activity(
        key: 'skateboard',
        image: 'assets/images/skateboarding2.webp',
        kcalPerHour: 300,
        align: Alignment(0, -0.4),
      ),
      Activity(
        key: 'bmx',
        image: 'assets/images/bmx.webp',
        kcalPerHour: 350,
        align: Alignment(0, -0.4),
      ),
      Activity(
        key: 'motocross',
        image: 'assets/images/motocross.webp',
        kcalPerHour: 350,
        align: Alignment(0, -0.1),
      ),
    ],
  };

  final Map<String, ScreenBuilder> _activityRoutes = {
    // grouped
    'soccer': () => const SoccerScreen(),
    'basketball': () => const BasketballScreen(),
    'tennis': () => const TennisScreen(),
    'beachvolleyball': () => const BeachVolleyBallScreen(),
    'table_tennis': () => const TableTennisScreen(),

    // individual
    'fitness': () => const FitnessScreen(),
    'climbing': () => const ClimbingScreen(),

    // intensive
    'skateboard': () => const SkateboardScreen(),
    'bmx': () => const BmxScreen(),

    // canoeing & motocross intentionally not mapped to show snackbar fallback
  };

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: selectedCategoryIndex);

    // (Optional) precache first page images for snappier paint.
    WidgetsBinding.instance.addPostFrameCallback((_) => _prefetchImagesFor(0));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void navigateToMenu(String key) {
    HapticFeedback.lightImpact();

    final builder = _activityRoutes[key];
    assert(() {
      if (builder == null) {
        debugPrint('No screen mapped for activity: $key');
      }
      return true;
    }());
    if (builder != null) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => builder()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('no_menu_available'.tr(namedArgs: {'title': key})),
        ),
      );
    }
  }

  void _prefetchImagesFor(int pageIndex) {
    if (pageIndex < 0 || pageIndex >= categories.length) return;
    final key = categories[pageIndex];
    final list = activities[key] ?? const <Activity>[];
    for (final a in list) {
      precacheImage(AssetImage(a.image), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pagePhysics = Theme.of(context).platform == TargetPlatform.iOS
        ? const BouncingScrollPhysics()
        : const ClampingScrollPhysics();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Activities'.tr(), // or keep literal "Activities"
        ),
        centerTitle: true,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.blackIcon,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark, // dark status bar icons
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, size: 24),
            tooltip: 'menu'.tr(),
            onPressed: () {
              // TODO: open drawer or bottom sheet
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: AppPaddings.symmHorizontalReg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppHeights.superbig),

              // ✅ REMOVED the Row with the duplicate back arrow and menu

              Expanded(
                child: Container(
                  padding: AppPaddings.allBig,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppRadius.container),
                    boxShadow: AppShadows.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('find_your_activity'.tr(),
                          style: AppTextStyles.headline),
                      const SizedBox(height: AppHeights.huge),

                      // Category tabs
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onHorizontalDragStart: (_) => _dragDx = 0,
                        onHorizontalDragUpdate: (d) => _dragDx += d.delta.dx,
                        onHorizontalDragEnd: (_) {
                          const threshold =
                              48.0; // px; tweak to 32–64 as you like
                          if (_dragDx <= -threshold) {
                            _goToPage(selectedCategoryIndex +
                                1); // swipe left -> next
                          } else if (_dragDx >= threshold) {
                            _goToPage(selectedCategoryIndex -
                                1); // swipe right -> prev
                          }
                        },
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(categories.length, (index) {
                              final isSelected = index == selectedCategoryIndex;
                              return Padding(
                                padding: AppPaddings.symmHorizontalMedium,
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () {
                                      _prefetchImagesFor(
                                          index); // optional: warms images
                                      _goToPage(
                                          index); // animation will trigger onPageChanged later
                                    },
                                    child: Padding(
                                      padding: AppPaddings.symmSpecial,
                                      child: Column(
                                        children: [
                                          Text(categories[index].tr(),
                                              style: AppTextStyles.special),
                                          AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 180),
                                            curve: Curves.easeInOut,
                                            margin: AppPaddings.topSmall,
                                            width:
                                                isSelected ? AppWidths.huge : 0,
                                            height:
                                                3, // was 2 — thicker underline
                                            color: isSelected
                                                ? AppColors.blackIcon
                                                : Colors.transparent,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppHeights.big),

                      // Pages
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          allowImplicitScrolling: true,
                          physics: pagePhysics,
                          itemCount: categories.length,
                          onPageChanged: (index) {
                            setState(() => selectedCategoryIndex = index);
                            _prefetchImagesFor(index); // current page
                            _prefetchImagesFor(
                                index - 1); // previous page (if exists)
                            _prefetchImagesFor(index + 1);
                          },
                          itemBuilder: (context, pageIndex) {
                            final key = categories[pageIndex];
                            final pageActivities =
                                activities[key] ?? const <Activity>[];

                            return ActivityCategoryPage(
                              key: PageStorageKey('cat_$key'),
                              activities: pageActivities,
                              onTapActivity: navigateToMenu,
                            );
                          },
                        ),
                      ),
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
