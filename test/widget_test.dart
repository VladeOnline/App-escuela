import 'package:flutter_test/flutter_test.dart';

import 'package:app_escuela/main.dart';

void main() {
  testWidgets('App inicia correctamente', (WidgetTester tester) async {
    await tester.pumpWidget(const AppEscuela());
    expect(find.byType(AppEscuela), findsOneWidget);
  });
}
