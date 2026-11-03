import 'package:flutter/material.dart';

void main() {
  runApp(const TaskFlowApp());
}

class TaskFlowApp extends StatelessWidget { // StatelessWidget -> se usa cuando la interfaz depende de datos que no cambian localmente 
  const TaskFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TaskFlow',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const studentName = 'Roberto Mero';
    const pendingTasks = 6;
    const courseName = 'Desarrollo de aplicaciones móviles';

    const motivationalMessage = '¡Sigue así! Cada tarea completada te acerca más a tu objetivo.';

    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskFlow'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigo.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.fact_check_rounded,
                  size: 58,
                  color: Colors.indigo,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '¡Hola, $studentName!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text('Bienvenido/a a $courseName.'),

            const SizedBox(height: 12),
            const Text(
              motivationalMessage,
              style: TextStyle(
                fontSize: 16,
                color: Colors.indigo,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(Icons.pending_actions),
                    const SizedBox(width: 12),
                    Text('Tareas pendientes: $pendingTasks'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}