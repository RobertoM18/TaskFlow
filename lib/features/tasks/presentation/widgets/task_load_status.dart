import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../tasks_view_model.dart';

class TaskLoadStatus extends StatelessWidget {
  const TaskLoadStatus({super.key});
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TasksViewModel>();
    if (vm.isLoading) {
      return const Center(
        child: CircularProgressIndicator(semanticsLabel: 'Cargando tareas'),
      );
    }
    final hasError = vm.errorMessage != null;
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                hasError ? Icons.cloud_off_outlined : Icons.task_alt,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                vm.errorMessage ?? 'Todavía no hay tareas para mostrar.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => context.read<TasksViewModel>().loadTasks(),
                icon: const Icon(Icons.refresh),
                label: Text(hasError ? 'Reintentar' : 'Actualizar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
