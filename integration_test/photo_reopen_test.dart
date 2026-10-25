import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:resumen_semanal/main.dart' as app;
import 'package:resumen_semanal/services/local_services.dart';
import 'package:resumen_semanal/widgets/habit_widgets.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('foto durable tras reinicio y tema persistente', (tester) async {
    final services = await AppServices.open();
    final row = (await services.repository.list()).single;
    expect(row.photoPath, isNotNull);
    expect(File(row.photoPath!).existsSync(), isTrue);
    await tester.pumpWidget(app.ResumenSemanalApp(services: services));
    await tester.pumpAndSettle();
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Práctica de Flutter Sesión 7'));
    await tester.tap(find.text('Práctica de Flutter Sesión 7'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(HabitPhoto));
    await precacheImage(
      FileImage(File(row.photoPath!)),
      tester.element(find.byType(HabitPhoto)),
    );
    await tester.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    await binding.takeScreenshot('09_foto_despues_reabrir');
    await tester.tap(find.byTooltip('Volver'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Ajustes'));
    await tester.pumpAndSettle();
    await binding.takeScreenshot('10_ajustes');
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(services.preferences.dark, isTrue);
    await binding.takeScreenshot('11_modo_oscuro');
    // Restaurar la preferencia clara para la siguiente demostración.
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(services.preferences.dark, isFalse);
    await services.repository.close();
  });
}
