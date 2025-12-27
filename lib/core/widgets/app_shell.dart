import 'package:flutter/material.dart';

import '../../features/countdown/presentation/pages/countdown_page.dart';
import '../../features/watchlist/presentation/pages/watchlist_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  late final PageController _pageController;

  final _pages = const <Widget>[CountdownPage(), WatchlistPage()];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onNavTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const BouncingScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onNavTapped,
        backgroundColor: theme.colorScheme.surfaceContainer,
        indicatorColor: theme.colorScheme.primary.withValues(alpha: 0.2),
        destinations: [
          NavigationDestination(
            icon: Icon(
              Icons.timer_outlined,
              color: _currentIndex == 0
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
            selectedIcon: Icon(Icons.timer, color: theme.colorScheme.primary),
            label: 'Countdown',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.movie_outlined,
              color: _currentIndex == 1
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
            selectedIcon: Icon(Icons.movie, color: theme.colorScheme.primary),
            label: 'Watchlist',
          ),
        ],
      ),
    );
  }
}
