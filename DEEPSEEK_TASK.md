# Tarea de implementación para DeepSeek

## 1. Objetivo y estado inspeccionado

Crear una única pantalla Flutter: «Resumen semanal de hábitos de estudio y bienestar», para Desarrollo de Software II. Es una demostración visual académica de composición, constraints, adaptación, accesibilidad y calidad visual.

Directorio de trabajo obligatorio: `E:\desII`. Al inspeccionarlo estaba vacío, incluidos archivos ocultos: no existen código, dependencias, pubspec.yaml, pruebas ni arquitectura previa. Codex solo preparó este documento, sin implementar componentes. Flutter está localizado en `E:\FLUTTER\flutter\bin\flutter.bat`; su metadata local indica Flutter 3.41.7 estable y Dart 3.11.5. Confirmar con `flutter --version` al comenzar.

## 2. Restricciones innegociables

- Todos los widgets propios deben extender exclusivamente StatelessWidget. Prohibidos StatefulWidget, setState y cualquier gestor de estado: Provider, Riverpod, BLoC, GetX, etc. Los widgets del SDK requeridos están permitidos aunque internamente gestionen estado; la restricción se aplica al código de la aplicación.
- Datos constantes/mock. No calcular métricas con lógica de negocio. Sí se permite calcular anchos de layout según constraints.
- Sin APIs, HTTP, Firebase, Supabase, backend, SQLite, shared_preferences ni persistencia de ningún tipo.
- Sin arquitectura por capas, repositories, services, controllers, inyección de dependencias ni carpetas equivalentes.
- Una sola pantalla, sin navegación ni funcionalidades extra. Callbacks null o vacíos, sin efectos, modificaciones de datos ni eventos funcionales. Preferir contenido estático sin botones innecesarios.
- Usar Material y los iconos incluidos en Flutter. Sin paquetes adicionales, fuentes remotas, imágenes descargadas ni assets necesarios.
- Código simple, nombres descriptivos, const donde corresponda, comentarios solo para decisiones relevantes. No introducir widgets artificialmente para completar una lista.

## 3. Inicialización y dependencias

Desde `E:\desII`, inicializar con `flutter create --empty --project-name resumen_semanal --platforms=android,web .`. Conservar este documento. Si el directorio ya contiene trabajo nuevo al comenzar, inspeccionarlo antes de ejecutar el comando y no sobrescribirlo a ciegas.

El comando genera los archivos de plataforma y pubspec.yaml necesarios. No editar manualmente archivos generados de plataforma. Mantener las dependencias predeterminadas necesarias del SDK y flutter_lints para análisis; no añadir paquetes. Confirmar `uses-material-design: true` en pubspec.yaml. No hay un pubspec previo que corregir.

## 4. Estructura y archivos

```text
lib/
  main.dart
  screens/weekly_summary_screen.dart
  widgets/header_section.dart
  widgets/weekly_calendar.dart
  widgets/metric_card.dart
  widgets/progress_summary.dart
  widgets/achievement_card.dart
  widgets/reminder_card.dart
  utils/app_constants.dart
test/
  weekly_summary_screen_test.dart
```

Modificar el main.dart generado: main llama runApp; aplicación StatelessWidget con MaterialApp, tema Material 3, sin banner de depuración y WeeklySummaryScreen como home. Crear los demás archivos anteriores. Si existe una prueba del contador generada por Flutter, reemplazarla por pruebas de esta pantalla. Sustituir README.md generado con instrucciones breves para ejecutar, validar y explicar decisiones de layout. No crear capas adicionales ni archivos vacíos para futuras funciones.

## 5. Responsabilidades y contratos

