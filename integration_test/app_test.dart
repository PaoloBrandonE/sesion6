import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:resumen_semanal/main.dart' as app;
import 'package:resumen_semanal/services/local_services.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('registro nativo, persistencia y navegación', (tester) async {
    final services = await AppServices.open();
    await tester.pumpWidget(app.ResumenSemanalApp(services: services));
    await tester.pumpAndSettle();
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await binding.takeScreenshot('01_resumen_inicial');
    await tester.tap(find.byKey(const Key('newHabit')));
    await tester.pumpAndSettle();
    await binding.takeScreenshot('02_formulario');
    await tester.ensureVisible(find.byKey(const Key('save')));
    await tester.tap(find.byKey(const Key('save')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('title')));
    await binding.takeScreenshot('03_validaciones');
    await tester.enterText(
      find.byKey(const Key('title')),
      'Práctica de Flutter Sesión 7',
    );
    await tester.ensureVisible(find.byKey(const Key('category')));
    await tester.tap(find.byKey(const Key('category')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Estudio').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('minutes')), '90');
    await tester.enterText(
      find.byKey(const Key('notes')),
      'Resolver formularios, navegación y persistencia local con SQLite.',
    );
    await tester.ensureVisible(find.byKey(const Key('save')));
    await tester.tap(find.byKey(const Key('save')));
    await tester.pumpAndSettle();
    expect(find.text('Hábitos UNSAAC'), findsOneWidget);
    final entries = await services.repository.list();
    expect(
      entries.where((e) => e.title == 'Práctica de Flutter Sesión 7').length,
      1,
    );
    await tester.ensureVisible(find.text('Práctica de Flutter Sesión 7'));
    await tester.tap(find.text('Práctica de Flutter Sesión 7'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(Switch));
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    await binding.takeScreenshot('04_detalle');
    await tester.tap(find.byTooltip('Volver'));
    await tester.pumpAndSettle();
    await binding.takeScreenshot('05_lista_antes_cerrar');
    expect((await services.repository.list()).single.completed, isTrue);
    await services.repository.close();
  });
}
