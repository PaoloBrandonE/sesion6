import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resumen_semanal/screens/weekly_summary_screen.dart';
import 'package:resumen_semanal/utils/app_constants.dart';
import 'package:resumen_semanal/widgets/achievement_card.dart';
import 'package:resumen_semanal/widgets/header_section.dart';
import 'package:resumen_semanal/widgets/metric_card.dart';
import 'package:resumen_semanal/widgets/progress_summary.dart';
import 'package:resumen_semanal/widgets/reminder_card.dart';
import 'package:resumen_semanal/widgets/weekly_calendar.dart';

/// Monta la pantalla con un tamaño de vista y una escala de texto concretos.
Future<void> _pumpScreen(
  WidgetTester tester, {
  required Size size,
  double textScale = 1.0,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MediaQuery(
        data: MediaQueryData(
          size: size,
          textScaler: TextScaler.linear(textScale),
        ),
        child: const WeeklySummaryScreen(),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('composición de la pantalla', () {
    testWidgets('muestra los seis bloques y los textos fijos', (tester) async {
      await _pumpScreen(tester, size: const Size(390, 844));

      expect(find.byType(HeaderSection), findsOneWidget);
      expect(find.byType(WeeklyCalendar), findsOneWidget);
      expect(find.byType(MetricCard), findsNWidgets(4));
      expect(find.byType(ProgressSummary), findsOneWidget);
      expect(find.byType(AchievementCard), findsOneWidget);
      expect(find.byType(ReminderCard), findsNWidgets(3));

      expect(find.text(MockData.screenTitle), findsOneWidget);
      expect(find.text(MockData.greeting), findsOneWidget);
      expect(find.text(MockData.todayLabel), findsOneWidget);
      expect(find.text(MockData.avatarInitial), findsOneWidget);
      expect(find.text(MockData.weekRangeLabel), findsOneWidget);
    });

    testWidgets('calendario: siete días con estado por texto e icono', (
      tester,
    ) async {
      await _pumpScreen(tester, size: const Size(390, 844));

      for (final String abbreviation in <String>[
        'Lun',
        'Mar',
        'Mié',
        'Jue',
        'Vie',
        'Sáb',
        'Dom',
      ]) {
        expect(find.text(abbreviation), findsOneWidget);
      }
      expect(find.text('Cumplido'), findsNWidgets(5));
      expect(find.text('Pendiente'), findsNWidgets(2));
      expect(find.byIcon(Icons.check_circle), findsNWidgets(5));
      expect(find.byIcon(Icons.radio_button_unchecked), findsNWidgets(2));
    });

    testWidgets(
      'métricas: cada tarjeta tiene icono, nombre, valor, unidad y estado',
      (tester) async {
        await _pumpScreen(tester, size: const Size(1280, 900));

        final Finder metricCards = find.byType(MetricCard);
        expect(metricCards, findsNWidgets(4));

        // Se busca dentro de cada tarjeta porque algunos nombres también
        // aparecen en recordatorios o en los bloques de progreso.
        for (int i = 0; i < MockData.metrics.length; i++) {
          final WeeklyMetric metric = MockData.metrics[i];
          final Finder card = metricCards.at(i);
          expect(
            find.descendant(of: card, matching: find.text(metric.name)),
            findsOneWidget,
          );
          expect(
            find.descendant(of: card, matching: find.text(metric.value)),
            findsOneWidget,
          );
          expect(
            find.descendant(of: card, matching: find.text(metric.unit)),
            findsOneWidget,
          );
          expect(
            find.descendant(of: card, matching: find.text(metric.status)),
            findsOneWidget,
          );
          expect(
            find.descendant(of: card, matching: find.byType(Icon)),
            findsOneWidget,
          );
        }
      },
    );
  });

  group('indicadores de progreso', () {
    testWidgets('valores determinados y porcentaje visible', (tester) async {
      await _pumpScreen(tester, size: const Size(1280, 900));

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      final LinearProgressIndicator linear = tester
          .widget<LinearProgressIndicator>(
            find.byType(LinearProgressIndicator),
          );
      final CircularProgressIndicator circular = tester
          .widget<CircularProgressIndicator>(
            find.byType(CircularProgressIndicator),
          );
      expect(linear.value, MockData.weeklyProgressValue);
      expect(circular.value, MockData.goalsProgressValue);
      expect(find.text('82 %'), findsNWidgets(2));
    });

    testWidgets('los indicadores exponen label y valor accesibles', (
      tester,
    ) async {
      await _pumpScreen(tester, size: const Size(1280, 900));

      final Iterable<Semantics> semanticsWidgets = tester.widgetList<Semantics>(
        find.byType(Semantics),
      );
      final Semantics weekly = semanticsWidgets.firstWhere(
        (Semantics item) =>
            item.properties.label == MockData.weeklyProgressTitle,
      );
      final Semantics goals = semanticsWidgets.firstWhere(
        (Semantics item) =>
            item.properties.label == MockData.goalsProgressTitle,
      );
      expect(weekly.properties.value, MockData.weeklyProgressLabel);
      expect(goals.properties.value, MockData.goalsProgressLabel);
    });
  });

  group('accesibilidad', () {
    testWidgets('el estado del día se anuncia con icono y texto', (
      tester,
    ) async {
      await _pumpScreen(tester, size: const Size(390, 844));

      final Iterable<Semantics> semanticsWidgets = tester.widgetList<Semantics>(
        find.byType(Semantics),
      );
      expect(
        semanticsWidgets.any(
          (Semantics item) => item.properties.label == 'Lun 28, Cumplido',
        ),
        isTrue,
      );
      expect(
        semanticsWidgets.any(
          (Semantics item) => item.properties.label == 'Dom 4, Pendiente',
        ),
        isTrue,
      );
    });

    testWidgets('el avatar describe un perfil de ejemplo', (tester) async {
      await _pumpScreen(tester, size: const Size(390, 844));

      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(
        tester
            .widgetList<Semantics>(find.byType(Semantics))
            .any(
              (Semantics item) =>
                  item.properties.label == MockData.avatarSemantics,
            ),
        isTrue,
      );
    });
  });

  group('layout adaptativo', () {
    const List<Size> sizes = <Size>[
      Size(320, 800),
      Size(390, 844),
      Size(768, 1024),
      Size(1280, 900),
    ];

    for (final Size size in sizes) {
      testWidgets('sin excepciones de layout en '
          '${size.width.toInt()}x${size.height.toInt()}', (tester) async {
        await _pumpScreen(tester, size: size);
        expect(tester.takeException(), isNull);
        expect(find.byType(MetricCard), findsNWidgets(4));
        expect(find.byType(ReminderCard), findsNWidgets(3));
      });
    }

    testWidgets('móvil conserva el contenido con texto 200 %', (tester) async {
      await _pumpScreen(tester, size: const Size(390, 844), textScale: 2.0);
      expect(tester.takeException(), isNull);
      expect(find.byType(MetricCard), findsNWidgets(4));
      expect(find.byType(ReminderCard), findsNWidgets(3));
    });

    testWidgets('pantalla amplia conserva el contenido con texto 200 %', (
      tester,
    ) async {
      await _pumpScreen(tester, size: const Size(1280, 900), textScale: 2.0);
      expect(tester.takeException(), isNull);
      expect(find.byType(MetricCard), findsNWidgets(4));
    });
  });

  group('distribución de métricas', () {
    testWidgets('dos columnas en móvil', (tester) async {
      await _pumpScreen(tester, size: const Size(390, 844));
      final double cardWidth = tester
          .getSize(find.byType(MetricCard).first)
          .width;
      // disponible = 390 - 32 (padding) = 358; (358 - 12) / 2 = 173.
      expect(cardWidth, closeTo(173, 1.0));
    });

    testWidgets('cuatro columnas en pantalla amplia', (tester) async {
      await _pumpScreen(tester, size: const Size(1280, 900));
      final double cardWidth = tester
          .getSize(find.byType(MetricCard).first)
          .width;
      // disponible = min(1280, 1120) - 48 = 1072; (1072 - 36) / 4 = 259.
      expect(cardWidth, closeTo(259, 1.0));
    });

    testWidgets('una columna como salvaguarda con texto grande', (
      tester,
    ) async {
      await _pumpScreen(tester, size: const Size(390, 844), textScale: 2.0);
      final double cardWidth = tester
          .getSize(find.byType(MetricCard).first)
          .width;
      // disponible = 390 - 32 = 358; una columna usa todo el ancho.
      expect(cardWidth, closeTo(358, 1.0));
    });
  });
}