- `WeeklySummaryScreen`: Scaffold, SafeArea, scroll vertical único, ancho máximo centrado de 1120 dp, título visible, separación de secciones y adaptación de métricas. Orden: encabezado, título «Tu resumen semanal», calendario, métricas, progreso, logro, recordatorios.
- `HeaderSection`: saludo, fecha fija y CircleAvatar de 48 dp con inicial «A». Row con Expanded alrededor de la Column de textos; avatar con etiqueta «Perfil de ejemplo». No interacción.
- `WeeklyCalendar`: título «Esta semana» y siete días completos; LayoutBuilder local decide Row con siete Expanded o Wrap con celdas de ancho finito. Cada día contiene abreviatura, número y estado con icono y texto. Clase auxiliar privada StatelessWidget permitida en el mismo archivo.
- `MetricCard`: recibe icono, nombre, valor, unidad y estado como parámetros finales, constructor const. Card o Container con fondo suave, valor destacado y texto de estado. Sin altura fija.
- `ProgressSummary`: progreso semanal de 82 % con LinearProgressIndicator(value: 0.82), y cumplimiento de metas de 82 % con CircularProgressIndicator(value: 0.82). Cada indicador tiene su propio porcentaje visible y descripción accesible. Circular dentro de SizedBox finito de 80 x 80; texto numérico fuera del círculo para admitir escalado sin recortes. Alinear ambos bloques en Row solo si caben; de lo contrario Column.
- `AchievementCard`: Stack con tarjeta «5 días de racha» y texto «Semana productiva»; insignia de trofeo superpuesta mediante Positioned en la esquina superior. Reservar 24 dp de espacio superior y 56 dp lateral para evitar que la insignia tape el texto. La tarjeta conserva altura natural según contenido. La insignia queda dentro de los límites del Stack.
- `ReminderCard`: Card con Icon, nombre y hora. Row con Expanded para el nombre; en ancho estrecho o texto grande, hora debajo del nombre para evitar overflow.
- `app_constants.dart`: constantes de colores, espaciados, radios y datos mock. Usar listas const y, si facilitan lectura, pequeños tipos inmutables en este mismo archivo; sin lógica, servicios ni cálculo de porcentajes.

La sección de recordatorios, dentro de la pantalla, usa ListView.separated con exactamente tres ReminderCard, shrinkWrap: true, primary: false y NeverScrollableScrollPhysics. El scroll exterior mueve toda la página; esta lista corta no requiere otro scroll.

## 6. Datos mock definitivos

No usar DateTime.now ni servicios de fecha. Fecha fija: «Martes, 6 de octubre de 2026». Saludo: «Buenos días, Alex». Semana de ejemplo: «28 sep. – 4 oct. de 2026», claramente rotulada como semana resumida anterior.

| Día | Número | Estado |
| --- | --- | --- |
| Lun | 28 | Cumplido |
| Mar | 29 | Cumplido |
| Mié | 30 | Cumplido |
| Jue | 1 | Cumplido |
| Vie | 2 | Cumplido |
| Sáb | 3 | Pendiente |
| Dom | 4 | Pendiente |

| Métrica | Valor | Unidad | Estado | Icono sugerido |
| --- | --- | --- | --- | --- |
| Horas de estudio | 18 | h | Meta cumplida | menu_book |
| Sueño | 7,5 | h por noche | Óptimo | bedtime |
| Actividad física | 180 | min | Meta cumplida | directions_run |
| Cumplimiento de metas | 82 | % | 18 de 22 completadas | flag |

Progreso semanal: 0.82 y etiqueta «82 %». Cumplimiento: 0.82 y etiqueta «82 %». Son valores constantes suministrados, no resultados calculados de los días cumplidos. Logro: «5 días de racha», «Semana productiva». Recordatorios: «Estudiar Redes», «19:00», menu_book; «Actividad física», «07:00», directions_run; «Dormir», «22:30», bedtime. Son ejemplos sin acciones.

## 7. Dirección visual y tokens

Inspiración conceptual en Google Fit: calma, espacio en blanco, jerarquía y tarjetas suaves. Fitia solo inspira la representación de días cumplidos y racha. Crear composición original; no copiar logos ni pantallas. No hace falta investigar ni descargar referencias.

