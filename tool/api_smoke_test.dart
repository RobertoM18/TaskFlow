// Ejecutar explícitamente: flutter test tool/api_smoke_test.dart
// Esta comprobación usa internet y actualiza la evidencia de la consulta real.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:task_flow/features/tasks/data/task_api_service.dart';

void main() {
  test('Consulta real del usuario elegido con Dio', () async {
    final service = TaskApiService();
    addTearDown(service.dispose);
    final tasks = await service.getTasks();
    expect(tasks, isNotEmpty);
    expect(tasks.every((task) => task.userId == TaskApiService.userId), isTrue);
    File('test/evidence/api_tasks.json').writeAsStringSync(
      const JsonEncoder.withIndent('  ')
          .convert(tasks.map((task) => task.toJson()).toList()),
    );
    File('test/evidence/api_http.txt').writeAsStringSync(
      'GET ${TaskApiService.baseUrl}/todos?userId=${TaskApiService.userId} → HTTP 200\n'
      'Verificado: ${DateTime.now().toUtc().toIso8601String()}\n'
      'Tareas recibidas: ${tasks.length}\n'
      'Usuario: ${TaskApiService.userId}\n'
      'Consulta real con TaskApiService y Dio; sin escrituras remotas.\n',
    );
  });
}
