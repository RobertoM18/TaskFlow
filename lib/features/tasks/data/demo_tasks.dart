import '../domain/task.dart';

// Usuario local de demostración; no representa una sesión autenticada.
const demoUserId = 1;

// CINCO TAREAS LOCALES DE PRUEBA
const List<Task> demoTasks = [
  Task(
    id: 1,
    title: 'Preparar exposición de TaskFlow',
    description:
        'Organizar las diapositivas y ensayar la explicación del proyecto.',
    priority: 'Alta',
    isCompleted: false,
    userId: demoUserId,
  ),
  Task(
    id: 2,
    title: 'Practicar navegación por rutas',
    description: 'Abrir las cinco tareas por su id y regresar al listado.',
    priority: 'Media',
    isCompleted: false,
    userId: demoUserId,
  ),
  Task(
    id: 3,
    title: 'Documentar el modelo de tareas',
    description:
        'Describir los seis campos de Task y un ejemplo JSON en el README.',
    priority: 'Baja',
    isCompleted: true,
    userId: demoUserId,
  ),
  Task(
    id: 4,
    title: 'Repasar arquitectura MVVM',
    description:
        'Explicar el recorrido desde la View hasta el Service con un ejemplo.',
    priority: 'Alta',
    isCompleted: false,
    userId: demoUserId,
  ),
  Task(
    id: 5,
    title: 'Validar TaskFlow en el teléfono',
    description:
        'Probar el listado, el detalle y el cambio de estado en Android.',
    priority: 'Media',
    isCompleted: false,
    userId: demoUserId,
  ),
];
