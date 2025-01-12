import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pomodoro_app2/timer/application/timer_notifier.dart';
import 'package:pomodoro_app2/timer/domain/timer_state.dart';
import 'package:pomodoro_app2/timer/domain/timer_type.dart';
import 'package:pomodoro_app2/timer/presentation/providers/timer_provider.dart';
import 'package:pomodoro_app2/timer/presentation/widgets/timercontrols/start_pause_button.dart';

class MockTimerNotifier extends Mock implements TimerNotifier {}

void main() {
  late TimerNotifier timerNotifier;
  late MockTimerNotifier mockNotifier;

  setUp(() {
    timerNotifier = TimerNotifier();
    mockNotifier = MockTimerNotifier();

    // Setup mock state
    when(() => mockNotifier.state).thenReturn(
      const TimerState(
        timerType: TimerType.work,
        remainingSeconds: 1500,
        isRunning: false,
      ),
    );

    // Properly mock the toggleTimer method
    when(() => mockNotifier.toggleTimer()).thenAnswer((_) => Future.value());
  });

  testWidgets('should display Start button when timer is not running', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          timerProvider.overrideWith((ref) => timerNotifier),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: StartPauseButton(),
          ),
        ),
      ),
    );

    expect(find.text('Start'), findsOneWidget);
  });

  testWidgets('should display Pause button when timer is running', (tester) async {
    // Set initial state to running
    timerNotifier.state = const TimerState(
      timerType: TimerType.work,
      remainingSeconds: 1500,
      isRunning: true,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          timerProvider.overrideWith((ref) => timerNotifier),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: StartPauseButton(),
          ),
        ),
      ),
    );

    expect(find.text('Pause'), findsOneWidget);
  });
}
