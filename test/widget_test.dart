import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:task_flow/app/task_flow_app.dart';
import 'package:task_flow/features/tasks/data/demo_tasks.dart';
import 'package:task_flow/features/tasks/presentation/task_list_view.dart';
import 'package:task_flow/features/tasks/presentation/task_detail_view.dart';
import 'package:task_flow/features/tasks/presentation/widgets/task_card.dart';

void main() {
  setUpAll(() async {
    final font = FontLoader('Roboto');
    font.addFont(
      Future.value(
        ByteData.sublistView(
          File('test/evidence/Roboto-Regular.ttf').readAsBytesSync(),
        ),
      ),
    );
    await font.load();
    final icons = FontLoader('MaterialIcons');
    icons.addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });
  testWidgets('Navega por id, comparte estado y admite rutas inválidas', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const TaskFlowApp());
    await tester.pumpAndSettle();
    expect(find.byType(TaskCard), findsNWidgets(5));
    await expectLater(
      find.byType(TaskFlowApp),
      matchesGoldenFile('evidence/listado.png'),
    );
    for (final task in demoTasks) {
      await tester.tap(find.text(task.title));
      await tester.pumpAndSettle();
      expect(
        GoRouterState.of(tester.element(find.byType(TaskDetailView))).uri.path,
        '/task/${task.id}',
      );
      expect(find.text(task.description), findsOneWidget);
      expect(find.text('Identificador: ${task.id}'), findsOneWidget);
      expect(find.text('Usuario: ${task.userId}'), findsOneWidget);
      if (task.id == 1) {
        await expectLater(
          find.byType(TaskFlowApp),
          matchesGoldenFile('evidence/detalle.png'),
        );
      }
      expect(find.text('Prioridad: ${task.priority}'), findsOneWidget);
      expect(
        find.text(
          task.isCompleted ? 'Estado: completada' : 'Estado: pendiente',
        ),
        findsOneWidget,
      );
      if (task.id == 2) {
        await tester.binding.handlePopRoute();
      } else {
        await tester.tap(find.text('Volver al listado'));
      }
      await tester.pumpAndSettle();
      expect(find.text('Mis tareas'), findsOneWidget);
    }
    await tester.tap(find.text('Agregar'));
    await tester.pumpAndSettle();
    expect(find.text('Pendientes: 5'), findsOneWidget);
    await tester.tap(find.text('Nueva tarea 6'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Marcar como completada'));
    await tester.pumpAndSettle();
    expect(find.text('Estado: completada'), findsOneWidget);
    await tester.tap(find.text('Marcar como pendiente'));
    await tester.pumpAndSettle();
    expect(find.text('Estado: pendiente'), findsOneWidget);
    await tester.tap(find.text('Volver al listado'));
    await tester.pumpAndSettle();
    expect(find.text('Pendientes: 5'), findsOneWidget);
    await tester.tap(find.text('Completar'));
    await tester.pumpAndSettle();
    expect(find.text('Pendientes: 4'), findsOneWidget);
    for (final id in ['3', '999', 'abc']) {
      GoRouter.of(tester.element(find.byType(TaskListView))).go('/task/$id');
      await tester.pumpAndSettle();
      expect(
        find.text(id == '3' ? 'Estado: completada' : 'Tarea no encontrada'),
        findsOneWidget,
      );
      await tester.tap(find.text('Volver al listado'));
      await tester.pumpAndSettle();
      expect(find.text('Mis tareas'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}
