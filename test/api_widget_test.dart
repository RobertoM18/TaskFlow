import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:task_flow/app/task_flow_app.dart';
import 'package:task_flow/features/tasks/data/task_api_service.dart';
import 'package:task_flow/features/tasks/data/remote_task_repository.dart';
import 'package:task_flow/features/tasks/presentation/task_detail_view.dart';

import 'support/api_adapter.dart';

void main() {
  late List<dynamic> rows;
  setUpAll(() async {
    rows = jsonDecode(
      File('test/evidence/api_tasks.json').readAsStringSync(),
    ) as List<dynamic>;
    final font = FontLoader('Roboto')
      ..addFont(
        Future.value(
          ByteData.sublistView(
            File('test/evidence/Roboto-Regular.ttf').readAsBytesSync(),
          ),
        ),
      );
    await font.load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });

  testWidgets(
    'Datos remotos, detalle por id y cambio local sin otra consulta',
    (tester) async {
      tester.view.physicalSize = const Size(1000, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final adapter = ApiAdapter((_) => jsonResponse(rows));
      final dio = testDio(adapter);
      addTearDown(() => dio.close());
      await tester.pumpWidget(
        TaskFlowApp(
          repositoryFactory: () =>
              RemoteTaskRepository(TaskApiService(dio: dio)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(rows.first['title'] as String), findsOneWidget);
      expect(
        tester
            .widget<ElevatedButton>(
              find.widgetWithText(ElevatedButton, 'Agregar'),
            )
            .onPressed,
        isNull,
      );
      await expectLater(
        find.byType(TaskFlowApp),
        matchesGoldenFile('evidence/listado_api.png'),
      );
      await tester.tap(find.text(rows.first['title'] as String));
      await tester.pumpAndSettle();
      expect(
        GoRouterState.of(tester.element(find.byType(TaskDetailView))).uri.path,
        '/task/${rows.first['id']}',
      );
      expect(find.text('Usuario: 2'), findsOneWidget);
      expect(find.text('Sin descripción (API)'), findsOneWidget);
      expect(find.text('Prioridad: Sin prioridad (API)'), findsOneWidget);
      await expectLater(
        find.byType(TaskFlowApp),
        matchesGoldenFile('evidence/detalle_api.png'),
      );
      await tester.tap(find.text('Marcar como completada'));
      await tester.pumpAndSettle();
      expect(find.text('Estado: completada'), findsOneWidget);
      await tester.tap(find.text('Volver al listado'));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byKey(ValueKey<int>(rows.first['id'] as int)),
          matching: find.byIcon(Icons.check_circle_rounded),
        ),
        findsOneWidget,
      );
      await tester.tap(find.text(rows.first['title'] as String));
      await tester.pumpAndSettle();
      expect(find.text('Estado: completada'), findsOneWidget);
      expect(adapter.requests, hasLength(1));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Muestra carga, error y reintento con lista vacía', (
    tester,
  ) async {
    final gate = Completer<ResponseBody>();
    var count = 0;
    final dio = testDio(
      ApiAdapter((_) => count++ == 0 ? gate.future : jsonResponse([])),
    );
    addTearDown(() => dio.close());
    await tester.pumpWidget(
      TaskFlowApp(
        repositoryFactory: () => RemoteTaskRepository(TaskApiService(dio: dio)),
      ),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    gate.complete(jsonResponse({}, status: 503));
    await tester.pumpAndSettle();
    expect(find.text('No se pudieron cargar las tareas.'), findsOneWidget);
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(find.text('No hay tareas para mostrar.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('El enlace directo espera la carga antes de buscar el id', (
    tester,
  ) async {
    final gate = Completer<ResponseBody>();
    final dio = testDio(ApiAdapter((_) => gate.future));
    addTearDown(() => dio.close());
    await tester.pumpWidget(
      TaskFlowApp(
        initialLocation: '/task/${rows.first['id']}',
        repositoryFactory: () => RemoteTaskRepository(TaskApiService(dio: dio)),
      ),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Tarea no encontrada'), findsNothing);
    gate.complete(jsonResponse(rows));
    await tester.pumpAndSettle();
    expect(find.text(rows.first['title'] as String), findsOneWidget);
    expect(find.text('Usuario: 2'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