- Fondo #F7F9FC; superficies #FFFFFF; tarjetas suaves #EDF3FA.
- Texto principal #172B4D; secundario #42526E; acento #2457A7; éxito #216E4E sobre #E8F5ED. Confirmar contraste en las combinaciones finales; no usar acentos claros para texto sobre blanco.
- Escala de separación: 4, 8, 12, 16, 24, 32 dp. Padding de tarjeta 16; separación de métricas 12; separación entre secciones 24.
- Radios: tarjetas 16, chips 12. Elevación 0 en todas las tarjetas; borde sutil opcional consistente.
- Título de pantalla 28, sección 20, valor 30, cuerpo 16, información secundaria 14 sp. Permitir el escalado del sistema; no fijar textScaler ni reducir texto para hacerlo caber.
- Sin alturas fijas para tarjetas o textos y sin exceso de decoración.

## 8. Responsive, breakpoints y constraints

Usar LayoutBuilder dentro del contenido ya limitado por padding y ancho máximo: sus constraints.maxWidth son el ancho realmente disponible. MediaQuery.sizeOf(context).width decide padding exterior: 16 dp si viewport < 600, 24 dp desde 600. MediaQuery.textScalerOf(context) permite detectar texto grande. Considerar texto grande cuando scale(16) > 20; mantener el escalado original y adoptar distribuciones más verticales.

Métricas: Wrap con spacing/runSpacing 12. Cuatro columnas si ancho disponible >= 900 y texto normal; dos columnas por debajo. Ancho de tarjeta = (ancho disponible - separación * (columnas - 1)) / columnas. Para ancho excepcional < 280 o texto grande, permitir una columna como salvaguarda de accesibilidad; a 320–430 dp con escala normal deben verse dos columnas. Justificación: cuatro tarjetas conservan aproximadamente 216 dp cada una desde 900, y el móvil distribuye dos filas.

Calendario: Row y siete Expanded si ancho local >= 700 y texto normal. Por debajo, Wrap con spacing/runSpacing 8; calcular columnas que aseguren aproximadamente 96 dp mínimos por celda (128 con texto grande), limitar de 1 a 7, y asignar ancho finito según el espacio. Se permite usar floor/clamp para layout, no para métricas. Nunca colocar Expanded dentro de Wrap. No fijar altura de celdas.

Progreso: Row con Expanded en cada bloque si ancho local >= 600 y texto normal; Column en otro caso. Recordatorios: apilar hora si ancho local < 360 o texto grande. Estos son umbrales locales simples, no un sistema global complejo.

Scroll exterior: SingleChildScrollView -> Center -> ConstrainedBox(maxWidth: 1120) -> Padding -> LayoutBuilder -> Column(mainAxisSize: min). El ancho debe quedar acotado por el viewport. No usar Expanded/Flexible vertical en esa Column bajo scroll, ni un ListView sin shrinkWrap dentro de ella. Expanded se reserva para Row de ancho finito. No anidar GridView de altura indefinida: usar Wrap para métricas. Indicadores siempre con ancho o dimensiones finitas. Textos largos admiten varias líneas, sin truncar valores o estados esenciales. Evitar FittedBox, recortes y ellipsis como remedios para overflow.

## 9. Accesibilidad y uso pertinente de widgets

Estados de días: check + «Cumplido», círculo vacío + «Pendiente», además del color. Semantics puede reunir día, fecha y estado. Iconos decorativos deben excluirse de semántica para evitar lectura duplicada; iconos que aporten significado sin texto deben tener semanticLabel. Avatar con descripción, no anuncio de acción. Indicadores con semanticsLabel y semanticsValue «82 %»; comprobar que el lector no repita innecesariamente la misma información. Texto visible siempre conserva los porcentajes.

No hay controles activos. Si se introduce un control demostrativo autorizado, mantener callback null/vacío y área mínima de 48 x 48 dp, sin lógica. No añadir acciones para justificar esta regla.

