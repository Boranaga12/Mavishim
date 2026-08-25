import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cycle_provider.dart';
import '../providers/game_provider.dart';
import 'cycle/cycle_calendar.dart';
import 'cycle/cycle_dashboard.dart';
import 'games/games_hub.dart';
import 'love_notes/love_notes_view.dart';
import 'settings/settings_view.dart';
import '../l10n/generated/app_localizations.dart';
import '../widgets/tap_effects_layer.dart';

class MainNavigationView extends StatefulWidget {
  const MainNavigationView({super.key});

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  int _currentIndex = 0;
  String? _lastShownError;
  late final List<Widget?> _pages;

  @override
  void initState() {
    super.initState();
    _pages = List<Widget?>.filled(5, null);
    _pages[0] = _createPage(0);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final cycleError = context.select<CycleProvider, String?>(
      (value) => value.errorMessage,
    );
    final gameError = context.select<GameProvider, String?>(
      (value) => value.errorMessage,
    );
    _scheduleErrorMessage(cycleError ?? gameError);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: List.generate(
          _pages.length,
          (index) => _pages[index] ?? const SizedBox.shrink(),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        onDestinationSelected: (index) {
          if (index == _currentIndex) return;
          setState(() {
            _currentIndex = index;
            _pages[index] ??= _createPage(index);
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.spa_outlined),
            selectedIcon: const Icon(Icons.spa),
            label: strings.cycleTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month),
            label: strings.calendarTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.sports_esports_outlined),
            selectedIcon: const Icon(Icons.sports_esports),
            label: strings.gamesTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_border),
            selectedIcon: const Icon(Icons.favorite),
            label: strings.notesTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: strings.settingsTab,
          ),
        ],
      ),
    );
  }

  Widget _createPage(int index) => switch (index) {
    0 => const TapEffectsLayer(
      surfaceId: 'cycle-dashboard',
      child: CycleDashboard(),
    ),
    1 => const TapEffectsLayer(
      surfaceId: 'calendar',
      child: CycleCalendarView(),
    ),
    2 => const TapEffectsLayer(surfaceId: 'games-hub', child: GamesHubView()),
    3 => const TapEffectsLayer(surfaceId: 'notes', child: LoveNotesView()),
    _ => const TapEffectsLayer(surfaceId: 'settings', child: SettingsView()),
  };

  void _scheduleErrorMessage(String? message) {
    if (message == null || message == _lastShownError) return;
    _lastShownError = message;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      context.read<CycleProvider>().clearError();
      context.read<GameProvider>().clearError();
      _lastShownError = null;
    });
  }
}
