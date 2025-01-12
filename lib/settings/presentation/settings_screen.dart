import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/settings/presentation/providers/settings_repository_provider.dart';

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
            Text('Work Duration: ${workDuration.inMinutes} minutes'),
            Slider(
              value: workDuration.inMinutes.toDouble(),
              min: 1,
              max: 60,
              divisions: 59,
              label: '${workDuration.inMinutes} minutes',
              onChanged: (value) {
                _saveWorkDuration(Duration(minutes: value.toInt()));
              },
            ),
            const SizedBox(height: 20),
            Text('Rest Duration: ${restDuration.inMinutes} minutes'),
            Slider(
              value: restDuration.inMinutes.toDouble(),
              min: 1,
              max: 30,
              divisions: 29,
              label: '${restDuration.inMinutes} minutes',
              onChanged: (value) {
                _saveRestDuration(Duration(minutes: value.toInt()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
