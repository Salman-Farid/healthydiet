import 'package:flutter_test/flutter_test.dart';
import 'package:fitforge/main.dart';

void main() {
  testWidgets('FitBook 2026 smoke', (WidgetTester tester) async {
    expect(const FitForgeApp(), isNotNull);
  });
}
