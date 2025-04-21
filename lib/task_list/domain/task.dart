import 'package:pomodoro_app2/core/domain/ddd_interfaces.dart';

/// Represents a task item that can be compared for sorting.
class Task extends Entity<TaskId> implements Comparable<Task> {
  final String title;
  final DateTime createdAt;
  DateTime? _completedAt;

  Task(
    super.id, {
    required this.title,
    required this.createdAt,
    DateTime? completedAt,
  }) : _completedAt = completedAt;

  factory Task.create({
    required String title,
    DateTime? createdAt,
  }) {
    return Task(
      TaskId.generate(),
      title: title,
      createdAt: createdAt ?? DateTime.now(),
      completedAt: null,
    );
  }

  bool get isCompleted => _completedAt != null;
  DateTime? get completedAt => _completedAt;

  void markComplete([DateTime? completedTime]) {
    _completedAt = completedTime ?? DateTime.now();
  }

  void markIncomplete() {
    _completedAt = null;
  }

  @override
  int compareTo(Task other) {
    return createdAt.compareTo(other.createdAt);
  }

  @override
  String toString() {
    return 'Task{id: $id, title: $title, createdAt: $createdAt, '
        'completedAt: $_completedAt}';
  }
}

class TaskId extends EntityUniqueId {
  TaskId.generate() : super.generate();
  TaskId.fromString(super.id) : super.fromString();
}
