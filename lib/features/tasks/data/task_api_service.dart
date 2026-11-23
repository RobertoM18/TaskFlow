import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../domain/task.dart';

class TaskApiService {
  static const userId = 2;
  static const baseUrl = 'https://jsonplaceholder.typicode.com';
  TaskApiService({Dio? dio})
    : _ownsDio = dio == null,
      _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ),
          );
  final Dio _dio;
  final bool _ownsDio;

  Future<List<Task>> getTasks() async {
    final response = await _dio.get<dynamic>(
      '/todos',
      queryParameters: {'userId': userId},
    );
    debugPrint('GET /todos?userId=$userId → HTTP ${response.statusCode}');
    if (response.statusCode != 200 || response.data is! List) {
      throw const FormatException('La respuesta no contiene una lista válida.');
    }
    final ids = <int>{};
    final tasks = <Task>[];
    for (final row in response.data as List) {
      if (row is! Map) {
        throw const FormatException('La tarea no es un objeto JSON.');
      }
      final task = Task.fromJson(Map<String, dynamic>.from(row));
      if (task.userId != userId || !ids.add(task.id)) {
        throw const FormatException(
          'Usuario inesperado o identificador duplicado.',
        );
      }
      tasks.add(task);
    }
    return List.unmodifiable(tasks);
  }

  void dispose() {
    if (_ownsDio) _dio.close(force: true);
  }
}