| Widget obligatorio | Uso |
| --- | --- |
| Text, Icon | Datos, títulos y estados |
| Container, Card | Fondos de días y tarjetas |
| Row, Column, Expanded | Encabezado y distribuciones acotadas |
| Stack, Positioned | Insignia superpuesta del logro |
| Wrap | Métricas y calendario estrecho |
| LayoutBuilder | Decisiones por ancho local disponible |
| MediaQuery | Padding por viewport y adaptación al escalado |
| CircleAvatar | Avatar del encabezado |
| ListView | Tres recordatorios |
| LinearProgressIndicator | Progreso semanal determinado |
| CircularProgressIndicator | Cumplimiento determinado |

## 10. Criterios de aceptación obligatorios

El trabajo NO está terminado hasta comprobar todos los puntos:

- [ ] Solo StatelessWidget en widgets propios; sin StatefulWidget ni setState.
- [ ] Sin gestores de estado, API, backend o persistencia; datos totalmente mock y constantes.
- [ ] Encabezado con saludo, fecha y CircleAvatar.
- [ ] Calendario con los siete días y estados identificables mediante texto e icono.
- [ ] Exactamente cuatro métricas, cada una con Icon, nombre, valor, unidad y estado textual.
- [ ] LinearProgressIndicator y CircularProgressIndicator determinados, ambos con porcentaje visible y accesible.
- [ ] Stack para insignia/logro; Wrap, Row, Column y Expanded utilizados pertinentemente.
- [ ] LayoutBuilder y MediaQuery tienen las responsabilidades indicadas.
- [ ] ListView con tres recordatorios, Card e Icon y sin acciones funcionales.
- [ ] Estados no dependen exclusivamente del color.
- [ ] Móvil: dos columnas de métricas; amplia: cuatro; calendario estrecho se reorganiza.
- [ ] Texto grande y anchos excepcionales conservan contenido con las salvaguardas definidas.
- [ ] Sin RenderFlex overflow, tamaños infinitos, unbounded constraints ni contenido cortado.
- [ ] Radios, elevaciones, colores, espaciados y jerarquía tipográfica consistentes.
- [ ] Nombres descriptivos, organización simple, const donde corresponde.
- [ ] Análisis, pruebas y revisión visual completados, o limitación de entorno declarada sin afirmar una validación no realizada.

## 11. Procedimiento de validación y entrega

1. Confirmar SDK con `flutter --version`; ejecutar `flutter pub get`.
2. Formatear con `dart format lib test`; ejecutar `flutter analyze` y corregir errores y warnings relevantes sin relajar las restricciones.
3. Crear pruebas útiles en weekly_summary_screen_test.dart y ejecutar `flutter test`. Cubrir presencia de los seis bloques y cuatro métricas; valores de ambos indicadores; ausencia de excepciones de layout al montar la app en 320 x 800, 390 x 844, 768 x 1024 y 1280 x 900; repetir un móvil y una pantalla amplia con TextScaler.linear(2). Restablecer tamaño de vista y escala al terminar cada prueba. Verificar además ancho de las tarjetas/distribución 2 y 4 columnas en escala normal y estados accesibles. No conservar pruebas del contador ni pruebas que solo duplican constantes sin revisar comportamiento.
4. Ejecutar `flutter run -d chrome` (o dispositivo Android disponible). Verificar visualmente al menos 390 y 1280 dp de ancho; revisar también 320, 768 y texto al 200 %. Recorrer toda la página hasta recordatorios. Confirmar porcentajes, insignia, legibilidad, contraste y ausencia de errores en consola. Las pruebas no sustituyen la revisión visual.
5. Revisar fuentes de lib buscando StatefulWidget, setState, gestores, red y persistencia; revisar pubspec y callbacks. No auditar internals del SDK como si fueran código propio.
6. Si falta dispositivo/navegador o SDK falla, describir el bloqueo exacto y lo pendiente. No declarar completada la validación visual sin ejecutarla ni agregar dependencias/funciones para sortear las restricciones.
7. Entregar resumen de archivos, comandos y resultados reales, tamaños revisados y limitaciones. Detenerse después de la pantalla solicitada: no agregar pantallas, cuentas, navegación, almacenamiento o lógica de hábitos.
