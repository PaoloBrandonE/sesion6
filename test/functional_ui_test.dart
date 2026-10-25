import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:resumen_semanal/main.dart';
import 'package:resumen_semanal/models/habit_entry.dart';
import 'package:resumen_semanal/data/habit_repository.dart';
import 'package:resumen_semanal/services/local_services.dart';
import 'package:resumen_semanal/services/photo_service.dart';
import 'package:resumen_semanal/screens/habit_form_screen.dart';

class MemoryRepository implements HabitRepository {
  final List<HabitEntry> entries = [];
  @override
  Future<List<HabitEntry>> list() async => List.of(entries);
  @override
  Future<HabitEntry?> get(int id) async =>
      entries.where((e) => e.id == id).firstOrNull;
  @override
  Future<bool> exists(String title, DateTime date, {int? excludingId}) async =>
      entries.any(
        (e) =>
            titleKey(e.title) == titleKey(title) &&
            dayKey(e.date) == dayKey(date) &&
            e.id != excludingId,
      );
  @override
  Future<int> save(HabitEntry e) async {
    final id = e.id ?? entries.length + 1;
    entries.removeWhere((entry) => entry.id == id);
    entries.add(
      HabitEntry(
        id: id,
        title: e.title,
        category: e.category,
        minutes: e.minutes,
        date: e.date,
        email: e.email,
        notes: e.notes,
        photoPath: e.photoPath,
        completed: e.completed,
      ),
    );
    return id;
  }

  @override
  Future<void> setCompleted(int id, bool value) async {
    final e = (await get(id))!;
    await save(
      HabitEntry(
        id: id,
        title: e.title,
        category: e.category,
        minutes: e.minutes,
        date: e.date,
        email: e.email,
        notes: e.notes,
        photoPath: e.photoPath,
        completed: value,
      ),
    );
  }

  @override
  Future<void> delete(int id) async {
    entries.removeWhere((e) => e.id == id);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class DeniedPhotos implements PhotoService {
  @override
  Future<String?> capture() async => throw const PhotoFailure(
    'Permiso denegado. Puedes guardar sin foto.',
    settings: true,
  );
  @override
  Future<String?> recover() async => null;
  @override
  Future<void> remove(String path) async {}
  @override
  Future<void> settings() async {}
}

Future<AppServices> services() async {
  SharedPreferences.setMockInitialValues({});
  return AppServices(
    repository: MemoryRepository(),
    photos: DeniedPhotos(),
    preferences: PreferencesService(await SharedPreferences.getInstance()),
  );
}

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'validación asíncrona bloquea duplicado y editar excluye su propio id',
    (tester) async {
      final deps = await services();
      final first = HabitEntry(
        id: 1,
        title: 'Estudiar Flutter',
        category: 'Estudio',
        minutes: 60,
        date: DateTime.now(),
        email: '210928@unsaac.edu.pe',
        notes: 'Practicar formularios y persistencia.',
      );
      await deps.repository.save(first);
      await tester.pumpWidget(
        MaterialApp(home: HabitFormScreen(services: deps)),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('title')), first.title);
      await tapVisible(tester, find.byKey(const Key('category')));
      await tester.tap(find.text('Estudio').last);
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('minutes')), '60');
      await tester.enterText(find.byKey(const Key('notes')), first.notes);
      await tapVisible(tester, find.byKey(const Key('save')));
      expect(find.textContaining('Ya existe ese título'), findsOneWidget);
      expect((await deps.repository.list()).length, 1);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await tester.pumpWidget(
        MaterialApp(
          home: HabitFormScreen(services: deps, args: HabitFormArgs(first)),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('minutes')), '75');
      await tapVisible(tester, find.byKey(const Key('save')));
      expect((await deps.repository.list()).single.minutes, 75);
      expect((await deps.repository.list()).length, 1);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('crear, detalle, completar, retorno del sistema y eliminar', (
    tester,
  ) async {
    final deps = await services();
    await tester.pumpWidget(ResumenSemanalApp(services: deps));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('newHabit')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('title')), 'Estudiar Flutter');
    await tapVisible(tester, find.byKey(const Key('category')));
    await tester.tap(find.text('Estudio').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('minutes')), '60');
    await tester.enterText(
      find.byKey(const Key('notes')),
      'Practicar formularios y persistencia.',
    );
    await tapVisible(tester, find.byKey(const Key('save')));
    expect(find.text('Hábitos UNSAAC'), findsOneWidget);
    expect((await deps.repository.list()).length, 1);
    await tapVisible(tester, find.text('Estudiar Flutter'));
    expect(find.text('Detalle del registro'), findsOneWidget);
    await tapVisible(tester, find.byType(Switch));
    expect((await deps.repository.list()).single.completed, isTrue);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Mis registros (1)'), findsOneWidget);
    await tapVisible(tester, find.text('Estudiar Flutter'));
    await tapVisible(tester, find.byKey(const Key('delete')));
    await tester.tap(find.widgetWithText(FilledButton, 'Eliminar'));
    await tester.pumpAndSettle();
    expect(await deps.repository.list(), isEmpty);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'permiso denegado muestra alternativa sin bloquear el formulario',
    (tester) async {
      final deps = await services();
      await tester.pumpWidget(
        MaterialApp(home: HabitFormScreen(services: deps)),
      );
      await tester.pumpAndSettle();
      await tapVisible(tester, find.byKey(const Key('camera')));
      expect(find.text('Abrir ajustes de cámara'), findsOneWidget);
      expect(
        find.text('Permiso denegado. Puedes guardar sin foto.'),
        findsOneWidget,
      );
      expect(
        tester.widget<FilledButton>(find.byKey(const Key('save'))).onPressed,
        isNotNull,
      );
    },
  );
  testWidgets('formulario vacío no guarda y muestra cómo corregirlo', (
    tester,
  ) async {
    final deps = await services();
    await tester.pumpWidget(MaterialApp(home: HabitFormScreen(services: deps)));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byKey(const Key('save')));
    expect(find.text('Escribe el nombre del hábito.'), findsOneWidget);
    expect(find.text('Selecciona una categoría.'), findsOneWidget);
    expect(await deps.repository.list(), isEmpty);
  });
  for (final width in [320.0, 600.0, 1100.0]) {
    testWidgets('pantallas adaptables a $width px', (tester) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final deps = await services();
      await tester.pumpWidget(ResumenSemanalApp(services: deps));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const Key('newHabit')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
