import 'package:flutter/material.dart';
import '../models/habit_entry.dart';
import '../services/local_services.dart';
import '../widgets/habit_widgets.dart';
import 'habit_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.services});
  final AppServices services;
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<HabitEntry>> _entries;
  String? _category;
  @override
  void initState() {
    super.initState();
    _entries = widget.services.repository.list();
  }

  // El Future se conserva entre builds y solo se sustituye al recargar.
  void _reload() {
    if (mounted) {
      setState(() {
        _entries = widget.services.repository.list();
      });
    }
  }

  Future<void> _open(String route, {Object? arguments}) async {
    final changed = await Navigator.pushNamed<bool>(
      context,
      route,
      arguments: arguments,
    );
    if (changed == true && mounted) _reload();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Hábitos UNSAAC'),
      actions: [
        IconButton(
          tooltip: 'Actualizar',
          onPressed: _reload,
          icon: const Icon(Icons.refresh),
        ),
        IconButton(
          tooltip: 'Ajustes',
          onPressed: () => _open('/ajustes'),
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      key: const Key('newHabit'),
      onPressed: () => _open('/formulario'),
      icon: const Icon(Icons.add),
      label: const Text('Nuevo registro'),
    ),
    body: FutureBuilder<List<HabitEntry>>(
      future: _entries,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('No se pudieron cargar los registros.'),
                ElevatedButton(
                  onPressed: _reload,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }
        final all = snapshot.data ?? [];
        final entries = all
            .where((e) => _category == null || e.category == _category)
            .toList();
        final today = DateTime.now();
        final start = DateTime(
          today.year,
          today.month,
          today.day,
        ).subtract(Duration(days: today.weekday - 1));
        final week = all
            .where(
              (e) =>
                  !e.date.isBefore(start) &&
                  e.date.isBefore(start.add(const Duration(days: 7))),
            )
            .toList();
        final completed = week.where((e) => e.completed).length;
        final percent = week.isEmpty ? 0.0 : completed / week.length;
        int minutes(String category) => week
            .where((e) => e.category == category && e.completed)
            .fold(0, (sum, e) => sum + e.minutes);
        return PageBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hola, Brandon',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text('Tu resumen de estudio y bienestar'),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    child: const Text('BE'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Esta semana · ${dayKey(start)}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, box) {
                  final columns = box.maxWidth < 350 ? 3 : 7;
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (int i = 0; i < 7; i++)
                        SizedBox(
                          width: (box.maxWidth - 8 * (columns - 1)) / columns,
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                children: [
                                  Text(
                                    const [
                                      'Lun',
                                      'Mar',
                                      'Mié',
                                      'Jue',
                                      'Vie',
                                      'Sáb',
                                      'Dom',
                                    ][i],
                                  ),
                                  Text(
                                    '${start.add(Duration(days: i)).day}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge,
                                  ),
                                  Icon(
                                    week.any(
                                          (e) =>
                                              dayKey(e.date) ==
                                                  dayKey(
                                                    start.add(
                                                      Duration(days: i),
                                                    ),
                                                  ) &&
                                              e.completed,
                                        )
                                        ? Icons.check_circle_outline
                                        : Icons.circle_outlined,
                                    semanticLabel:
                                        week.any(
                                          (e) =>
                                              dayKey(e.date) ==
                                                  dayKey(
                                                    start.add(
                                                      Duration(days: i),
                                                    ),
                                                  ) &&
                                              e.completed,
                                        )
                                        ? 'Con actividad completada'
                                        : 'Sin actividad completada',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, box) {
                  final count = box.maxWidth >= 900
                      ? 4
                      : box.maxWidth < 300
                      ? 1
                      : 2;
                  final values = [
                    (
                      'Estudio',
                      '${minutes('Estudio')} min',
                      Icons.menu_book_outlined,
                    ),
                    (
                      'Sueño',
                      '${minutes('Sueño')} min',
                      Icons.bedtime_outlined,
                    ),
                    (
                      'Actividad física',
                      '${minutes('Actividad física')} min',
                      Icons.directions_run,
                    ),
                    (
                      'Cumplimiento',
                      '${(percent * 100).round()} %',
                      Icons.flag_outlined,
                    ),
                  ];
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final item in values)
                        SizedBox(
                          width: (box.maxWidth - 12 * (count - 1)) / count,
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(item.$3),
                                  const SizedBox(height: 8),
                                  Text(
                                    item.$2,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(item.$1),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Progreso semanal · $completed de ${week.length} registros completados',
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: percent,
                semanticsLabel: 'Progreso semanal',
                semanticsValue: '${(percent * 100).round()}',
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Mis registros (${entries.length})',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const Icon(
                    Icons.storage_outlined,
                    semanticLabel: 'Almacenamiento local',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Todas'),
                    selected: _category == null,
                    onSelected: (_) => setState(() => _category = null),
                  ),
                  for (final category in categories)
                    FilterChip(
                      label: Text(category),
                      selected: _category == category,
                      onSelected: (_) => setState(() => _category = category),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (entries.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Todavía no hay registros en esta categoría. Pulsa Nuevo registro para comenzar.',
                    ),
                  ),
                ),
              for (final entry in entries)
                HabitCard(
                  entry: entry,
                  onTap: () =>
                      _open('/detalle', arguments: HabitDetailArgs(entry.id!)),
                ),
              const SizedBox(height: 96),
            ],
          ),
        );
      },
    ),
  );
}
