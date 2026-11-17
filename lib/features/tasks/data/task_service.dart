/// Puerto de acceso a datos de la demostración local, sin dependencias de UI.
/// Al incorporar HTTP, las operaciones deberán ser asíncronas y el servicio
/// remoto resolverá endpoints, métodos, respuestas y errores de transporte.
abstract interface class TaskService {
  List<Map<String, dynamic>> readTasks();
  void writeTasks(List<Map<String, dynamic>> tasks);
}
