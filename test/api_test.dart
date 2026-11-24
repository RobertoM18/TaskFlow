import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_flow/features/tasks/data/task_api_service.dart';
import 'package:task_flow/features/tasks/data/remote_task_repository.dart';
import 'package:task_flow/features/tasks/presentation/tasks_view_model.dart';

import 'support/api_adapter.dart';

void main() {
  const row = {
    'id': 21,
    'userId': 2,
    'title': 'Tarea remota',
    'completed': false,
  };

  test(
    'GET filtrado y cambios locales; recargar restaura el valor remoto',
    () async {
      final adapter = ApiAdapter((_) => jsonResponse([row]));
      final dio = testDio(adapter);
      final repository = RemoteTaskRepository(TaskApiService(dio: dio));
      final vm = TasksViewModel(repository, userId: TaskApiService.userId);
      addTearDown(() => dio.close());
      addTearDown(repository.dispose);
      addTearDown(vm.dispose);
      await vm.loadTasks();
      expect(adapter.requests.single.method, 'GET');
      expect(
        adapter.requests.single.uri.toString(),
        'https://jsonplaceholder.typicode.com/todos?userId=2',
      );
      expect(vm.tasks.single.id, 21);
      expect(vm.tasks.single.priority, 'Sin prioridad (API)');
      expect(vm.canCreateTasks, isFalse);
      vm.addTask();
      expect(vm.tasks, hasLength(1));
      expect(vm.toggleTask(21), isTrue);
      expect(vm.tasks.single.isCompleted, isTrue);
      expect(adapter.requests, hasLength(1));
      expect(() => repository.tasks.clear(), throwsUnsupportedError);
      await vm.loadTasks();
      expect(adapter.requests, hasLength(2));
      expect(vm.tasks.single.isCompleted, isFalse);
    },
  );

  test(
    'Rechaza respuestas sin lista, campos inválidos, duplicados y otro usuario',
    () async {
      for (final body in [
        null,
        {'error': 'no lista'},
        [3],
        [
          {'id': 21},
        ],
        [row, row],
        [
          {...row, 'userId': 1},
        ],
      ]) {
        final dio = testDio(ApiAdapter((_) => jsonResponse(body)));
        await expectLater(
          TaskApiService(dio: dio).getTasks(),
          throwsFormatException,
        );
        dio.close();
      }
    },
  );

  test('Carga, error HTTP, reintento vacío y recuperación', () async {
    final gate = Completer<ResponseBody>();
    final started = Completer<void>();
    var response = 0;
    final adapter = ApiAdapter((_) {
      if (response++ == 0) {
        started.complete();
        return gate.future;
      }
      return jsonResponse(response == 2 ? [] : [row]);
    });
    final dio = testDio(adapter);
    final repository = RemoteTaskRepository(TaskApiService(dio: dio));
    final vm = TasksViewModel(repository, userId: 2);
    addTearDown(() => dio.close());
    addTearDown(repository.dispose);
    addTearDown(vm.dispose);
    final pending = vm.loadTasks();
    expect(vm.isLoading, isTrue);
    expect(vm.isEmpty, isFalse);
    await vm.loadTasks(); // No duplica consultas en curso.
    await started.future;
    expect(adapter.requests, hasLength(1));
    gate.complete(jsonResponse({'error': 'unavailable'}, status: 503));
    await pending;
    expect(vm.isLoading, isFalse);
    expect(vm.errorMessage, 'No se pudieron cargar las tareas.');
    expect(vm.isEmpty, isFalse);
    await vm.loadTasks();
    expect(vm.errorMessage, isNull);
    expect(vm.tasks, isEmpty);
    expect(vm.isEmpty, isTrue);
    await vm.loadTasks();
    expect(vm.tasks, hasLength(1));
    expect(vm.isEmpty, isFalse);
  });

  test('Timeout de red conserva caché y termina la carga', () async {
    var fail = false;
    final dio = testDio(
      ApiAdapter((options) {
        if (fail) {
          throw DioException(
            requestOptions: options,
            type: DioExceptionType.connectionTimeout,
          );
        }
        return jsonResponse([row]);
      }),
    );
    final repository = RemoteTaskRepository(TaskApiService(dio: dio));
    final vm = TasksViewModel(repository, userId: 2);
    addTearDown(() => dio.close());
    addTearDown(repository.dispose);
    addTearDown(vm.dispose);
    await vm.loadTasks();
    fail = true;
    await vm.loadTasks();
    expect(vm.isLoading, isFalse);
    expect(vm.errorMessage, isNotNull);
    expect(vm.tasks.single.id, 21);
  });

  test('Respuesta tardía después de dispose no notifica', () async {
    final gate = Completer<ResponseBody>();
    final dio = testDio(ApiAdapter((_) => gate.future));
    final repository = RemoteTaskRepository(TaskApiService(dio: dio));
    final vm = TasksViewModel(repository, userId: 2);
    final pending = vm.loadTasks();
    vm.dispose();
    repository.dispose();
    gate.complete(jsonResponse([row]));
    await pending;
    dio.close();
  });
}
