import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:resumen_semanal/main.dart' as app;
import 'package:resumen_semanal/services/local_services.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('nuevo proceso conserva el registro anterior', (tester) async {
    final services = await AppServices.open();
    final rows = await services.repository.list();
    expect(
      rows.any((e) => e.title == 'Práctica de Flutter Sesión 7' && e.completed),
      isTrue,
    );
    await tester.pumpWidget(app.ResumenSemanalApp(services: services));
    await tester.pumpAndSettle();
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await binding.takeScreenshot('06_lista_despues_reabrir');
    await services.repository.close();
  });
}
