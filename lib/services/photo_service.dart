import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';

class PhotoFailure implements Exception {
  const PhotoFailure(this.message, {this.settings = false});
  final String message;
  final bool settings;
}

abstract class PhotoService {
  Future<String?> capture();
  Future<String?> recover();
  Future<void> remove(String path);
  Future<void> settings();
}

/// La foto se copia desde la caché de la cámara a almacenamiento privado durable.
class DevicePhotoService implements PhotoService {
  DevicePhotoService(this.folder);
  final Directory folder;
  final ImagePicker _picker = ImagePicker();

  Future<String> _keep(XFile file) async {
    await folder.create(recursive: true);
    final target = p.join(
      folder.path,
      'foto_${DateTime.now().microsecondsSinceEpoch}.jpg',
    );
    await File(file.path).copy(target);
    return target;
  }

  @override
  Future<String?> capture() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      throw const PhotoFailure(
        'La captura con cámara está disponible en Android. Puedes guardar sin fotografía.',
      );
    }
    final permission = await Permission.camera.request();
    if (!permission.isGranted) {
      throw PhotoFailure(
        permission.isPermanentlyDenied
            ? 'Cámara bloqueada. Puedes habilitarla en Ajustes o guardar sin foto.'
            : 'Permiso de cámara denegado. Puedes guardar sin foto.',
        settings: permission.isPermanentlyDenied,
      );
    }
    try {
      final image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 80,
      );
      return image == null ? null : await _keep(image);
    } on PlatformException {
      throw const PhotoFailure(
        'No se pudo abrir la cámara. Intenta otra vez o guarda sin fotografía.',
      );
    }
  }

  @override
  Future<String?> recover() async {
    if (!Platform.isAndroid) return null;
    final response = await _picker.retrieveLostData();
    if (response.isEmpty || response.files == null || response.files!.isEmpty) {
      return null;
    }
    return _keep(response.files!.first);
  }

  @override
  Future<void> remove(String path) async {
    // Nunca borrar rutas ajenas al directorio de fotos de esta aplicación.
    if (!p.isWithin(
      p.normalize(folder.absolute.path),
      p.normalize(File(path).absolute.path),
    )) {
      return;
    }
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } on FileSystemException {
      /* El registro sigue siendo utilizable. */
    }
  }

  @override
  Future<void> settings() async {
    await openAppSettings();
  }
}
