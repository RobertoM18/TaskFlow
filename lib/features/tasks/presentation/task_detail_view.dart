import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'tasks_view_model.dart';

class TaskDetailView extends StatelessWidget {
  const TaskDetailView({super.key, required this.taskId});

  final int? taskId;

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TasksViewModel>();
    final task = viewModel.taskById(taskId);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de tarea'),
        leading: BackButton(onPressed: () => _back(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task == null)
                const Text('Tarea no encontrada')
              else ...[
                Text(
                  task.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Text(task.description),
                const SizedBox(height: 16),
                Chip(label: Text('Prioridad: ${task.priority}')),
                const SizedBox(height: 12),
                Text(
                  task.isCompleted ? 'Estado: completada' : 'Estado: pendiente',
                ),
                const SizedBox(height: 8),
                Text('Identificador: ${task.id}'),
                Text('Usuario: ${task.userId}'),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () =>
                      context.read<TasksViewModel>().toggleTask(task.id),
                  icon: Icon(
                    task.isCompleted ? Icons.undo : Icons.check_circle_outline,
                  ),
                  label: Text(
                    task.isCompleted
                        ? 'Marcar como pendiente'
                        : 'Marcar como completada',
                  ),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton.tonalIcon(
                onPressed: () => _back(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Volver al listado'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
