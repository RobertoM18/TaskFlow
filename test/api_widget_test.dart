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
    expect(find.text('Todavía no hay tareas para mostrar.'), findsOneWidget);
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
  testWidgets(
    'Actualizar, vacío, error y Reintentar recuperan la misma sesión',
    (tester) async {
      tester.view.physicalSize = const Size(1000, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final pending = Completer<ResponseBody>();
      var request = 0;
      final adapter = ApiAdapter((_) {
        request++;
        if (request == 1 || request >= 5) return jsonResponse([rows.first]);
        if (request == 2) return pending.future;
        if (request == 3) return jsonResponse([]);
        return jsonResponse({}, status: 503);
      });
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
      // Barra de actualización: no permite repetir una petición en curso.
      await tester.tap(find.byTooltip('Actualizar tareas'));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        tester
            .widget<IconButton>(
              find.byWidgetPredicate(
                (widget) =>
                    widget is IconButton &&
                    widget.tooltip == 'Actualizar tareas',
              ),
            )
            .onPressed,
        isNull,
      );
      expect(find.text('Actualizar'), findsNothing);
      expect(find.text('Reintentar'), findsNothing);
      await tester.pump(const Duration(milliseconds: 100));
      expect(adapter.requests, hasLength(2));
      pending.complete(jsonResponse({}, status: 503));
      await tester.pumpAndSettle();
      expect(find.text('No se pudieron cargar las tareas.'), findsOneWidget);
      expect(find.text('Todavía no hay tareas para mostrar.'), findsNothing);
      await expectLater(
        find.byType(TaskFlowApp),
        matchesGoldenFile('evidence/error_api.png'),
      );
      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();
      expect(find.text('Todavía no hay tareas para mostrar.'), findsOneWidget);
      expect(find.text('Reintentar'), findsNothing);
      await expectLater(
        find.byType(TaskFlowApp),
        matchesGoldenFile('evidence/vacio_api.png'),
      );
      await tester.tap(find.text('Actualizar'));
      await tester.pumpAndSettle();
      expect(find.text('Reintentar'), findsOneWidget);
      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();
      expect(find.text(rows.first['title'] as String), findsOneWidget);
      expect(adapter.requests, hasLength(5));
      // Una lista corta también permite deslizar para actualizar.
      await tester.drag(find.byType(ListView), const Offset(0, 400));
      await tester.pumpAndSettle();
      expect(adapter.requests, hasLength(6));
      await tester.tap(find.text(rows.first['title'] as String));
      await tester.pumpAndSettle();
      expect(find.text('Identificador: ${rows.first['id']}'), findsOneWidget);
      expect(find.text('Usuario: 2'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'Formulario valida, cancela y devuelve borrador sin escribir en API',
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
      await tester.tap(find.text('Nueva tarea'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      expect(find.text('Escribe un título para tu tarea.'), findsOneWidget);
      await expectLater(
        find.byType(TaskFlowApp),
        matchesGoldenFile('evidence/formulario_errores.png'),
      );
      await tester.enterText(find.byType(TextFormField).first, ' ab ');
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      expect(
        find.text('El título debe tener al menos 3 caracteres.'),
        findsOneWidget,
      );
      await tester.enterText(find.byType(TextFormField).first, '   ');
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      expect(find.text('Escribe un título para tu tarea.'), findsOneWidget);
      await tester.enterText(
        find.byType(TextFormField).first,
        '  Preparar exposición  ',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        '  Revisar diapositivas y practicar.  ',
      );
      await tester.tap(find.text('Media'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Alta').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Elegir fecha (opcional)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Aceptar'));
      await tester.pumpAndSettle();
      expect(find.text('Quitar fecha'), findsOneWidget);
      await tester.tap(find.text('Quitar fecha'));
      await tester.pumpAndSettle();
      // Revalidar antes de capturar el formulario válido, sin navegar.
      tester.state<FormState>(find.byType(Form)).validate();
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(TaskFlowApp),
        matchesGoldenFile('evidence/formulario_valido.png'),
      );
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      expect(
        find.text('Formulario válido: Preparar exposición'),
        findsOneWidget,
      );
      await expectLater(
        find.byType(TaskFlowApp),
        matchesGoldenFile('evidence/formulario_retorno.png'),
      );
      expect(adapter.requests, hasLength(1));
      expect(find.text('Preparar exposición'), findsNothing);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Nueva tarea'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField).first)
            .controller!
            .text,
        isEmpty,
      );
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);
      await tester.tap(find.text(rows.first['title'] as String));
      await tester.pumpAndSettle();
      expect(find.text('Identificador: ${rows.first['id']}'), findsOneWidget);
      expect(adapter.requests, hasLength(1));
      expect(tester.takeException(), isNull);
    },
  );
}
