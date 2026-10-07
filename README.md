# Resumen semanal de hábitos de estudio y bienestar

Demostración visual académica de una **única pantalla** Flutter (Material 3) para
*Desarrollo de Software II*. Composición estática con datos mock: no hay
navegación, red, backend, persistencia ni gestores de estado.

## Requisitos

- Flutter 3.41.x estable (Dart 3.11.x). SDK local: `E:\FLUTTER\flutter\bin\flutter.bat`.

## Ejecutar

```powershell
flutter pub get
flutter run -d chrome     # o un dispositivo Android disponible
```

## Validar

```powershell
dart format lib test
flutter analyze
flutter test
```

## Estructura

```text
lib/
  main.dart                       # app StatelessWidget + MaterialApp (M3)
  screens/weekly_summary_screen.dart
  widgets/header_section.dart
  widgets/weekly_calendar.dart
  widgets/metric_card.dart
  widgets/progress_summary.dart
  widgets/achievement_card.dart
  widgets/reminder_card.dart
  utils/app_constants.dart        # tokens y datos mock
test/
  weekly_summary_screen_test.dart
```

## Decisiones de layout

- **Scroll único**: `SingleChildScrollView → Center → ConstrainedBox(maxWidth: 1120)
  → Padding → LayoutBuilder → Column(mainAxisSize: min)`. El ancho se acota por el
  viewport; no se usan flexibles verticales ni listas sin `shrinkWrap` dentro de la
  columna.
- **Padding exterior** por `MediaQuery.sizeOf`: 16 dp si el viewport mide menos de
  600, 24 dp desde 600.
- **Métricas** en `Wrap`: cuatro columnas con ancho disponible ≥ 900 y texto normal;
  dos columnas por debajo (a 320–430 dp se ven dos columnas); una columna como
  salvaguarda con texto grande o ancho < 280. Ancho de tarjeta =
  `(disponible − 12 × (columnas − 1)) / columnas`.
- **Calendario**: `Row` con siete `Expanded` si el ancho local ≥ 700 y el texto es
  normal; en caso contrario `Wrap` con celdas de ancho finito calculado para
  garantizar ~96 dp (128 con texto grande) por celda. Nunca hay `Expanded` en `Wrap`.
- **Progreso**: `Row` con dos `Expanded` si el ancho local ≥ 600 y texto normal;
  en otro caso `Column`. Los indicadores viven en cajas finitas y su porcentaje se
  muestra fuera del círculo.
- **Recordatorios**: `ListView.separated` anidado (`shrinkWrap`, `primary: false`,
  `NeverScrollableScrollPhysics`) con tres tarjetas; la hora baja al segundo renglón
  si el ancho local < 360 o el texto es grande.
- **Texto grande** se detecta con `MediaQuery.textScalerOf(context).scale(16) > 20`;
  se conserva el escalado del sistema y se adoptan distribuciones más verticales.

## Accesibilidad

- El estado de cada día usa icono + texto («Cumplido»/«Pendiente»), nunca solo color;
  `Semantics` reúne día, número y estado.
- Iconos decorativos se excluyen de la semántica; la insignia de trofeo aporta
  significado y lleva `semanticLabel`. El avatar describe «Perfil de ejemplo».
- Los indicadores exponen `label` y valor «82 %» visibles y accesibles; el texto
  visible conserva siempre el porcentaje.


## Informe técnico UI/UX

El informe LaTeX, su copia .txt y las capturas están en docs/informe/.
Para compilar, usar informe_ui_ux.tex como archivo principal y conservar las imágenes en la misma carpeta.

