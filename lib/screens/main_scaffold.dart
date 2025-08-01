import 'package:flutter/material.dart';
import 'package:move_young/screens/home/home_screen.dart';
import 'package:move_young/screens/activities/activities_screen.dart';
import 'package:move_young/screens/agenda/agenda_screen.dart';
import 'package:move_young/widgets/custom_bottom_nav_bar.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  int _previousIndex = 0;

  final List<Widget> _screens = const [
    HomeScreenNew(),
    ActivitiesScreen(),
    AgendaScreen(),
    Placeholder(),
  ];

  @override
  Widget build(BuildContext context) {
    final isForward = _currentIndex > _previousIndex;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          final offsetAnimation = Tween<Offset>(
            begin: isForward ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(animation);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: _screens[_currentIndex],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (_currentIndex != index) {
            setState(() {
              _previousIndex = _currentIndex;
              _currentIndex = index;
            });
          }
        },
      ),
    );
  }
}
