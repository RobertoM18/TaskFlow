/// Entidad del dominio independiente de Flutter y de la interfaz.
class Task {
  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.isCompleted,
    required this.userId,
  });

  final int id;
  final String title;
  final String description;
  final String priority;
  final bool isCompleted;
  final int userId;

  /// Admite JSON local y remoto; los valores API de respaldo son explícitos.
  factory Task.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final title = json['title'];
    final description = json['description'] ?? 'Sin descripción (API)';
    final priority = json['priority'] ?? 'Sin prioridad (API)';
    final isCompleted = json['isCompleted'] ?? json['completed'];
    final userId = json['userId'];
    if (id is! int ||
        id <= 0 ||
        title is! String ||
        title.trim().isEmpty ||
        description is! String ||
        priority is! String ||
        !['Alta', 'Media', 'Baja', 'Sin prioridad (API)'].contains(priority) ||
        isCompleted is! bool ||
        userId is! int ||
        userId <= 0) {
      throw const FormatException('Datos de tarea inválidos o incompletos');
    }
    return Task(
      id: id,
      title: title,
      description: description,
      priority: priority,
      isCompleted: isCompleted,
      userId: userId,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'priority': priority,
    'isCompleted': isCompleted,
    'userId': userId,
  };

  // Crea una copia de la tarea con un nuevo estado
  Task copyWith({
    String? title,
    String? description,
    String? priority,
    bool? isCompleted,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      userId: userId,
    );
  }
}
