// BRANDON PAOLO ESTRADA CUYTO · 210928 · Docente: YOVER COLLANTES VALER
import 'package:flutter/material.dart';
import 'services/local_services.dart';
import 'screens/dashboard_screen.dart';
import 'screens/habit_form_screen.dart';
import 'screens/habit_detail_screen.dart';
import 'screens/settings_screen.dart';
import 'utils/app_constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    runApp(ResumenSemanalApp(services: await AppServices.open()));
  } catch (_) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('No se pudo abrir el almacenamiento local.'),
                  const Text(
                    'Revisa el espacio disponible e inténtalo de nuevo.',
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: main,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ResumenSemanalApp extends StatefulWidget {
  const ResumenSemanalApp({super.key, required this.services});
  final AppServices services;
  @override
  State<ResumenSemanalApp> createState() => _ResumenSemanalAppState();
}

class _ResumenSemanalAppState extends State<ResumenSemanalApp> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme(Brightness brightness) => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accent,
        brightness: brightness,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.all(16),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
    return MaterialApp(
      title: 'Hábitos UNSAAC',
      debugShowCheckedModeBanner: false,
      theme: theme(Brightness.light),
      darkTheme: theme(Brightness.dark),
      themeMode: widget.services.preferences.dark
          ? ThemeMode.dark
          : ThemeMode.light,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        final services = widget.services;
        Widget page;
        switch (settings.name) {
          case '/':
            page = DashboardScreen(services: services);
            break;
          case '/formulario':
            final args = settings.arguments;
            page = args == null || args is HabitFormArgs
                ? HabitFormScreen(
                    services: services,
                    args: args as HabitFormArgs?,
                  )
                : const _InvalidRoute();
            break;
          case '/detalle':
            final args = settings.arguments;
            page = args is HabitDetailArgs
                ? HabitDetailScreen(services: services, args: args)
                : const _InvalidRoute();
            break;
          case '/ajustes':
            page = SettingsScreen(
              preferences: services.preferences,
              onThemeChanged: () {
                if (mounted) setState(() {});
              },
            );
            break;
          default:
            page = const _InvalidRoute();
        }
        return MaterialPageRoute<bool>(
          settings: settings,
          builder: (_) => page,
        );
      },
    );
  }
}

class _InvalidRoute extends StatelessWidget {
  const _InvalidRoute();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Ruta no disponible')),
    body: const Center(
      child: Text('Regresa e intenta abrir el registro desde la lista.'),
    ),
  );
}
