import 'package:flutter_test/flutter_test.dart';
import 'package:task_flow/main.dart';

void main() {
  testWidgets('TaskFlow permite agregar y completar tareas', (
    WidgetTester tester,
  ) async {
    // Iniciar la aplicación TaskFlow
    await tester.pumpWidget(const TaskFlowApp());

    // Verificar el contador inicial
    expect(find.text('6'), findsOneWidget);

    // Verificar las tareas completadas inicialmente
    expect(find.text('Completadas hoy: 0 de 5'), findsOneWidget);

    // Buscar el botón Agregar tarea
    final addButton = find.text('Agregar tarea');

    // Desplazarse hasta que sea visible
    await tester.ensureVisible(addButton);
    await tester.pump();

    // Presionar Agregar tarea
    await tester.tap(addButton);
    await tester.pump();

    // Verificar que pendientes aumentó a 7
    expect(find.text('7'), findsOneWidget);

    // Buscar el botón Completar tarea
    final completeButton = find.text('Completar tarea');

    // Desplazarse hasta hacerlo visible
    await tester.ensureVisible(completeButton);
    await tester.pump();

    // Completar una tarea
    await tester.tap(completeButton);
    await tester.pump();

    // Verificar que pendientes volvió a 6
    expect(find.text('6'), findsOneWidget);

    // Verificar que completadas aumentó a 1
    expect(find.text('Completadas hoy: 1 de 5'), findsOneWidget);
  });
}
