import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../domain/task.dart';
import 'tasks_view_model.dart';
import 'widgets/task_card.dart';
import 'widgets/task_load_status.dart';

class TaskListView extends StatelessWidget {
  const TaskListView({super.key});
  static const studentName = 'Roberto Mero';
  static const courseName = 'Desarrollo de aplicaciones móviles';
  static const motivationalMessage =
      '¡Sigue así! Cada tarea completada te acerca más a tu objetivo.';

  void _addTask(BuildContext context) {
    context.read<TasksViewModel>().addTask();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Nueva tarea agregada!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _completeTask(BuildContext context) {
    if (!context.read<TasksViewModel>().completeNextTask()) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Tarea completada con éxito!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TasksViewModel>();
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
        actions: [
          IconButton(
            tooltip: 'Actualizar tareas',
            onPressed: viewModel.isLoading
                ? null
                : () => context.read<TasksViewModel>().loadTasks(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body:
          viewModel.isLoading ||
              viewModel.errorMessage != null ||
              viewModel.isEmpty
          ? const TaskLoadStatus()
          : SafeArea(
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
                                    'Pendientes: ${viewModel.pendingTasks}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                Text(
                                  'Hoy: ${viewModel.completedTasks}/${TasksViewModel.dailyGoal}',
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
                                onPressed: viewModel.canCreateTasks
                                    ? () => _addTask(context)
                                    : null,
                                icon: const Icon(Icons.add),
                                label: const Text('Agregar'),
                              ),
                            ),

                            const SizedBox(width: 8),

                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: viewModel.pendingTasks > 0
                                    ? () => _completeTask(context)
                                    : null,
                                icon: const Icon(Icons.check),
                                label: const Text('Completar'),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        Center(
                          child: Text(
                            viewModel.canCreateTasks
                                ? viewModel.statusMessage
                                : 'Usuario ${viewModel.userId} · Cambios de estado solo en esta sesión',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
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
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // LISTVIEW.BUILDER: LISTA DESPLAZABLE
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () =>
                          context.read<TasksViewModel>().loadTasks(),
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: viewModel.tasks.length,
                        itemBuilder: (context, index) {
                          final Task task = viewModel.tasks[index];

                          return TaskCard(
                            key: ValueKey(task.id),
                            task: task,
                            onTap: () => context.push('/task/${task.id}'),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
