import 'package:flutter/material.dart';

void main() {
  runApp(const TaskFlowApp());
}

// APLICACIÓN PRINCIPAL
class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TaskFlow',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}

// MODELO DE DATOS
class Task {
  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.isCompleted,
  });

  final int id;
  final String title;
  final String description;
  final String priority;
  final bool isCompleted;

  // Crea una copia de la tarea con un nuevo estado
  Task copyWith({bool? isCompleted}) {
    return Task(
      id: id,
      title: title,
      description: description,
      priority: priority,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

// CINCO TAREAS LOCALES DE PRUEBA
const List<Task> demoTasks = [
  Task(
    id: 1,
    title: 'Leer documentación',
    description: 'Revisar ListView.builder',
    priority: 'Alta',
    isCompleted: false,
  ),
  Task(
    id: 2,
    title: 'Diseñar la pantalla',
    description: 'Definir la tarjeta de tarea',
    priority: 'Media',
    isCompleted: false,
  ),
  Task(
    id: 3,
    title: 'Preparar evidencia',
    description: 'Tomar captura del avance',
    priority: 'Baja',
    isCompleted: true,
  ),
  Task(
    id: 4,
    title: 'Organizar el backlog',
    description: 'Priorizar pendientes',
    priority: 'Alta',
    isCompleted: false,
  ),
  Task(
    id: 5,
    title: 'Revisar código',
    description: 'Ejecutar flutter analyze',
    priority: 'Media',
    isCompleted: false,
  ),
];

// COMPONENTE REUTILIZABLE TASKCARD
class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.task, required this.onDetail});

  final Task task;
  final VoidCallback onDetail;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

        // Ícono según el estado de la tarea
        leading: Icon(
          task.isCompleted
              ? Icons.check_circle_rounded
              : Icons.radio_button_unchecked_rounded,
          color: task.isCompleted ? Colors.green : Colors.indigo,
          size: 30,
        ),

        // Título de la tarea
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),

        // Descripción y prioridad
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(task.description),
              const SizedBox(height: 5),
              Text(
                'Prioridad: ${task.priority}',
                style: TextStyle(
                  color: task.priority == 'Alta'
                      ? Colors.red
                      : task.priority == 'Media'
                      ? Colors.orange.shade800
                      : Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // Acción visual de detalle
        trailing: IconButton(
          tooltip: 'Ver detalle',
          onPressed: onDetail,
          icon: const Icon(Icons.chevron_right_rounded),
        ),

        onTap: onDetail,
      ),
    );
  }
}

// PANTALLA PRINCIPAL CON ESTADO
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  // Datos que no se reasignan
  final String studentName = 'Roberto Mero';

  final String courseName = 'Desarrollo de aplicaciones móviles';

  final String motivationalMessage =
      '¡Sigue así! Cada tarea completada te acerca más a tu objetivo.';

  // Meta diaria
  static const dailyGoal = 5;

  // Lista local inicializada con demoTasks
  final List<Task> _tasks = List.of(demoTasks);

  // Contar tareas pendientes
  int get pendingTasks => _tasks.where((task) => !task.isCompleted).length;

  // Contar tareas completadas sin superar la meta
  int get completedTasks {
    final int total = _tasks.where((task) => task.isCompleted).length;

    return total > dailyGoal ? dailyGoal : total;
  }

  // Agregar nueva tarea
  void _addTask() {
    final int nextId =
        _tasks.fold<int>(
          0,
          (maxId, task) => task.id > maxId ? task.id : maxId,
        ) +
        1;

    setState(() {
      _tasks.add(
        Task(
          id: nextId,
          title: 'Nueva tarea $nextId',
          description: 'Tarea agregada desde TaskFlow.',
          priority: 'Media',
          isCompleted: false,
        ),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Nueva tarea agregada!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Completar una tarea pendiente
  void _completeTask() {
    if (pendingTasks == 0) return;

    final int index = _tasks.indexWhere((task) => !task.isCompleted);

    if (index == -1) return;

    setState(() {
      _tasks[index] = _tasks[index].copyWith(isCompleted: true);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Tarea completada con éxito!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Mostrar detalle de una tarea sin otra pantalla
  void _showTaskDetail(Task task) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.description),
            const SizedBox(height: 12),
            Text('Prioridad: ${task.priority}'),
            const SizedBox(height: 8),
            Text('Estado: ${task.isCompleted ? "Completada" : "Pendiente"}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String statusMessage = pendingTasks == 0
        ? '¡Excelente! No tienes tareas pendientes.'
        : '¡Sigue adelante, tú puedes!';

    return Scaffold(
      // APPBAR CORREGIDO SEGÚN EL DOCENTE
      appBar: AppBar(
        title: const Text(
          'Mis tareas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),

      body: SafeArea(
        child: Column(
          children: [
            // PANEL DE BIENVENIDA
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ícono centrado
                  Center(
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.indigo.withValues(alpha: 0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.fact_check_rounded,
                        size: 42,
                        color: Colors.indigo,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Saludo
                  Text(
                    '¡Hola, $studentName!',
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 5),

                  Text('Bienvenido/a a $courseName.'),

                  const SizedBox(height: 5),

                  Text(
                    motivationalMessage,
                    style: const TextStyle(
                      color: Colors.indigo,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // CONTADORES
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.pending_actions_rounded,
                            color: Colors.indigo,
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Text(
                              'Pendientes: $pendingTasks',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          Text(
                            'Hoy: $completedTasks/$dailyGoal',
                            style: const TextStyle(
                              color: Colors.indigo,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // BOTONES
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _addTask,
                          icon: const Icon(Icons.add),
                          label: const Text('Agregar'),
                        ),
                      ),

                      const SizedBox(width: 8),

                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: pendingTasks > 0 ? _completeTask : null,
                          icon: const Icon(Icons.check),
                          label: const Text('Completar'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Center(
                    child: Text(
                      statusMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),

            // TÍTULO DEL LISTADO
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Listado de tareas',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // LISTVIEW.BUILDER: LISTA DESPLAZABLE
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final Task task = _tasks[index];

                  return TaskCard(
                    key: ValueKey(task.id),
                    task: task,
                    onDetail: () => _showTaskDetail(task),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
