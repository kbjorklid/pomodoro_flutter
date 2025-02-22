import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/daily_goal/presentation/daily_goal_widgets.dart';
import 'package:pomodoro_app2/settings/presentation/providers/settings_repository_provider.dart';
import 'package:pomodoro_app2/settings/presentation/widgets/duration_slider.dart';
import 'package:pomodoro_app2/settings/presentation/widgets/settings_list_tile.dart';
import 'package:pomodoro_app2/settings/presentation/widgets/sound_selector.dart';
import 'package:pomodoro_app2/settings/presentation/widgets/workday_timespan_slider.dart';
import 'package:pomodoro_app2/sound/domain/notification_sound.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Duration workDuration = const Duration(minutes: 25);
  Duration shortRestDuration = const Duration(minutes: 5);
  Duration longRestDuration = const Duration(minutes: 15);
  NotificationSound selectedSound = NotificationSound.ding;
  bool pauseEnabled = true;
  TimeOfDay typicalWorkDayStart = const TimeOfDay(hour: 8, minute: 0);
  Duration typicalWorkDayLength = const Duration(hours: 8);
  bool isLoading = true;
  bool alwaysShowWorkdayTimespanInTimeline = false;
  int? dailyPomodoroGoal;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final repository = ref.read(settingsRepositoryProvider);
    final loadedWorkDuration = await repository.getWorkDuration();
    final loadedShortRestDuration = await repository.getShortRestDuration();
    final loadedLongRestDuration = await repository.getLongRestDuration();
    final loadedSelectedSound = await repository.getTimerEndSound();
    final loadedPauseEnabled = await repository.isPauseEnabled();
    final loadedTypicalWorkDayStart = await repository.getTypicalWorkDayStart();
    final loadedTypicalWorkDayLength =
        await repository.getTypicalWorkDayLength();
    final loadedAlwaysShowWorkdayTimespanInTimeline =
        await repository.isAlwaysShowWorkdayTimespanInTimeline();
    final loadedDailyPomodoroGoal = await repository.getDailyPomodoroGoal();

    setState(() {
      workDuration = loadedWorkDuration;
      shortRestDuration = loadedShortRestDuration;
      longRestDuration = loadedLongRestDuration;
      selectedSound = loadedSelectedSound;
      pauseEnabled = loadedPauseEnabled;
      typicalWorkDayStart = loadedTypicalWorkDayStart;
      typicalWorkDayLength = loadedTypicalWorkDayLength;
      alwaysShowWorkdayTimespanInTimeline =
          loadedAlwaysShowWorkdayTimespanInTimeline;
      dailyPomodoroGoal = loadedDailyPomodoroGoal;
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

  Future<void> _saveShortRestDuration(Duration duration) async {
    final repository = ref.read(settingsRepositoryProvider);
    await repository.setShortRestDuration(duration);
    setState(() {
      shortRestDuration = duration;
    });
    ref.invalidate(settingsRepositoryProvider);
  }

  Future<void> _saveLongRestDuration(Duration duration) async {
    final repository = ref.read(settingsRepositoryProvider);
    await repository.setLongRestDuration(duration);
    setState(() {
      longRestDuration = duration;
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

  Future<void> _saveDailyPomodoroGoal(int? goal) async {
    final repository = ref.read(settingsRepositoryProvider);
    await repository.setDailyPomodoroGoal(goal);
    setState(() {
      dailyPomodoroGoal = goal;
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

  Future<void> _saveAlwaysShowWorkdayTimespanInTimeline(bool alwaysShow) async {
    final repository = ref.read(settingsRepositoryProvider);
    await repository.setAlwaysShowWorkdayTimespanInTimeline(alwaysShow);
    setState(() {
      alwaysShowWorkdayTimespanInTimeline = alwaysShow;
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
                    label: 'Short Rest Duration',
                    duration: shortRestDuration,
                    minDuration: const Duration(minutes: 1),
                    maxDuration: const Duration(minutes: 30),
                    onChanged: _saveShortRestDuration,
                  ),
                  const SizedBox(height: 16),
                  DurationSlider(
                    label: 'Long Rest Duration',
                    duration: longRestDuration,
                    minDuration: const Duration(minutes: 5),
                    maxDuration: const Duration(minutes: 60),
                    onChanged: _saveLongRestDuration,
                  ),
                  const SizedBox(height: 16),
                  SettingsListTile(
                    title: 'Pause enabled',
                    subtitle: 'Show pause button on timer screen',
                    trailing: Switch(
                      value: pauseEnabled,
                      onChanged: _savePauseEnabled,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SettingsListTile(
                    title: 'Auto-switch timer',
                    subtitle:
                        'Automatically switch between work and rest timers when the current timer is completed.',
                    trailing: Switch(
                      value: true, // Default value
                      onChanged: _saveAutoSwitchTimer,
                    ),
                  ),
                ],
              ),
              _buildCard(
                title: 'Notification Settings',
                children: [
                  SettingsListTile(
                    title: 'Timer end sound',
                    trailing: SoundSelector(
                      selectedSound: selectedSound,
                      onChanged: _saveSelectedSound,
                    ),
                  ),
                ],
              ),
              _buildCard(
                title: 'Work Schedule',
                children: [
                  WorkdayTimespanSlider(
                    startTime: typicalWorkDayStart,
                    dayLength: typicalWorkDayLength,
                    onStartTimeChanged: _saveTypicalWorkDayStart,
                    onDayLengthChanged: _saveTypicalWorkDayLength,
                  ),
                  const SizedBox(height: 16),
                  SettingsListTile(
                    title: 'Always show workday timespan in timeline',
                    subtitle:
                        'If enabled, timeline bar will always show typical workday timespan, even if it is outside of the timer session history range.',
                    trailing: Switch(
                      value: alwaysShowWorkdayTimespanInTimeline,
                      onChanged: _saveAlwaysShowWorkdayTimespanInTimeline,
                    ),
                  ),
                ],
              ),
              _buildCard(
                title: 'Daily Goal',
                children: [
                  PomodoroGoalSelector(
                    selectedGoal: dailyPomodoroGoal,
                    onChanged: _saveDailyPomodoroGoal,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveAutoSwitchTimer(bool enabled) async {
    final repository = ref.read(settingsRepositoryProvider);
    await repository.setAutoSwitchTimer(enabled);
    setState(() {
      // No need to update local state, as it's not displayed directly
    });
    ref.invalidate(settingsRepositoryProvider);
  }
}
