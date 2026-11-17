import 'package:flutter/foundation.dart';

import '../domain/task.dart';

/// Fuente de verdad observable; la presentación depende de este contrato.
abstract class TaskRepository extends ChangeNotifier {
  List<Task> get tasks;
  Task createTask({
    required int userId,
    required String description,
    required String priority,
  });
  bool setCompleted(int id, bool isCompleted);
}
