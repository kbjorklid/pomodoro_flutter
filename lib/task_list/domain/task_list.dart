import 'package:pomodoro_app2/core/domain/ddd_interfaces.dart';
import 'package:pomodoro_app2/task_list/domain/task.dart';
import 'package:uuid/uuid.dart';

final uuid = Uuid();

class TaskListId extends EntityId<String> {
  TaskListId(super.value);
}

class TaskList extends AggregateRoot<TaskListId> {
  final String title;
  final List<Task> tasks;

  TaskList(
    super.id, {
    required this.title,
    required this.tasks,
  });

  factory TaskList.create({
    required TaskListId id,
    required String title,
  }) {
    return TaskList(
      id,
      title: title,
      tasks: [],
    );
  }

  void addTask(Task task) {
    tasks.add(task);
  }

  void markTaskComplete(TaskId taskId) {
    final task = tasks.firstWhere((task) => task.id == taskId);
    task.markComplete();
  }

  void markTaskIncomplete(TaskId taskId) {
    final task = tasks.firstWhere((task) => task.id == taskId);
    task.markIncomplete();
  }

  void deleteTask(TaskId taskId) {
    tasks.removeWhere((task) => task.id == taskId);
  }

  void move(int fromIndex, int toIndex) {
    if (fromIndex < 0 ||
        fromIndex >= tasks.length ||
        toIndex < 0 ||
        toIndex >= tasks.length) {
      throw RangeError('Invalid index');
    }
    if (fromIndex == toIndex) {
      return;
    }
    final task = tasks.removeAt(fromIndex);
    tasks.insert(toIndex, task);
  }

  void purgeCompleted() {
    tasks.removeWhere((task) => task.isCompleted);
  }

  Task? getFirstNotCompletedTask() {
    try {
      return tasks.firstWhere((task) => !task.isCompleted);
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() {
    return 'TaskList{id: $id, title: $title, tasks: $tasks}';
  }
}
