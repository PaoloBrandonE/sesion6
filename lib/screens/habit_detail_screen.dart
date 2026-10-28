import 'package:flutter/material.dart';
import '../models/habit_entry.dart';
import '../services/local_services.dart';
import '../widgets/habit_widgets.dart';
import '../utils/app_routes.dart';
import 'habit_form_screen.dart';

class HabitDetailArgs {
  const HabitDetailArgs(this.id);
  final int id;
}

class HabitDetailScreen extends StatefulWidget {
  const HabitDetailScreen({
    super.key,
    required this.services,
    required this.args,
  });
  final AppServices services;
  final HabitDetailArgs args;
  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  late Future<HabitEntry?> _entry;
  bool _changed = false, _busy = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    _entry = widget.services.repository.get(widget.args.id);
  }

  void _reload() => setState(() {
    _entry = widget.services.repository.get(widget.args.id);
  });
  Future<void> _edit(HabitEntry entry) async {
    final changed = await Navigator.pushNamed<bool>(
      context,
      AppRoutes.form,
      arguments: HabitFormArgs(entry),
    );
    if (changed == true && mounted) {
      _changed = true;
      _reload();
    }
  }

  Future<void> _toggle(HabitEntry entry) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.services.repository.setCompleted(
        entry.id!,
        !entry.completed,
      );
      if (mounted) {
        _changed = true;
        _reload();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'No se pudo actualizar. Inténtalo de nuevo.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete(HabitEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar registro?'),
        content: Text('Se eliminará «${entry.title}» de este dispositivo.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.services.repository.delete(entry.id!);
      if (entry.photoPath != null) {
        await widget.services.photos.remove(entry.photoPath!);
      }
      if (mounted) {
        _changed = true;
        Navigator.pop(context, true);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'No se pudo eliminar. Inténtalo de nuevo.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope<bool>(
    canPop: !_busy && !_changed,
    onPopInvokedWithResult: (didPop, result) {
      // También el botón Atrás del sistema devuelve el cambio a la lista.
      if (!didPop && !_busy) Navigator.pop(context, _changed);
    },
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del registro'),
        leading: IconButton(
          tooltip: 'Volver',
          onPressed: _busy ? null : () => Navigator.pop(context, _changed),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: FutureBuilder<HabitEntry?>(
        future: _entry,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('No se pudo cargar el registro.'),
                  TextButton(
                    onPressed: _reload,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          final entry = snapshot.data;
          if (entry == null) {
            return const Center(child: Text('El registro ya no existe.'));
          }
          return PageBody(
            maxWidth: 680,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(categoryIcon(entry.category), size: 40),
                const SizedBox(height: 16),
                Text(
                  entry.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(label: Text(entry.category)),
                    Chip(label: Text('${entry.minutes} minutos')),
                    Chip(label: Text(dayKey(entry.date))),
                  ],
                ),
                const SizedBox(height: 16),
                Text(entry.notes),
                const SizedBox(height: 16),
                Text('Responsable: ${entry.email}'),
                const SizedBox(height: 16),
                if (entry.photoPath != null) HabitPhoto(path: entry.photoPath!),
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(entry.completed ? 'Completado' : 'Pendiente'),
                  subtitle: const Text('Actualiza el progreso de tu semana'),
                  value: entry.completed,
                  onChanged: _busy ? null : (_) => _toggle(entry),
                ),
                if (_error != null) Text(_error!),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      key: const Key('edit'),
                      onPressed: _busy ? null : () => _edit(entry),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Editar'),
                    ),
                    OutlinedButton.icon(
                      key: const Key('delete'),
                      onPressed: _busy ? null : () => _delete(entry),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Eliminar'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}
