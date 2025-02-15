import 'package:flutter/material.dart';

class PomodoroGoalSelector extends StatelessWidget {
  final int? selectedGoal;
  final Function(int?) onChanged;
  final int maxGoal;

  const PomodoroGoalSelector({
    super.key,
    required this.selectedGoal,
    required this.onChanged,
    this.maxGoal = 20,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tomatoWidth = 50.0;
        final availableWidth = constraints.maxWidth;
        final idealItemsPerRow = (availableWidth / tomatoWidth).floor();

        final rows = idealItemsPerRow >= maxGoal
            ? 1
            : idealItemsPerRow >= maxGoal / 2
            ? 2
            : 4;

        final itemsPerRow = (maxGoal / rows).ceil();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daily Pomodoro Goal',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Switch(
                  value: selectedGoal != null,
                  onChanged: (enabled) {
                    onChanged(enabled ? 1 : null);
                  },
                ),
              ],
            ),
            if (selectedGoal != null) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                  ),
                  child: Column(
                    children: List.generate(rows, (rowIndex) {
                      final startIndex = rowIndex * itemsPerRow;
                      final endIndex = (startIndex + itemsPerRow).clamp(0, maxGoal);

                      return SizedBox(
                        height: 60,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(
                            endIndex - startIndex,
                                (index) {
                              final number = startIndex + index + 1;
                              return AnimatedTomato(
                                number: number,
                                isSelected: selectedGoal != null && number <= (selectedGoal  ?? 0),
                                onTap: () => onChanged(number),
                              );
                            },
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                selectedGoal == 1
                    ? '1 pomodoro per day'
                    : '$selectedGoal pomodoros per day',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        );
      },
    );
  }
}

class AnimatedTomato extends StatefulWidget {
  final int number;
  final bool isSelected;
  final VoidCallback onTap;

  const AnimatedTomato({
    super.key,
    required this.number,
    required this.isSelected,
    required this.onTap,
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
    return MouseRegion(
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
            child:  TweenAnimationBuilder<double>(
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
              child: Stack(
              alignment: Alignment.center,
              children: [
                // The tomato image with hover effect
               Image.asset(
                    'assets/images/tomato.png',
                    height: 40,
                    width: 40,
                    color: widget.isSelected
                        ? null
                        : Theme.of(context).colorScheme.outline.withOpacity(0.5),
                    colorBlendMode: widget.isSelected ? null : BlendMode.srcIn,
                  ),

                // The number
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
              ],),
            ),
          ),
        ),
      ),
    );
  }
}