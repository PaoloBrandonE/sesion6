import 'dart:io';
import 'package:flutter/material.dart';
import '../models/habit_entry.dart';

IconData categoryIcon(String category) => switch (category) {
  'Estudio' => Icons.menu_book_outlined,
  'Sueño' => Icons.bedtime_outlined,
  'Actividad física' => Icons.directions_run,
  _ => Icons.spa_outlined,
};

class HabitCard extends StatelessWidget {
  const HabitCard({super.key, required this.entry, required this.onTap});
  final HabitEntry entry;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: Icon(categoryIcon(entry.category)),
      title: Text(entry.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${entry.category} · ${entry.minutes} min\n${dayKey(entry.date)} · '
        '${entry.completed ? 'Completado' : 'Pendiente'}',
      ),
      isThreeLine: true,
      onTap: onTap,
      trailing: Icon(
        entry.completed ? Icons.check_circle_outline : Icons.chevron_right,
      ),
    ),
  );
}

class HabitPhoto extends StatelessWidget {
  const HabitPhoto({super.key, required this.path});
  final String path;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: Image.file(
      File(path),
      height: 200,
      width: double.infinity,
      fit: BoxFit.cover,
      semanticLabel: 'Fotografía adjunta del hábito',
      errorBuilder: (context, error, stack) => const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'La fotografía ya no está disponible. Puedes adjuntar otra.',
        ),
      ),
    ),
  );
}

class PageBody extends StatelessWidget {
  const PageBody({super.key, required this.child, this.maxWidth = 1120});
  final Widget child;
  final double maxWidth;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    ),
  );
}
