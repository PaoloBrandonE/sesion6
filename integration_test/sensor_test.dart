import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:resumen_semanal/main.dart' as app;
import 'package:resumen_semanal/services/local_services.dart';
import 'package:resumen_semanal/widgets/habit_widgets.dart';
import 'package:resumen_semanal/models/habit_entry.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('fotografía de cámara Android vinculada a registro', (
    tester,
  ) async {
    final services = await AppServices.open();
    if ((await services.repository.list()).isEmpty) {
      await services.repository.save(
        HabitEntry(
          title: 'Práctica de Flutter Sesión 7',
          category: 'Estudio',
          minutes: 90,
          date: DateTime.now(),
          email: '210928@unsaac.edu.pe',
          notes:
              'Resolver formularios, navegación y persistencia local con SQLite.',
          completed: true,
        ),
      );
    }
    await tester.pumpWidget(app.ResumenSemanalApp(services: services));
    await tester.pumpAndSettle();
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Práctica de Flutter Sesión 7'));
    await tester.tap(find.text('Práctica de Flutter Sesión 7'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('edit')));
    await tester.tap(find.byKey(const Key('edit')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('camera')));
    await tester.tap(find.byKey(const Key('camera')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    // La toma se confirma desde la interfaz nativa de la cámara del emulador.
    // Da tiempo para aceptar el permiso y confirmar el disparo.
    await Future<void>.delayed(const Duration(seconds: 50));
    await tester.pumpAndSettle();
    expect(find.byType(HabitPhoto), findsOneWidget);
    await tester.ensureVisible(find.byType(HabitPhoto));
    await binding.takeScreenshot('07_foto_capturada');
    await tester.ensureVisible(find.byKey(const Key('save')));
    await tester.tap(find.byKey(const Key('save')));
    await tester.pumpAndSettle();
    final row = (await services.repository.list()).single;
    expect(row.photoPath, isNotNull);
    expect(File(row.photoPath!).existsSync(), isTrue);
    await tester.ensureVisible(find.byType(HabitPhoto));
    await binding.takeScreenshot('08_detalle_con_foto');
    await services.repository.close();
  });
}
