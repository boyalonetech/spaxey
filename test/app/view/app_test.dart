// Ignore for testing purposes
// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:spaxey/app/app.dart';
import 'package:spaxey/counter/counter.dart';

void main() {
  group('App', () {
    testWidgets('renders CounterPage', (tester) async {
      await tester.pumpWidget(AppView());
      expect(find.byType(CounterPage), findsOneWidget);
    });
  });
}
