import 'package:flutter/material.dart';
import 'package:move_young/screens/home/home_screen.dart';
import 'package:move_young/screens/activities/activities_screen.dart';
import 'package:move_young/screens/agenda/agenda_screen.dart';
import 'package:easy_localization/easy_localization.dart';

// --- Dummy screens -
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: const Center(child: Text('Your favorites will appear here')),
    );
  }
}

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wallet')),
      body: const Center(child: Text('Wallet coming soon')),
    );
  }
}

// ---------------------------- Main Scaffold ----------------------------

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final _homeKey = GlobalKey<NavigatorState>();
  final _favoritesKey = GlobalKey<NavigatorState>();
  final _agendaKey = GlobalKey<NavigatorState>();
  final _walletKey = GlobalKey<NavigatorState>();

  NavigatorState get _currentNavigator {
    switch (_currentIndex) {
      case 0:
        return _homeKey.currentState!;
      case 1:
        return _favoritesKey.currentState!;
      case 2:
        return _agendaKey.currentState!;
      case 3:
      default:
        return _walletKey.currentState!;
    }
  }

  void _popToRoot(int index) {
    final keys = [_homeKey, _favoritesKey, _agendaKey, _walletKey];
    keys[index].currentState?.popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final popped = await _currentNavigator.maybePop();
        if (popped) return;

        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
          return;
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: <Widget>[
            _HomeFlow(navigatorKey: _homeKey),
            _FavoritesFlow(navigatorKey: _favoritesKey),
            _AgendaFlow(navigatorKey: _agendaKey),
            _WalletFlow(navigatorKey: _walletKey),
          ],
        ),
        bottomNavigationBar: _BottomBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index == _currentIndex) {
              _popToRoot(index);
            } else {
              setState(() => _currentIndex = index);
            }
          },
        ),
      ),
    );
  }
}

// ---------------------------- Tab Flows ----------------------------

// NOTE: Removed `super.key` from these private widgets to silence the “unused key” warning.

class _HomeFlow extends StatelessWidget {
  const _HomeFlow({required this.navigatorKey});
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/activities':
            return MaterialPageRoute(
              builder: (_) => ActivitiesScreen(),
              settings: settings,
            );

          default:
            return MaterialPageRoute(
              builder: (_) => const HomeScreenNew(),
              settings: settings,
            );
        }
      },
    );
  }
}

class _FavoritesFlow extends StatelessWidget {
  const _FavoritesFlow({required this.navigatorKey});
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => const FavoritesScreen(),
          settings: settings,
        );
      },
    );
  }
}

class _AgendaFlow extends StatelessWidget {
  const _AgendaFlow({required this.navigatorKey});
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => AgendaScreen(),
          settings: settings,
        );
      },
    );
  }
}

class _WalletFlow extends StatelessWidget {
  const _WalletFlow({required this.navigatorKey});
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => const WalletScreen(),
          settings: settings,
        );
      },
    );
  }
}

// ---------------------------- Bottom Bar Wrapper ----------------------------

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.currentIndex, required this.onTap});
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      key: ValueKey(context.locale.languageCode),
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'.tr()),
        BottomNavigationBarItem(
            icon: Icon(Icons.favorite), label: 'favorites'.tr()),
        BottomNavigationBarItem(icon: Icon(Icons.event), label: 'agenda'.tr()),
        BottomNavigationBarItem(icon: Icon(Icons.map), label: 'map'.tr()),
      ],
    );
  }
}
