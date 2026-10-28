import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resumen_semanal/main.dart';
import 'package:resumen_semanal/models/habit_entry.dart';
import 'package:resumen_semanal/screens/habit_form_screen.dart';
import 'package:resumen_semanal/services/local_services.dart';
import 'package:resumen_semanal/utils/app_routes.dart';
import 'functional_ui_test.dart' as fixture;

class DelayedRepository extends fixture.MemoryRepository {
  final gate = Completer<bool>();
  int writes = 0;
  @override
  Future<bool> exists(String title, DateTime date, {int? excludingId}) =>
      gate.future;
  @override
  Future<int> save(HabitEntry value) async {
    writes++;
    return super.save(value);
  }
}

Future<void> fill(WidgetTester tester) async {
  await tester.enterText(find.byKey(const Key('title')), 'Estudiar Flutter');
  await fixture.tapVisible(tester, find.byKey(const Key('category')));
  await tester.tap(find.text('Estudio').last);
  await tester.pumpAndSettle();
  await tester.enterText(find.byKey(const Key('minutes')), '90');
  await tester.enterText(
    find.byKey(const Key('notes')),
    'Practicar formularios y persistencia local.',
  );
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('guardo sin foto tras denegar y puedo abrir ajustes', (
    tester,
  ) async {
    final services = await fixture.services();
    await tester.pumpWidget(ResumenSemanalApp(services: services));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('newHabit')));
    await tester.pumpAndSettle();
    await fill(tester);
    await fixture.tapVisible(tester, find.byKey(const Key('camera')));
    await fixture.tapVisible(tester, find.text('Continuar'));
    await fixture.tapVisible(tester, find.text('Abrir ajustes de cámara'));
    expect((services.photos as fixture.DeniedPhotos).settingsCalls, 1);
    await fixture.tapVisible(tester, find.byKey(const Key('save')));
    final records = await services.repository.list();
    expect(records.length, 1);
    expect(records.single.photoPath, isNull);
    expect(find.text('Hábitos UNSAAC'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  test('rutas centralizadas y diferentes', () {
    expect(
      {
        AppRoutes.dashboard,
        AppRoutes.form,
        AppRoutes.detail,
        AppRoutes.settings,
      }.length,
      4,
    );
  });
  testWidgets('diez recorridos liberan los cincuenta controladores', (
    tester,
  ) async {
    final services = await fixture.services();
    await tester.pumpWidget(ResumenSemanalApp(services: services));
    await tester.pumpAndSettle();
    for (var i = 0; i < 10; i++) {
      await tester.tap(find.byKey(const Key('newHabit')));
      await tester.pumpAndSettle();
      final controllers = tester
          .widgetList<TextFormField>(find.byType(TextFormField))
          .map((field) => field.controller!)
          .toList();
      expect(controllers.length, 5);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      for (final controller in controllers) {
        expect(
          () => ChangeNotifier.debugAssertNotDisposed(controller),
          throwsFlutterError,
        );
      }
      expect(find.text('Hábitos UNSAAC'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
  testWidgets('el teclado no desborda y puedo alcanzar Guardar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    addTearDown(tester.view.reset);
    final services = await fixture.services();
    await tester.pumpWidget(
      MaterialApp(home: HabitFormScreen(services: services)),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('notes')));
    await tester.tap(find.byKey(const Key('notes')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('save')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('save')).hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('bloqueo el doble envío durante la consulta asíncrona', (
    tester,
  ) async {
    final base = await fixture.services();
    final repo = DelayedRepository();
    final services = AppServices(
      repository: repo,
      photos: base.photos,
      preferences: base.preferences,
    );
    await tester.pumpWidget(ResumenSemanalApp(services: services));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('newHabit')));
    await tester.pumpAndSettle();
    await fill(tester);
    await tester.ensureVisible(find.byKey(const Key('save')));
    await tester.tap(find.byKey(const Key('save')));
    await tester.pump();
    expect(
      tester.widget<FilledButton>(find.byKey(const Key('save'))).onPressed,
      isNull,
    );
    expect(repo.writes, 0);
    repo.gate.complete(false);
    await tester.pumpAndSettle();
    expect(repo.writes, 1);
    expect((await repo.list()).length, 1);
    expect(tester.takeException(), isNull);
  });
  testWidgets('una consulta tardía no toca controladores desmontados', (
    tester,
  ) async {
    final base = await fixture.services();
    final repo = DelayedRepository();
    final services = AppServices(
      repository: repo,
      photos: base.photos,
      preferences: base.preferences,
    );
    await tester.pumpWidget(
      MaterialApp(home: HabitFormScreen(services: services)),
    );
    await tester.pumpAndSettle();
    await fill(tester);
    await tester.ensureVisible(find.byKey(const Key('save')));
    await tester.tap(find.byKey(const Key('save')));
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
    repo.gate.complete(false);
    await tester.pumpAndSettle();
    expect(repo.writes, 0);
    expect(tester.takeException(), isNull);
  });
  testWidgets('puedo cancelar la explicación de cámara sin pedir permiso', (
    tester,
  ) async {
    final services = await fixture.services();
    await tester.pumpWidget(
      MaterialApp(home: HabitFormScreen(services: services)),
    );
    await tester.pumpAndSettle();
    await fixture.tapVisible(tester, find.byKey(const Key('camera')));
    expect(find.text('Usar la cámara'), findsOneWidget);
    await fixture.tapVisible(tester, find.text('Cancelar'));
    expect(find.text('Abrir ajustes de cámara'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
