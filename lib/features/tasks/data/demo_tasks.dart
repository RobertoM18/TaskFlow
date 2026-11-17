import '../domain/task.dart';

// Usuario local de demostración; no representa una sesión autenticada.
const demoUserId = 1;

// CINCO TAREAS LOCALES DE PRUEBA
const List<Task> demoTasks = [
  Task(
    id: 1,
    title: 'Leer documentación',
    description: 'Revisar ListView.builder',
    priority: 'Alta',
    isCompleted: false,
    userId: demoUserId,
  ),
  Task(
    id: 2,
    title: 'Diseñar la pantalla',
    description: 'Definir la tarjeta de tarea',
    priority: 'Media',
    isCompleted: false,
    userId: demoUserId,
  ),
  Task(
    id: 3,
    title: 'Preparar evidencia',
    description: 'Tomar captura del avance',
    priority: 'Baja',
    isCompleted: true,
    userId: demoUserId,
  ),
  Task(
    id: 4,
    title: 'Organizar el backlog',
    description: 'Priorizar pendientes',
    priority: 'Alta',
    isCompleted: false,
    userId: demoUserId,
  ),
  Task(
    id: 5,
    title: 'Revisar código',
    description: 'Ejecutar flutter analyze',
    priority: 'Media',
    isCompleted: false,
    userId: demoUserId,
  ),
];
