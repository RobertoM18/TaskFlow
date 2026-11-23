import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../tasks_view_model.dart';

class TaskLoadStatus extends StatelessWidget {
  const TaskLoadStatus({super.key});
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TasksViewModel>();
    return Center(
      child: vm.isLoading
          ? const CircularProgressIndicator()
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(vm.errorMessage ?? 'No hay tareas para mostrar.'),
                if (vm.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.read<TasksViewModel>().loadTasks(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ],
            ),
    );
  }
}
