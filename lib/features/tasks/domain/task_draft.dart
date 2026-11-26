/// Datos temporales del formulario; todavía no representan una tarea remota.
class TaskDraft {
  const TaskDraft({
    required this.title,
    required this.description,
    required this.priority,
    this.dueDate,
  });
  final String title;
  final String description;
  final String priority;
  final DateTime? dueDate;
}
