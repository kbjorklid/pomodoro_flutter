import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/settings/presentation/providers/settings_repository_provider.dart';
import 'package:pomodoro_app2/settings/presentation/widgets/duration_slider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Duration workDuration = const Duration(minutes: 25); // Initialize with default
  Duration restDuration = const Duration(minutes: 5);  // Initialize with default
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final repository = ref.read(settingsRepositoryProvider);
    final loadedWorkDuration = await repository.getWorkDuration();
    final loadedRestDuration = await repository.getRestDuration();
    
    setState(() {
      workDuration = loadedWorkDuration;
      restDuration = loadedRestDuration;
      isLoading = false;
    });
  }

  Future<void> _saveWorkDuration(Duration duration) async {
    final repository = ref.read(settingsRepositoryProvider);
    await repository.setWorkDuration(duration);
    setState(() {
      workDuration = duration;
    });
    // Notify listeners that settings have changed
    ref.invalidate(settingsRepositoryProvider);
  }

  Future<void> _saveRestDuration(Duration duration) async {
    final repository = ref.read(settingsRepositoryProvider);
    await repository.setRestDuration(duration);
    setState(() {
      restDuration = duration;
    });
    // Notify listeners that settings have changed
    ref.invalidate(settingsRepositoryProvider);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DurationSlider(
              label: 'Work Duration',
              duration: workDuration,
              minDuration: const Duration(minutes: 1),
              maxDuration: const Duration(minutes: 60),
              onChanged: _saveWorkDuration,
            ),
            const SizedBox(height: 20),
            DurationSlider(
              label: 'Rest Duration',
              duration: restDuration,
              minDuration: const Duration(minutes: 1),
              maxDuration: const Duration(minutes: 30),
              onChanged: _saveRestDuration,
            ),
          ],
        ),
      ),
    );
  }
}
