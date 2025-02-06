import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app2/timer/presentation/widgets/timercontrols/start_button.dart';
import 'package:pomodoro_app2/timer/presentation/widgets/timercontrols/pause_resume_button.dart';
import 'package:pomodoro_app2/timer/presentation/widgets/timercontrols/stop_button.dart';
import 'package:pomodoro_app2/settings/presentation/providers/settings_repository_provider.dart';

class TimerControls extends ConsumerWidget {
  const TimerControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsRepositoryProvider);

    return FutureBuilder<bool>(
      future: settings.isPauseEnabled(),
      builder: (context, snapshot) {
        final pauseEnabled = snapshot.data ?? true; // Default to true while loading

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StartButton(),
            const SizedBox(width: 16),
            if (pauseEnabled) ...[
              PauseResumeButton(),
              const SizedBox(width: 16),
            ],
            StopButton(),
          ],
        );
      },
    );
  }
}
