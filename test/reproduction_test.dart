import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thgportfolio/sections/hero_section.dart';

void main() {
  testWidgets('HeroSection layout test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: HeroSection())),
      ),
    );

    expect(find.byType(HeroSection), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
