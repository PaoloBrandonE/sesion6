# Hábitos UNSAAC — Sesión 7

Desarrollé una aplicación Android para registrar estudio, sueño, actividad física y
bienestar. Continué mi interfaz de la Sesión 6 y añadí estado, navegación,
persistencia local, formularios y fotografía opcional.

## Mi entorno y ejecución

Usé Flutter 3.41.7, Dart 3.11.5 y Android API 24 o posterior.

```powershell
flutter pub get
flutter devices
flutter run -d <id-android>
```

No necesito servidor ni cuenta online. La base SQLite habitos.db se crea al abrir
la app y cada teléfono conserva sus propios datos. No ejecuto esta entrega en
Chrome: el almacenamiento y la cámara están preparados para Android.

## Organización

- lib/models: modelo y serialización.
- lib/data: repositorio, CRUD, consultas parametrizadas y migración v1 a v2.
- lib/services: archivos, cámara y preferencia de tema.
- lib/screens: resumen, formulario, detalle y ajustes.
- lib/widgets: componentes reutilizables.
- lib/utils: rutas constantes, estilos y validaciones.
- test e integration_test: pruebas de código, interfaz y Android.

## Funcionalidades y decisiones

Puedo crear, listar, editar, completar y eliminar registros. La lista y las métricas
se recargan cuando una ruta devuelve un resultado. Definí las rutas en AppRoutes.
SQLite guarda registros estructurados; SharedPreferences conserva el tema.
Valido obligatoriedad, longitud, formato institucional, rango numérico, categoría
y duplicados mediante una consulta asíncrona. Bloqueo el botón durante el envío.

Copio las fotografías de la caché al directorio privado de la aplicación. Antes de
pedir el permiso explico la finalidad. Si se deniega, puedo guardar sin foto; si se
bloquea permanentemente, ofrezco abrir ajustes. No utilizo GPS ni flujos continuos
de sensores, por lo que no tengo StreamSubscription que cancelar.

## Verificación

```powershell
flutter analyze
flutter test --reporter expanded
flutter build apk --debug -t lib/main.dart
```

Para ejecutar la prueba de diez recorridos en un emulador de pruebas:

```powershell
flutter drive --keep-app-running --driver test_driver/integration_test.dart --target integration_test/lifecycle_test.dart -d <id-android>
```

La prueba genera tiempos de navegación y comprueba 50 controladores liberados;
no medí el heap en esta ejecución y diez ciclos no demuestran
ausencia absoluta de fugas. Distingo las comprobaciones de código de las mediciones
nativas y no atribuyo a un teléfono físico lo que probé en un emulador.

## Privacidad y limitaciones

No sincronizo ni cifro los datos con esta aplicación. Desinstalarla o borrar sus
datos puede eliminarlos. Las fotos son opcionales. La demostración en hardware
físico y la revisión de accesibilidad completa quedan fuera de estas pruebas.
El informe y sus capturas se entregan por separado; no están publicados aquí.
