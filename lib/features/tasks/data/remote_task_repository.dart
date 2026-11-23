import '../domain/task.dart';
import 'task_api_service.dart';
import 'task_repository.dart';

/// Consulta remota; los cambios de estado son solo de la sesión en memoria.
class RemoteTaskRepository extends TaskRepository {
  RemoteTaskRepository(this._apiService);
  final TaskApiService _apiService;
  List<Task> _tasks = const [];
  bool _disposed = false;
  @override
  List<Task> get tasks => _tasks;
  @override
  bool get canCreateTasks => false;
  @override
  Future<List<Task>> getTasks() async {
    final loaded = await _apiService.getTasks();
    if (!_disposed) {
      _tasks = List.unmodifiable(loaded);
      notifyListeners();
    }
    return List.unmodifiable(loaded);
  }

  @override
  bool setCompleted(int id, bool isCompleted) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index < 0 || _tasks[index].isCompleted == isCompleted) return false;
    final updated = List<Task>.of(_tasks);
    updated[index] = updated[index].copyWith(isCompleted: isCompleted);
    _tasks = List.unmodifiable(updated);
    notifyListeners();
    return true;
  }

  @override
  Task createTask({
    required int userId,
    required String description,
    required String priority,
  }) => throw UnsupportedError('Creación remota pendiente.');
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
