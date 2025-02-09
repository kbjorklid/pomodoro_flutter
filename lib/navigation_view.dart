import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/debug_tools/presentation/debug_tools_screen.dart';
import 'package:pomodoro_app2/settings/presentation/settings_screen.dart';
import 'package:pomodoro_app2/timer/presentation/widgets/timer_display.dart';

class NavigationView extends ConsumerStatefulWidget {
  const NavigationView({super.key});

  @override
  ConsumerState<NavigationView> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<NavigationView> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro Timer'),
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.none,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.timer),
                selectedIcon: Icon(Icons.timer),
                label: Text('Timer'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                selectedIcon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
              if (kDebugMode)
                NavigationRailDestination(
                  icon: Icon(Icons.bug_report),
                  selectedIcon: Icon(Icons.bug_report),
                  label: Text('Debug Tools'),
                ),
            ].whereType<NavigationRailDestination>().toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            flex: 10,
            child: _buildSelectedView(),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedView() {
    switch (_selectedIndex) {
      case 0:
        return const TimerDisplay();
      case 1:
        return const SettingsScreen();
      case 2:
        return kDebugMode ? const DebugToolsScreen() : const SizedBox.shrink(); // Or some error view
      default:
        return const TimerDisplay(); // Default to timer view
    }
  }
}
