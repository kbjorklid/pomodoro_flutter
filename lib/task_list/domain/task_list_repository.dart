import 'package:pomodoro_app2/core/domain/ddd_interfaces.dart';
import 'package:pomodoro_app2/task_list/domain/task_list.dart';

abstract class TaskListRepository extends Repository<TaskList, TaskListId> {
  Future<void> save(TaskList taskList);
  Future<void> update(TaskList taskList);
  Future<TaskList> create(TaskList taskList);
  @override
  Future<TaskList?> getById(TaskListId id);
}