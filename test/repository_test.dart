import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:resumen_semanal/data/habit_repository.dart';
import 'package:resumen_semanal/models/habit_entry.dart';
import 'package:resumen_semanal/utils/validators.dart';

HabitEntry sample({
  int? id,
  String title = 'Estudiar Flutter',
  String? photo,
}) => HabitEntry(
  id: id,
  title: title,
  category: 'Estudio',
  minutes: 60,
  date: DateTime(2026, 10, 24),
  email: '210928@unsaac.edu.pe',
  notes: 'Practicar formularios y persistencia local.',
  photoPath: photo,
);

void main() {
  sqfliteFfiInit();
  late Directory directory;
  late String path;
  late HabitRepository repo;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('habitos_test_');
    path = '${directory.path}/test.db';
    repo = await HabitRepository.open(databaseFactoryFfi, path);
  });
  tearDown(() async {
    await repo.close();
    await directory.delete(recursive: true);
  });

  test('CRUD completo y reapertura conserva datos y fotografía', () async {
    final id = await repo.save(sample(photo: '/fotos/evidencia.jpg'));
    expect((await repo.list()).length, 1);
    await repo.close();
    repo = await HabitRepository.open(databaseFactoryFfi, path);
    expect((await repo.get(id))!.photoPath, '/fotos/evidencia.jpg');
    await repo.save(
      sample(id: id, title: 'Repasar Flutter', photo: '/fotos/evidencia.jpg'),
    );
    await repo.setCompleted(id, true);
    expect((await repo.get(id))!.title, 'Repasar Flutter');
    expect((await repo.get(id))!.completed, isTrue);
    await repo.delete(id);
    expect(await repo.list(), isEmpty);
  });
  test('consulta asíncrona y UNIQUE impiden duplicados normalizados', () async {
    final id = await repo.save(sample());
    expect(
      await repo.exists('  ESTUDIAR   Flutter ', DateTime(2026, 10, 24)),
      isTrue,
    );
    expect(
      await repo.exists(
        'Estudiar Flutter',
        DateTime(2026, 10, 24),
        excludingId: id,
      ),
      isFalse,
    );
    await expectLater(
      repo.save(sample(title: 'ESTUDIAR FLUTTER')),
      throwsA(isA<DuplicateHabit>()),
    );
    expect((await repo.list()).length, 1);
  });
  test(
    'consultas parametrizadas aceptan apóstrofes sin ejecutar SQL ajeno',
    () async {
      await repo.save(sample(title: "Repaso O'Brien"));
      expect(
        await repo.exists("x' OR 1=1 --", DateTime(2026, 10, 24)),
        isFalse,
      );
      expect(
        await repo.exists("Repaso O'Brien", DateTime(2026, 10, 24)),
        isTrue,
      );
    },
  );
  test('migración v1 a v2 mantiene datos y añade foto nullable', () async {
    await repo.close();
    await databaseFactoryFfi.deleteDatabase(path);
    final old = await databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) => HabitRepository.createV1(db),
      ),
    );
    final values = sample().toMap()..remove('photo_path');
    await old.insert('habits', values);
    await old.close();
    repo = await HabitRepository.open(databaseFactoryFfi, path);
    expect((await repo.list()).single.title, 'Estudiar Flutter');
    expect((await repo.list()).single.photoPath, isNull);
    expect(await repo.db.getVersion(), 2);
  });
  test('seis reglas de formulario distinguen valores válidos e inválidos', () {
    expect(Validators.title(''), isNotNull);
    expect(Validators.title('ab'), isNotNull);
    expect(Validators.title('Estudiar'), isNull);
    expect(Validators.email('x@gmail.com'), isNotNull);
    expect(Validators.email('210928@unsaac.edu.pe'), isNull);
    for (final value in ['0', '1441', '1.5', 'hola']) {
      expect(Validators.minutes(value), isNotNull);
    }
    expect(Validators.minutes('1440'), isNull);
    expect(Validators.category(null), isNotNull);
    expect(Validators.category('Estudio'), isNull);
    expect(Validators.notes('Breve'), isNotNull);
    expect(Validators.notes('Descripción suficientemente extensa.'), isNull);
  });
}
