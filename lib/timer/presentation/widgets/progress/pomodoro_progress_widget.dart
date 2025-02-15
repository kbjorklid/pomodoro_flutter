import 'package:flutter/material.dart';

/// Displays the user's Pomodoro progress for the current day using tomato images.
/// Shows grayscale tomatoes for remaining goals and colored tomatoes for completed ones.
class PomodoroProgress extends StatelessWidget {
  final int completedCount;
  final int goalCount;
  final double tomatoSize;

  const PomodoroProgress({
    super.key,
    required this.completedCount,
    required this.goalCount,
    this.tomatoSize = 32.0,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate how many tomatoes to show (max of goal or completed)
    final displayCount = completedCount > goalCount ? completedCount : goalCount;

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: List.generate(displayCount, (index) {
        final isCompleted = index < completedCount;
        return _TomatoIcon(
          size: tomatoSize,
          isCompleted: isCompleted,
        );
      }),
    );
  }
}

/// A single tomato icon that can be either colored or grayscale
class _TomatoIcon extends StatelessWidget {
  static final String imagePath = "assets/images/tomato.png";
  final double size;
  final bool isCompleted;

  const _TomatoIcon({
    required this.size,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ColorFiltered(
        colorFilter: isCompleted
            ? const ColorFilter.mode(
          Colors.transparent,
          BlendMode.saturation,
        )
            : const ColorFilter.matrix(<double>[
          0.2126, 0.7152, 0.0722, 0, 0, // Red channel
          0.2126, 0.7152, 0.0722, 0, 0, // Green channel
          0.2126, 0.7152, 0.0722, 0, 0, // Blue channel
          0, 0, 0, 1, 0, // Alpha channel
        ]),
        child: Image.asset(
          imagePath,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}