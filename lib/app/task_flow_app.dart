import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../features/tasks/data/demo_tasks.dart';
import '../features/tasks/data/task_service.dart';
import '../features/tasks/data/local_task_service.dart';
import '../features/tasks/data/task_repository.dart';
import '../features/tasks/data/local_task_repository.dart';
import '../features/tasks/presentation/tasks_view_model.dart';
import 'app_router.dart';

class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({super.key, this.initialLocation});
  final String? initialLocation;

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      Provider<TaskService>(create: (_) => LocalTaskService()),
      ChangeNotifierProvider<TaskRepository>(
        create: (context) => LocalTaskRepository(context.read<TaskService>()),
      ),
      ChangeNotifierProvider<TasksViewModel>(
        create: (context) =>
            TasksViewModel(context.read<TaskRepository>(), userId: demoUserId),
      ),
    ],
    child: _RoutedApp(initialLocation: initialLocation),
  );
}

class _RoutedApp extends StatefulWidget {
  const _RoutedApp({this.initialLocation});
  final String? initialLocation;
  @override
  State<_RoutedApp> createState() => _RoutedAppState();
}

class _RoutedAppState extends State<_RoutedApp> {
  late final GoRouter _router = createAppRouter(
    initialLocation: widget.initialLocation,
  );
  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    debugShowCheckedModeBanner: false,
    title: 'TaskFlow',
    theme: buildAppTheme(),
    routerConfig: _router,
  );
}
