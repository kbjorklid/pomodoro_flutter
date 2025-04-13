import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/daily_goal/presentation/daily_goal_widgets.dart';
import 'package:pomodoro_app2/settings/domain/app_theme_mode.dart'; 
import 'package:pomodoro_app2/settings/presentation/providers/settings_repository_provider.dart';
import 'package:pomodoro_app2/settings/presentation/providers/theme_providers.dart'; 
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
  bool autoSwitchTimerEnabled = true;
  bool autoStartRestEnabled = false;
  bool autoStartWorkEnabled = false;
  bool allowOvertimeEnabled = false; 
  AppThemeMode selectedThemeMode = AppThemeMode.dark; 
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
    final loadedAutoSwitchTimer = await repository.getAutoSwitchTimer();
    final loadedAutoStartRest = await repository.isAutoStartRestEnabled();
    final loadedAutoStartWork = await repository.isAutoStartWorkEnabled();
    final loadedAllowOvertime = await repository.isAllowOvertimeEnabled(); 
    
    final loadedThemeMode = await ref.read(themeModeNotifierProvider.future);
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
      autoSwitchTimerEnabled = loadedAutoSwitchTimer;
      autoStartRestEnabled = loadedAutoStartRest;
      autoStartWorkEnabled = loadedAutoStartWork;
      allowOvertimeEnabled = loadedAllowOvertime; 
      selectedThemeMode = loadedThemeMode;
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

  // Save theme mode
  Future<void> _saveThemeMode(AppThemeMode? mode) async {
    if (mode == null) return;
    // Use the provider's method to update the theme
    await ref.read(themeModeNotifierProvider.notifier).updateThemeMode(mode);
    setState(() {
      selectedThemeMode = mode;
    });
    // No need to invalidate settingsRepositoryProvider here as the theme provider handles it
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
                    title: 'Allow overtime for work timer',
                    subtitle: 'Timer continues after work duration ends',
                    trailing: Switch(
                      value: allowOvertimeEnabled,
                      onChanged: _saveAllowOvertime,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SettingsListTile(
                    title: 'Auto-switch timer',
                    subtitle:
                        'Automatically switch between work and rest timers when the current timer is completed.',
                    trailing: Switch(
                      value: autoSwitchTimerEnabled,
                      onChanged: _saveAutoSwitchTimer,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SettingsListTile(
                    title: 'Auto-start Rest Timer',
                    subtitle:
                        'Automatically start rest timer after work timer completes.',
                    trailing: Switch(
                      value: autoStartRestEnabled,
                      // Disable if auto-switch is off OR if allow overtime is on
                      onChanged: (autoSwitchTimerEnabled && !allowOvertimeEnabled)
                          ? _saveAutoStartRest
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SettingsListTile(
                    title: 'Auto-start Work Timer',
                    subtitle:
                        'Automatically start work timer after rest timer completes.',
                    trailing: Switch(
                      value: autoStartWorkEnabled,
                      onChanged:
                          autoSwitchTimerEnabled ? _saveAutoStartWork : null,
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
              _buildCard( // Add Appearance Card
                title: 'Appearance',
                children: [
                  SettingsListTile(
                    title: 'Theme',
                    trailing: SegmentedButton<AppThemeMode>(
                      segments: const [
                        ButtonSegment(
                            value: AppThemeMode.system,
                            label: Text('System'),
                            icon: Icon(Icons.brightness_auto)),
                        ButtonSegment(
                            value: AppThemeMode.light,
                            label: Text('Light'),
                            icon: Icon(Icons.brightness_5)),
                        ButtonSegment(
                            value: AppThemeMode.dark,
                            label: Text('Dark'),
                            icon: Icon(Icons.brightness_4)),
                      ],
                      selected: {selectedThemeMode},
                      onSelectionChanged: (Set<AppThemeMode> newSelection) {
                        _saveThemeMode(newSelection.first);
                      },
                      showSelectedIcon: false, 
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
      autoSwitchTimerEnabled = enabled; // Update state
      // If disabling auto-switch, also disable both auto-start options
      if (!enabled) {
        autoStartRestEnabled = false;
        autoStartWorkEnabled = false;
        // Save the disabled auto-start states as well
        // No need to await here, can run in background
        repository.setAutoStartRest(false);
        repository.setAutoStartWork(false);
      }
    });
    ref.invalidate(settingsRepositoryProvider);
  }

  // New save method for auto-start rest
  Future<void> _saveAutoStartRest(bool enabled) async {
    final repository = ref.read(settingsRepositoryProvider);
    await repository.setAutoStartRest(enabled);
    setState(() {
      autoStartRestEnabled = enabled;
    });
    ref.invalidate(settingsRepositoryProvider);
  }

  // New save method for auto-start work
  Future<void> _saveAutoStartWork(bool enabled) async {
    final repository = ref.read(settingsRepositoryProvider);
    await repository.setAutoStartWork(enabled);
    setState(() {
      autoStartWorkEnabled = enabled;
    });
    ref.invalidate(settingsRepositoryProvider);
  }

  // Add save method for the new setting
  Future<void> _saveAllowOvertime(bool enabled) async {
    final repository = ref.read(settingsRepositoryProvider);
    await repository.setAllowOvertime(enabled);
    setState(() {
      allowOvertimeEnabled = enabled;
      // If overtime is enabled, disable auto-start rest
      if (enabled) {
        autoStartRestEnabled = false;
        // Save the disabled auto-start rest state as well
        // No need to await here, can run in background
        repository.setAutoStartRest(false);
      }
    });
    ref.invalidate(settingsRepositoryProvider); // Invalidate to potentially update dependent providers
  }
}
