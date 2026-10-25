import 'package:sqflite/sqflite.dart';
import '../models/habit_entry.dart';

class DuplicateHabit implements Exception {
  const DuplicateHabit();
  @override
  String toString() =>
      'Ya existe ese título para la fecha elegida. Cambia el título o la fecha.';
}

/// Todas las consultas usan parámetros. La UI no contiene SQL.
class HabitRepository {
  HabitRepository(this.db);
  final Database db;

  static Future<void> createV1(Database db) async {
    await db.execute("""CREATE TABLE habits (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL, title_key TEXT NOT NULL,
      category TEXT NOT NULL CHECK(category IN ('Estudio','Sueño','Actividad física','Bienestar')),
      minutes INTEGER NOT NULL CHECK(minutes BETWEEN 1 AND 1440),
      date TEXT NOT NULL, email TEXT NOT NULL, notes TEXT NOT NULL,
      completed INTEGER NOT NULL DEFAULT 0 CHECK(completed IN (0,1)),
      UNIQUE(title_key, date)
    )""");
  }

  static Future<void> upgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Migración aditiva v1 -> v2: conserva los registros existentes.
    if (oldVersion < 2 && newVersion >= 2) {
      await db.execute('ALTER TABLE habits ADD COLUMN photo_path TEXT');
    }
  }

  static Future<HabitRepository> open(
    DatabaseFactory factory,
    String path,
  ) async {
    final db = await factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 2,
        onCreate: (db, version) async {
          await createV1(db);
          await upgrade(db, 1, version);
        },
        onUpgrade: upgrade,
      ),
    );
    return HabitRepository(db);
  }

  Future<List<HabitEntry>> list() async => (await db.query(
    'habits',
    orderBy: 'date DESC, id DESC',
  )).map(HabitEntry.fromMap).toList();
  Future<HabitEntry?> get(int id) async {
    final rows = await db.query('habits', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : HabitEntry.fromMap(rows.single);
  }

  Future<bool> exists(String title, DateTime date, {int? excludingId}) async {
    final rows = await db.query(
      'habits',
      columns: ['id'],
      where:
          'title_key = ? AND date = ?${excludingId == null ? '' : ' AND id <> ?'}',
      whereArgs: [titleKey(title), dayKey(date), ?excludingId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<int> save(HabitEntry entry) async {
    try {
      if (entry.id == null) return await db.insert('habits', entry.toMap());
      final values = entry.toMap()..remove('id');
      final count = await db.update(
        'habits',
        values,
        where: 'id = ?',
        whereArgs: [entry.id],
      );
      if (count != 1) {
        throw StateError('El registro ya no existe. Vuelve a la lista.');
      }
      return entry.id!;
    } on DatabaseException catch (error) {
      // UNIQUE protege también frente a dos envíos concurrentes.
      if (error.isUniqueConstraintError()) throw const DuplicateHabit();
      rethrow;
    }
  }

  Future<void> setCompleted(int id, bool value) async {
    final count = await db.update(
      'habits',
      {'completed': value ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
    if (count != 1) throw StateError('El registro ya no existe.');
  }

  Future<void> delete(int id) async {
    await db.delete('habits', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() => db.close();
}
