import 'package:flutter/material.dart';

void main() {
  runApp(const TaskFlowApp());
}

// Widget principal de TaskFlow
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

// Pantalla que administra un estado cambiante
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

  // Meta diaria constante
  static const dailyGoal = 5;

  // Contadores que pueden cambiar
  int pendingTasks = 6;
  int completedTasks = 0;

  // Agregar una tarea pendiente
  void _addTask() {
    setState(() {
      pendingTasks++;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Nueva tarea agregada!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Completar una tarea
  void _completeTask() {
    // Impedir valores negativos
    if (pendingTasks == 0) return;

    setState(() {
      // Disminuir tareas pendientes
      pendingTasks--;

      // Aumentar completadas sin superar la meta
      if (completedTasks < dailyGoal) {
        completedTasks++;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Tarea completada con éxito!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mensaje dinámico según las tareas
    final String statusMessage = pendingTasks == 0
        ? '¡Excelente! No tienes tareas pendientes.'
        : '¡Sigue adelante, tú puedes!';

    return Scaffold(
      // Barra superior
      appBar: AppBar(
        title: const Text(
          'TaskFlow',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ícono centrado
              Center(
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.indigo.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.fact_check_rounded,
                    size: 58,
                    color: Colors.indigo,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Saludo personalizado
              Text(
                '¡Hola, $studentName!',
                style: Theme.of(context).textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              // Curso
              Text(
                'Bienvenido/a a $courseName.',
                style: const TextStyle(fontSize: 15),
              ),

              const SizedBox(height: 12),

              // Mensaje motivacional
              Text(
                motivationalMessage,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.indigo,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 32),

              // Tarjeta de tareas pendientes
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.pending_actions_rounded,
                        size: 36,
                        color: Colors.indigo,
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tareas pendientes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              '$pendingTasks',
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Botón agregar tarea
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _addTask,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Agregar tarea'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Botón completar tarea
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: pendingTasks > 0 ? _completeTask : null,
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: const Text('Completar tarea'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.indigo,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Estado y progreso diario
              Center(
                child: Column(
                  children: [
                    Text(
                      statusMessage,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    // Nuevo contador de completadas
                    Text(
                      'Completadas hoy: $completedTasks de $dailyGoal',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
