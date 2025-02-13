import 'package:flutter/material.dart';
import 'package:pomodoro_app2/core/domain/time_formatter.dart';
import 'package:pomodoro_app2/timer/domain/timersession/timer_session.dart';

import '../../../core/presentation/icons.dart';

class TimerDetailsDialog extends StatelessWidget {
  final ClosedTimerSession session;
  final Function(ClosedTimerSession) onDelete;
  final Function(ClosedTimerSession) onUndoDelete;

  const TimerDetailsDialog({
    super.key,
    required this.session,
    required this.onDelete,
    required this.onUndoDelete,
  });

  Icon? get _statusIcon {
    if (session.sessionType.isWork) {
      if (session.isCompleted) {
        return AppIcon.completedWorkSession;
      } else {
        return AppIcon.incompleteWorkSession;
      }
    }
    return null;
  }

  void _handleDelete(BuildContext context) {
    onDelete(session);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Timer session deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            onUndoDelete(session);
          },
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      actionsPadding: const EdgeInsets.all(24),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              AppIcon.timerTypeIcon(session.sessionType, color: Colors.black),
              const SizedBox(width: 8),
              Text(
                _typeText(),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          if (_statusIcon != null) _statusIcon!,
        ],
      ),
      content: SizedBox(
        width: 320,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTimeDetail('Started', session.startedAt),
                  const SizedBox(height: 12),
                  _buildDurationDetail(
                      'Duration', session.durationWithoutPauseTime),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTimeDetail('Ended', session.timerRangeEnd),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        Row(
          children: [
            TextButton.icon(
              onPressed: () => _handleDelete(context),
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              label: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
            const Spacer(),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _typeText() {
    if (session.sessionType.isRest) {
      return "Rest Session";
    }
    return "Work Session";
  }

  Widget _buildTimeDetail(String label, DateTime time) {
    return _buildDetails(
        label, TimeFormatter.timeToHoursMinutesAndSeconds(time));
  }

  Widget _buildDurationDetail(String label, Duration duration) {
    return _buildDetails(label, TimeFormatter.toMinutesAndSeconds(duration));
  }

  Widget _buildDetails(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}