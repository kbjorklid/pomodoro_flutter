import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pomodoro_app2/history/presentation/providers/timer_session_repository_provider.dart';
import 'package:pomodoro_app2/timer/presentation/providers/timer_provider.dart';
import 'package:pomodoro_app2/timer/presentation/timer_screen.dart';

void main() async {
  await Hive.initFlutter();

  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

/// Provider to initialize session saving
final _sessionSaverProvider = Provider<void>((ref) {
  final timerService = ref.read(timerProvider);
  final repository = ref.read(timerSessionRepositoryProvider);

  timerService.addSessionListener((session) async {
    await repository.save(session);
  });
});

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize session saver by reading the provider
    ref.read(_sessionSaverProvider);

    return MaterialApp(
      title: 'Pomodoro Timer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          secondary: Colors.teal,
          tertiary: Colors.green,
        ),
        useMaterial3: true,
      ),
      home: const TimerScreen(),
    );
  }
}
