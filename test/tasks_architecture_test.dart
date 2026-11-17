import 'package:flutter_test/flutter_test.dart';
import 'package:task_flow/features/tasks/data/demo_tasks.dart';
import 'package:task_flow/features/tasks/data/local_task_repository.dart';
import 'package:task_flow/features/tasks/data/local_task_service.dart';
import 'package:task_flow/features/tasks/data/task_service.dart';
import 'package:task_flow/features/tasks/presentation/tasks_view_model.dart';

class FailingService implements TaskService {
  @override
  List<Map<String, dynamic>> readTasks() =>
      demoTasks.map((t) => t.toJson()).toList();
  @override
  void writeTasks(List<Map<String, dynamic>> tasks) =>
      throw StateError('Sin almacenamiento');
}

class InspectableRepository extends LocalTaskRepository {
  InspectableRepository() : super(LocalTaskService());
  bool get hasObservers => hasListeners;
}

void main() {
  test('Acciones recorren VM, Repository y Service; ambos VM ven cambios', () {
    final service = LocalTaskService();
    final repository = LocalTaskRepository(service);
    final list = TasksViewModel(repository, userId: demoUserId);
    final detail = TasksViewModel(repository, userId: demoUserId);
    addTearDown(repository.dispose);
    addTearDown(list.dispose);
    addTearDown(detail.dispose);
    var notifications = 0;
    detail.addListener(() => notifications++);
    expect(list.pendingTasks, 4);
    list.addTask();
    expect(detail.taskById(6)?.title, 'Nueva tarea 6');
    expect(service.readTasks(), hasLength(6));
    expect(detail.toggleTask(6), isTrue);
    expect(list.pendingTasks, 4);
    expect(list.completedTasks, 2);
    expect(service.readTasks().last['isCompleted'], isTrue);
    expect(notifications, 2);
    expect(detail.toggleTask(999), isFalse);
    expect(notifications, 2);
    expect(() => repository.tasks.clear(), throwsUnsupportedError);
    expect(() => list.tasks.clear(), throwsUnsupportedError);
    final snapshot = service.readTasks();
    snapshot.first['title'] = 'Cambio externo';
    expect(service.readTasks().first['title'], demoTasks.first.title);
  });

  test('Estado vacío, meta diaria y tareas de otro usuario', () {
    final service = LocalTaskService(
      initialTasks: [
        {...demoTasks.first.toJson(), 'id': 20, 'userId': 2},
      ],
    );
    final repository = LocalTaskRepository(service);
    final vm = TasksViewModel(repository, userId: demoUserId);
    addTearDown(repository.dispose);
    addTearDown(vm.dispose);
    expect(vm.tasks, isEmpty);
    expect(vm.completeNextTask(), isFalse);
    expect(vm.toggleTask(20), isFalse);
    expect(vm.taskById(null), isNull);
    for (var i = 0; i < 7; i++) {
      vm.addTask();
      expect(vm.completeNextTask(), isTrue);
    }
    expect(vm.tasks.first.id, 21);
    expect(vm.completedTasks, TasksViewModel.dailyGoal);
    expect(vm.pendingTasks, 0);
    expect(vm.statusMessage, '¡Excelente! No tienes tareas pendientes.');
    expect(repository.tasks.first.isCompleted, isFalse);
  });

  test('Un fallo de Service no publica cambios ni notificaciones', () {
    final repository = LocalTaskRepository(FailingService());
    final vm = TasksViewModel(repository, userId: demoUserId);
    addTearDown(repository.dispose);
    addTearDown(vm.dispose);
    var notifications = 0;
    vm.addListener(() => notifications++);
    expect(vm.addTask, throwsStateError);
    expect(() => vm.toggleTask(1), throwsStateError);
    expect(vm.tasks, hasLength(5));
    expect(vm.taskById(1)?.isCompleted, isFalse);
    expect(notifications, 0);
  });

  test(
    'Dispose desconecta el VM y cada repositorio local es independiente',
    () {
      final repository = InspectableRepository();
      final other = LocalTaskRepository(LocalTaskService());
      final vm = TasksViewModel(repository, userId: demoUserId);
      addTearDown(repository.dispose);
      addTearDown(other.dispose);
      expect(repository.hasObservers, isTrue);
      vm.dispose();
      expect(repository.hasObservers, isFalse);
      repository.setCompleted(1, true);
      expect(other.tasks.first.isCompleted, isFalse);
    },
  );
}
