import 'package:flutter/material.dart';

import '../../domain/task.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.task, this.onTap});

  final Task task;
  final VoidCallback? onTap;

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
          onPressed: onTap,
          icon: const Icon(Icons.chevron_right_rounded),
        ),

        onTap: onTap,
      ),
    );
  }
}
