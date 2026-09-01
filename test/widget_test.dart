import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbmt_smart_bus/app.dart';

void main() {
  testWidgets('App boots to the home dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const MbmtApp());
    await tester.pump();

    // Greeting + search bar are on the home screen.
    expect(find.textContaining('Good'), findsWidgets);
    expect(find.text('Where do you want to go?'), findsOneWidget);

    // Bottom navigation is present.
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Journey'), findsWidgets);
    expect(find.text('Tickets'), findsWidgets);
  });

  testWidgets('Quick action opens the Buy Ticket screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MbmtApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Buy Ticket').first);
    await tester.pumpAndSettle();

    expect(find.text('Proceed to Pay  ·  ₹25'), findsOneWidget);
  });
}
