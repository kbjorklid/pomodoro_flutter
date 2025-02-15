import 'package:flutter/material.dart';

/// Base class for widgets that display tomatoes in a grid layout
abstract class TomatoDisplayBase extends StatelessWidget {
  final int maxToDisplay;
  final String title;

  const TomatoDisplayBase({
    super.key,
    required this.maxToDisplay,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tomatoWidth = 50.0;
        final availableWidth = constraints.maxWidth;
        final idealItemsPerRow = (availableWidth / tomatoWidth).floor();

        final rows = idealItemsPerRow >= maxToDisplay
            ? 1
            : idealItemsPerRow >= maxToDisplay / 2
            ? 2
            : 4;

        final itemsPerRow = (maxToDisplay / rows).ceil();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildHeader(context),
            const SizedBox(height: 16),
            if (shouldShowTomatoes) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                  ),
                  child: Column(
                    children: List.generate(rows, (rowIndex) {
                      final startIndex = rowIndex * itemsPerRow;
                      final endIndex = (startIndex + itemsPerRow).clamp(0, maxToDisplay);

                      return SizedBox(
                        height: 60,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(
                            endIndex - startIndex,
                                (index) => buildTomatoItem(context, startIndex + index),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              buildFooter(context),
            ],
          ],
        );
      },
    );
  }

  /// Build the header section of the display
  Widget buildHeader(BuildContext context);

  /// Build a single tomato item
  Widget buildTomatoItem(BuildContext context, int index);

  /// Build the footer section of the display
  Widget buildFooter(BuildContext context);

  /// Whether to show the tomatoes section
  bool get shouldShowTomatoes;
}

/// Widget for selecting a daily goal of pomodoros
class PomodoroGoalSelector extends TomatoDisplayBase {
  final int? selectedGoal;
  final Function(int?) onChanged;

  const PomodoroGoalSelector({
    super.key,
    required this.selectedGoal,
    required this.onChanged,
    int maxGoal = 20,
  }) : super(maxToDisplay: maxGoal, title: 'Daily Pomodoro Goal');

  @override
  Widget buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Switch(
          value: selectedGoal != null,
          onChanged: (enabled) {
            onChanged(enabled ? 1 : null);
          },
        ),
      ],
    );
  }

  @override
  Widget buildTomatoItem(BuildContext context, int index) {
    return AnimatedTomato(
      number: index + 1,
      isSelected: selectedGoal != null && (index + 1) <= (selectedGoal ?? 0),
      onTap: () => onChanged(index + 1),
    );
  }

  @override
  Widget buildFooter(BuildContext context) {
    return Text(
      selectedGoal == 1
          ? '1 pomodoro per day'
          : '$selectedGoal pomodoros per day',
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }

  @override
  bool get shouldShowTomatoes => selectedGoal != null;
}

/// Widget for displaying progress towards daily pomodoro goal
class PomodoroProgressDisplay extends TomatoDisplayBase {
  final int goalCount;
  final int achievedCount;

  const PomodoroProgressDisplay({
    super.key,
    required this.goalCount,
    required this.achievedCount,
  }) : super(
    maxToDisplay: achievedCount > goalCount ? achievedCount : goalCount,
    title: 'Daily Progress',
  );

  @override
  Widget buildHeader(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium,
    );
  }

  @override
  Widget buildTomatoItem(BuildContext context, int index) {
    return AnimatedTomato(
      number: index + 1,
      isSelected: index < achievedCount,
      onTap: () {}, // No interaction in progress display
      interactive: false,
    );
  }

  @override
  Widget buildFooter(BuildContext context) {
    if (achievedCount >= goalCount) {
      return Text(
        'Goal achieved! ($achievedCount/${goalCount})',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }
    return Text(
      '$achievedCount/$goalCount pomodoros completed',
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }

  @override
  bool get shouldShowTomatoes => true;
}

class AnimatedTomato extends StatefulWidget {
  final int number;
  final bool isSelected;
  final VoidCallback onTap;
  final bool interactive;

  const AnimatedTomato({
    super.key,
    required this.number,
    required this.isSelected,
    required this.onTap,
    this.interactive = true,
  });

  @override
  State<AnimatedTomato> createState() => _AnimatedTomatoState();
}

class _AnimatedTomatoState extends State<AnimatedTomato>
    with SingleTickerProviderStateMixin {
  bool isHovered = false;
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AnimatedTomato oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _controller.forward().then((_) => _controller.reverse());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child = Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(
          'assets/images/tomato.png',
          height: 40,
          width: 40,
          color: widget.isSelected
              ? null
              : Theme.of(context).colorScheme.outline.withOpacity(0.5),
          colorBlendMode: widget.isSelected ? null : BlendMode.srcIn,
        ),
        Transform.translate(
          offset: const Offset(0, 3),
          child: Text(
            widget.number.toString(),
            style: TextStyle(
              color: widget.isSelected
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );

    if (!widget.interactive) {
      return child;
    }

    child = MouseRegion(
      onEnter: (_) => setState(() {
        isHovered = true;
        if (!widget.isSelected) _controller.forward();
      }),
      onExit: (_) => setState(() {
        isHovered = false;
        if (!widget.isSelected) _controller.reverse();
      }),
      child: GestureDetector(
        onTap: () {
          widget.onTap();
          _controller.forward().then((_) => _controller.reverse());
        },
        child: Tooltip(
          message: '${widget.number} pomodoros',
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 200),
              tween: Tween<double>(
                begin: 0.0,
                end: isHovered ? 0.5 : 0.0,
              ),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, -value * 10),
                  child: child,
                );
              },
              child: child,
            ),
          ),
        ),
      ),
    );

    return child;
  }
}