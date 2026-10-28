import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:resumen_semanal/main.dart' as app;
import 'package:resumen_semanal/services/local_services.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('diez recorridos con tiempos y liberación de controladores', (
    tester,
  ) async {
    final services = await AppServices.open();
    await tester.pumpWidget(app.ResumenSemanalApp(services: services));
    await tester.pumpAndSettle();
    Future<List<TextEditingController>> openAndClose() async {
      await tester.tap(find.byKey(const Key('newHabit')));
      await tester.pumpAndSettle();
      final controllers = tester
          .widgetList<TextFormField>(find.byType(TextFormField))
          .map((field) => field.controller!)
          .toList();
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      for (final controller in controllers) {
        expect(
          () => ChangeNotifier.debugAssertNotDisposed(controller),
          throwsFlutterError,
        );
      }
      return controllers;
    }

    // Caliento las rutas para distinguir caché inicial de crecimiento sostenido.
    for (var i = 0; i < 3; i++) {
      await openAndClose();
    }
    final samples = <Map<String, int>>[];
    for (var i = 0; i < 10; i++) {
      final timer = Stopwatch()..start();
      final controllers = await openAndClose();
      timer.stop();
      expect(controllers.length, 5);
      controllers.clear();
      samples.add({'ciclo': i + 1, 'duracion_ms': timer.elapsedMilliseconds});
      expect(tester.takeException(), isNull);
    }
    binding.reportData = {
      'ciclos': samples,
      'controladores_liberados': 50,
      'metodo':
          'Diez ciclos nativos, tiempo de ruta y dispose de 50 controladores',
      'limite':
          'No constituye un perfil de memoria ni una prueba en teléfono físico',
    };
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await binding.takeScreenshot('checklist_diez_recorridos');
    await services.repository.close();
  });
}
