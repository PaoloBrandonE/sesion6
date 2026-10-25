import 'package:flutter/material.dart';
import '../services/local_services.dart';
import '../widgets/habit_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.preferences,
    required this.onThemeChanged,
  });
  final PreferencesService preferences;
  final VoidCallback onThemeChanged;
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _busy = false;
  String? _error;
  Future<void> _change(bool value) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.preferences.setDark(value);
      if (mounted) {
        widget.onThemeChanged();
        setState(() {});
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'No se pudo guardar el tema. Intenta otra vez.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Ajustes')),
    body: PageBody(
      maxWidth: 680,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            title: const Text('Modo oscuro'),
            subtitle: const Text('Se conserva al cerrar la aplicación'),
            value: widget.preferences.dark,
            onChanged: _busy ? null : _change,
          ),
          if (_error != null) Text(_error!),
          const SizedBox(height: 24),
          const Text(
            'Almacenamiento local',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'SQLite guarda tus registros y las fotos permanecen en la carpeta privada de la aplicación. '
            'No necesitas una cuenta online ni conexión a internet. Desinstalar la app puede eliminar estos datos.',
          ),
          const SizedBox(height: 24),
          const Text('BRANDON PAOLO ESTRADA CUYTO · 210928'),
          const SizedBox(height: 8),
          const Text('Docente: YOVER COLLANTES VALER'),
        ],
      ),
    ),
  );
}
