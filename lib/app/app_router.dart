import '../features/tasks/presentation/task_form_screen.dart';

import 'package:go_router/go_router.dart';

import '../features/tasks/presentation/task_list_view.dart';
import '../features/tasks/presentation/task_detail_view.dart';

GoRouter createAppRouter({String? initialLocation}) => GoRouter(
  initialLocation: initialLocation,
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const TaskListView(),
      routes: [
        GoRoute(
          path: 'new',
          builder: (context, state) => const TaskFormScreen(),
        ),
        GoRoute(
          path: 'task/:id',
          builder: (context, state) => TaskDetailView(
            taskId: int.tryParse(state.pathParameters['id'] ?? ''),
          ),
        ),
      ],
    ),
  ],
);
