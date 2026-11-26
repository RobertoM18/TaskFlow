import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../domain/task_draft.dart';

class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key});
  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  String _priority = 'Media';
  DateTime? _dueDate;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  void _cancel() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final draft = TaskDraft(
      title: _title.text.trim(),
      description: _description.text.trim(),
      priority: _priority,
      dueDate: _dueDate,
    );
    context.pop(draft);
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 10, 12, 31),
      helpText: 'Fecha de la tarea',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );
    if (!mounted || selected == null) return;
    setState(() => _dueDate = selected);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Nueva tarea'),
      leading: IconButton(
        tooltip: 'Volver',
        onPressed: _cancel,
        icon: const Icon(Icons.arrow_back),
      ),
    ),
    body: SafeArea(
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Organiza tu siguiente pendiente. El título es obligatorio; la descripción y la fecha son opcionales.',
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Título'),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                final title = value?.trim() ?? '';
                if (title.isEmpty) return 'Escribe un título para tu tarea.';
                if (title.length < 3) {
                  return 'El título debe tener al menos 3 caracteres.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _description,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _priority,
              decoration: const InputDecoration(labelText: 'Prioridad'),
              items: ['Alta', 'Media', 'Baja']
                  .map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => _priority = value ?? 'Media'),
              validator: (value) => ['Alta', 'Media', 'Baja'].contains(value)
                  ? null
                  : 'Selecciona una prioridad.',
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _selectDate,
              icon: const Icon(Icons.calendar_today),
              label: Text(
                _dueDate == null
                    ? 'Elegir fecha (opcional)'
                    : 'Fecha: ${_dueDate!.day.toString().padLeft(2, '0')}/${_dueDate!.month.toString().padLeft(2, '0')}/${_dueDate!.year}',
              ),
            ),
            if (_dueDate != null)
              TextButton(
                onPressed: () => setState(() => _dueDate = null),
                child: const Text('Quitar fecha'),
              ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _submit, child: const Text('Guardar')),
            TextButton(onPressed: _cancel, child: const Text('Cancelar')),
          ],
        ),
      ),
    ),
  );
}
