
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ersatz_lounge/main.dart';

void main() {
  testWidgets('Dummy test', (WidgetTester tester) async {

    await tester.pumpWidget(const MyApp());

    //await tester.tap(find.bySemanticsLabel("Login"));
    //await tester.pump();

    //expect(find.text('Loading...'), findsOneWidget);
  });
}
