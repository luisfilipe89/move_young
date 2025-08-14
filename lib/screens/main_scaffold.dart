import 'package:flutter/material.dart';
import 'package:move_young/screens/home/home_screen.dart';
import 'package:move_young/screens/activities/activities_screen.dart';
import 'package:move_young/screens/agenda/agenda_screen.dart';

// --- Dummy screens (replace with your real ones if you have them) ---
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

  // One Navigator per tab so each tab keeps its own stack/history
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
      // We’ll handle back manually so predictive back can still work with nested navigators
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // Try pop inside current tab
        final popped = await _currentNavigator.maybePop();
        if (popped) return;

        // At root of a non-Home tab? Switch to Home.
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
          return;
        }

        // At root of Home: allow system to pop the app (do nothing here).
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
              // Re-tapping the same tab pops to its root.
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
          // Add more Home subpages here (e.g., '/sportDetails')
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
        // Add favorites detail routes here if needed.
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
        // Add '/eventDetails' later if you need deeper pages.
        return MaterialPageRoute(
          builder: (_) =>
              AgendaScreen(), // (no const if your constructor isn't const)
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
// Uses your CustomBottomNavBar, but wrapped in a small adapter for clarity.
// If you already call CustomBottomNavBar directly, you can remove this widget.

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.currentIndex, required this.onTap});
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    // If you prefer, replace this with your CustomBottomNavBar directly.
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
        BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Agenda'),
        BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
      ],
    );
  }
}
