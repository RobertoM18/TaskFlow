import 'demo_tasks.dart';
import 'task_service.dart';

/// Simula el intercambio de objetos JSON en memoria, sin peticiones HTTP.
class LocalTaskService implements TaskService {
  LocalTaskService({List<Map<String, dynamic>>? initialTasks})
    : _items = _copy(
        initialTasks ?? demoTasks.map((task) => task.toJson()).toList(),
      );

  List<Map<String, dynamic>> _items;
  static List<Map<String, dynamic>> _copy(List<Map<String, dynamic>> items) =>
      items.map((item) => Map<String, dynamic>.of(item)).toList();

  @override
  List<Map<String, dynamic>> readTasks() => _copy(_items);

  @override
  void writeTasks(List<Map<String, dynamic>> tasks) => _items = _copy(tasks);
}
