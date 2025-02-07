import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/settings/presentation/providers/settings_repository_provider.dart';
import 'package:pomodoro_app2/settings/presentation/widgets/duration_slider.dart';
import 'package:pomodoro_app2/settings/presentation/widgets/sound_selector.dart';
import 'package:pomodoro_app2/sound/domain/notification_sound.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Duration workDuration = const Duration(minutes: 25);
  Duration restDuration = const Duration(minutes: 5);
  NotificationSound selectedSound = NotificationSound.ding;
  bool pauseEnabled = true;
  TimeOfDay typicalWorkDayStart = const TimeOfDay(hour: 8, minute: 0);
  Duration typicalWorkDayLength = const Duration(hours: 8);
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
    final loadedSelectedSound = await repository.getTimerEndSound();
    final loadedPauseEnabled = await repository.isPauseEnabled();
    final loadedTypicalWorkDayStart = await repository.getTypicalWorkDayStart();
    final loadedTypicalWorkDayLength =
        await repository.getTypicalWorkDayLength();

    setState(() {
      workDuration = loadedWorkDuration;
      restDuration = loadedRestDuration;
      selectedSound = loadedSelectedSound;
      pauseEnabled = loadedPauseEnabled;
      typicalWorkDayStart = loadedTypicalWorkDayStart;
      typicalWorkDayLength = loadedTypicalWorkDayLength;
      isLoading = false;
    });
  }

  Future<void> _saveWorkDuration(Duration duration) async {
    final repository = ref.read(settingsRepositoryProvider);
    await repository.setWorkDuration(duration);
    setState(() {
      workDuration = duration;
    });
    ref.invalidate(settingsRepositoryProvider);
  }

  Future<void> _saveSelectedSound(NotificationSound? sound) async {
    if (sound == null) return;
    final repository = ref.read(settingsRepositoryProvider);
    await repository.setTimerEndSound(sound);
    setState(() {
      selectedSound = sound;
    });
    ref.invalidate(settingsRepositoryProvider);
  }

  Future<void> _saveRestDuration(Duration duration) async {
    final repository = ref.read(settingsRepositoryProvider);
    await repository.setRestDuration(duration);
    setState(() {
      restDuration = duration;
    });
    ref.invalidate(settingsRepositoryProvider);
  }

  Future<void> _saveTypicalWorkDayStart(TimeOfDay time) async {
    final repository = ref.read(settingsRepositoryProvider);
    await repository.setTypicalWorkDayStart(time);
    setState(() {
      typicalWorkDayStart = time;
    });
    ref.invalidate(settingsRepositoryProvider);
  }

  Future<void> _saveTypicalWorkDayLength(Duration duration) async {
    final repository = ref.read(settingsRepositoryProvider);
    await repository.setTypicalWorkDayLength(duration);
    setState(() {
      typicalWorkDayLength = duration;
    });
    ref.invalidate(settingsRepositoryProvider);
  }

  Future<void> _savePauseEnabled(bool enabled) async {
    final repository = ref.read(settingsRepositoryProvider);
    await repository.setPauseEnabled(enabled);
    setState(() {
      pauseEnabled = enabled;
    });
    ref.invalidate(settingsRepositoryProvider);
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(title),
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCard(
                title: 'Timer Settings',
                children: [
                  DurationSlider(
                    label: 'Work Duration',
                    duration: workDuration,
                    minDuration: const Duration(minutes: 1),
                    maxDuration: const Duration(minutes: 60),
                    onChanged: _saveWorkDuration,
                  ),
                  const SizedBox(height: 16),
                  DurationSlider(
                    label: 'Rest Duration',
                    duration: restDuration,
                    minDuration: const Duration(minutes: 1),
                    maxDuration: const Duration(minutes: 30),
                    onChanged: _saveRestDuration,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text(
                      'Pause enabled',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: const Text(
                      'Show pause button on timer screen',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    trailing: Switch(
                      value: pauseEnabled,
                      onChanged: _savePauseEnabled,
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
              _buildCard(
                title: 'Notification Settings',
                children: [
                  SoundSelector(
                    selectedSound: selectedSound,
                    onChanged: _saveSelectedSound,
                  ),
                ],
              ),
              _buildCard(
                title: 'Work Schedule',
                children: [
                  ListTile(
                    title: const Text('Typical Work Day Start'),
                    trailing: TextButton(
                      child: Text(typicalWorkDayStart.format(context)),
                      onPressed: () async {
                        final TimeOfDay? newTime = await showTimePicker(
                          context: context,
                          initialTime: typicalWorkDayStart,
                        );
                        if (newTime != null) {
                          _saveTypicalWorkDayStart(newTime);
                        }
                      },
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 16),
                  DurationSlider(
                    label: 'Typical Work Day Length',
                    duration: typicalWorkDayLength,
                    minDuration: const Duration(hours: 1),
                    maxDuration: const Duration(hours: 16),
                    onChanged: _saveTypicalWorkDayLength,
                    step: const Duration(minutes: 15),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}