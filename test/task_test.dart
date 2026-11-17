import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:task_flow/features/tasks/data/demo_tasks.dart';
import 'package:task_flow/features/tasks/domain/task.dart';

void main() {
  final validJson = <String, dynamic>{
    'id': 1,
    'title': 'Leer documentación',
    'description': 'Revisar ListView.builder',
    'priority': 'Alta',
    'isCompleted': false,
    'userId': 1,
  };

  test('Intercambia todos los campos mediante texto JSON', () {
    final task = Task.fromJson(validJson);
    expect(task.id, 1);
    expect(task.title, 'Leer documentación');
    expect(task.description, 'Revisar ListView.builder');
    expect(task.priority, 'Alta');
    expect(task.isCompleted, isFalse);
    expect(task.userId, 1);
    final restored = Task.fromJson(
      jsonDecode(jsonEncode(task.toJson())) as Map<String, dynamic>,
    );
    expect(restored.toJson(), validJson);
  });

  test('Los cinco objetos locales forman una lista JSON válida', () {
    final decoded = jsonDecode(
      jsonEncode(demoTasks.map((t) => t.toJson()).toList()),
    ) as List<dynamic>;
    final tasks = decoded
        .map((item) => Task.fromJson(item as Map<String, dynamic>))
        .toList();
    expect(tasks, hasLength(5));
    expect(tasks.map((t) => t.id).toSet(), hasLength(5));
    expect(tasks.every((t) => t.userId == demoUserId), isTrue);
    expect(tasks.map((t) => t.priority).toSet(), {'Alta', 'Media', 'Baja'});
    expect(tasks.map((t) => t.isCompleted).toSet(), {true, false});
  });

  test('Rechaza cada campo ausente y entradas inválidas', () {
    for (final key in validJson.keys) {
      final incomplete = Map<String, dynamic>.of(validJson)..remove(key);
      expect(
        () => Task.fromJson(incomplete),
        throwsFormatException,
        reason: key,
      );
    }
    for (final invalid in <Map<String, dynamic>>[
      {'id': '1'},
      {'id': 0},
      {'id': -1},
      {'title': '   '},
      {'title': null},
      {'description': 3},
      {'priority': 'Urgente'},
      {'isCompleted': 'false'},
      {'userId': 0},
      {'userId': '1'},
    ]) {
      expect(
        () => Task.fromJson({...validJson, ...invalid}),
        throwsFormatException,
      );
    }
    expect(
      Task.fromJson({...validJson, 'description': ''}).description,
      isEmpty,
    );
  });

  test('Actualizar conserva identidad y propietario sin mutar el original', () {
    final original = Task.fromJson(validJson);
    final updated = original.copyWith(
      title: 'Entregar',
      description: '',
      priority: 'Baja',
      isCompleted: true,
    );
    expect(updated.toJson(), {
      ...validJson,
      'title': 'Entregar',
      'description': '',
      'priority': 'Baja',
      'isCompleted': true,
    });
    expect(original.toJson(), validJson);
    expect(original.copyWith().toJson(), validJson);
  });
}
