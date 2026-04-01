import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thgportfolio/sections/hero_section.dart';

void main() {
  testWidgets('HeroSection layout test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: HeroSection())));

    // If it doesn't crash, the test passes.
    expect(find.byType(HeroSection), findsOneWidget);
  });
}
