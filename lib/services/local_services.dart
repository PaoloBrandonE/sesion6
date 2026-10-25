import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../data/habit_repository.dart';
import 'photo_service.dart';

class PreferencesService {
  PreferencesService(this.prefs);
  final SharedPreferences prefs;
  bool get dark => prefs.getBool('dark') ?? false;
  Future<void> setDark(bool value) async {
    if (!await prefs.setBool('dark', value)) {
      throw StateError('No se pudo guardar la preferencia.');
    }
  }
}

class AppServices {
  AppServices({
    required this.repository,
    required this.photos,
    required this.preferences,
  });
  final HabitRepository repository;
  final PhotoService photos;
  final PreferencesService preferences;

  static Future<AppServices> open() async {
    final directory = await getApplicationDocumentsDirectory();
    final folder = Directory(p.join(directory.path, 'UNSAAC_Habitos'));
    await folder.create(recursive: true);
    DatabaseFactory factory = databaseFactory;
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      factory = databaseFactoryFfi;
    }
    return AppServices(
      repository: await HabitRepository.open(
        factory,
        p.join(folder.path, 'habitos.db'),
      ),
      photos: DevicePhotoService(Directory(p.join(folder.path, 'fotos'))),
      preferences: PreferencesService(await SharedPreferences.getInstance()),
    );
  }
}
