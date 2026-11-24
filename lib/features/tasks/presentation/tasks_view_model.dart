import 'package:flutter/foundation.dart';

import '../data/task_repository.dart';
import '../domain/task.dart';

/// Estado y acciones compartidos por listado y detalle; no construye widgets.
class TasksViewModel extends ChangeNotifier {
  TasksViewModel(this._repository, {required this.userId}) {
    _repository.addListener(_onTasksChanged);
  }

  final TaskRepository _repository;
  final int userId;
  static const dailyGoal = 5;
  bool _isLoading = false;
  bool _disposed = false;
  String? _errorMessage;
  bool get isLoading => _isLoading;
  bool get isEmpty => !isLoading && errorMessage == null && tasks.isEmpty;
  String? get errorMessage => _errorMessage;
  bool get canCreateTasks => _repository.canCreateTasks && !isLoading;

  Future<void> loadTasks() async {
    if (_isLoading || _disposed) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.getTasks();
    } catch (error) {
      if (!_disposed) {
        _errorMessage = 'No se pudieron cargar las tareas.';
        debugPrint('Error al cargar tareas: $error');
      }
    } finally {
      if (!_disposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  List<Task> get tasks => List.unmodifiable(
    _repository.tasks.where((task) => task.userId == userId),
  );
  int get pendingTasks => tasks.where((task) => !task.isCompleted).length;
  int get completedTasks =>
      tasks.where((task) => task.isCompleted).length.clamp(0, dailyGoal);
  String get statusMessage => pendingTasks == 0
      ? '¡Excelente! No tienes tareas pendientes.'
      : '¡Sigue adelante, tú puedes!';

  Task? taskById(int? id) {
    for (final task in tasks) {
      if (task.id == id) return task;
    }
    return null;
  }

  void addTask() {
    if (!canCreateTasks) return;
    _repository.createTask(
      userId: userId,
      description: 'Tarea agregada desde TaskFlow.',
      priority: 'Media',
    );
  }

  bool completeNextTask() {
    for (final task in tasks) {
      if (!task.isCompleted) return _repository.setCompleted(task.id, true);
    }
    return false;
  }

  bool toggleTask(int id) {
    final task = taskById(id);
    return task != null && _repository.setCompleted(id, !task.isCompleted);
  }

  void _onTasksChanged() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _repository.removeListener(_onTasksChanged);
    super.dispose();
  }
}
