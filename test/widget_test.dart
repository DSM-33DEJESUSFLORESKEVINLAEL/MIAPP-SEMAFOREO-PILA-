import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:miapp/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Construir la aplicación y generar un frame.
    await tester.pumpWidget(MyApp()); // Se eliminó 'const'

    // Verificar que el contador inicia en 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Simular un tap en el botón '+' y generar un frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verificar que el contador incrementó a 1.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
