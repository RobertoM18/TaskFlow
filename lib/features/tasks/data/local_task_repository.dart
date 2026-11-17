import '../domain/task.dart';
import 'task_repository.dart';
import 'task_service.dart';

class LocalTaskRepository extends TaskRepository {
  LocalTaskRepository(this._service)
    : _tasks = List.unmodifiable(_service.readTasks().map(Task.fromJson));

  final TaskService _service;
  List<Task> _tasks;

  @override
  List<Task> get tasks => _tasks;

  void _save(List<Task> updated) {
    // Publicar solo después de guardar: un fallo no modifica el estado visible.
    _service.writeTasks(updated.map((task) => task.toJson()).toList());
    _tasks = List.unmodifiable(updated);
    notifyListeners();
  }

  @override
  Task createTask({
    required int userId,
    required String description,
    required String priority,
  }) {
    final id =
        _tasks.fold<int>(0, (max, task) => task.id > max ? task.id : max) + 1;
    final task = Task.fromJson({
      'id': id,
      'title': 'Nueva tarea $id',
      'description': description,
      'priority': priority,
      'isCompleted': false,
      'userId': userId,
    });
    _save([..._tasks, task]);
    return task;
  }

  @override
  bool setCompleted(int id, bool isCompleted) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index < 0 || _tasks[index].isCompleted == isCompleted) return false;
    final updated = List<Task>.of(_tasks);
    updated[index] = updated[index].copyWith(isCompleted: isCompleted);
    _save(updated);
    return true;
  }
}
