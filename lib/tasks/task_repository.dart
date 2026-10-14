import 'task.dart';

abstract interface class TaskRepository {
  Future<List<Task>> fetchTasks();

  Future<void> setTaskCompleted(String id, bool isCompleted);

  Future<void> deleteTask(String id);
}

class InMemoryTaskRepository implements TaskRepository {
  InMemoryTaskRepository()
    : _tasks = [
        const Task(
          id: 'plan-week',
          title: 'Plan the week',
          description: 'Review priorities and make room for focused work.',
        ),
        const Task(
          id: 'review-design',
          title: 'Review the new dashboard design',
          description: 'Share feedback with the product team.',
        ),
        const Task(
          id: 'send-notes',
          title: 'Send meeting notes',
          description: 'Include decisions and the next steps.',
          isCompleted: true,
        ),
      ];

  final List<Task> _tasks;

  @override
  Future<List<Task>> fetchTasks() async => List.unmodifiable(_tasks);

  @override
  Future<void> setTaskCompleted(String id, bool isCompleted) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) {
      throw StateError('Task "$id" no longer exists.');
    }
    _tasks[index] = _tasks[index].copyWith(isCompleted: isCompleted);
  }

  @override
  Future<void> deleteTask(String id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) {
      throw StateError('Task "$id" no longer exists.');
    }
    _tasks.removeAt(index);
  }
}
