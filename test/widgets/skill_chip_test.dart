import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/gestures.dart';
import 'package:thgportfolio/portfolio_data.dart';
import 'package:thgportfolio/widgets/skill_chip.dart';
import 'package:thgportfolio/theme.dart';

void main() {
  group('SkillChip', () {
    testWidgets('SkillChip changes color and text color on hover', (
      WidgetTester tester,
    ) async {
      final skillDetail = SkillDetail(
        name: 'Flutter',
        description: 'Mobile App Development',
        websiteUrl: '',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: portfolioTheme, // Explicitly provide the theme
          home: Builder(
            builder: (BuildContext context) {
              return Scaffold(
                body: SkillChip(
                  skillDetail: skillDetail,
                  icon: Icons.flutter_dash,
                  textTheme: Theme.of(context).textTheme,
                ),
              );
            },
          ),
        ),
      );

      // Initial state
      final initialContainer = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      expect(initialContainer.decoration, isA<BoxDecoration>());
      expect(
        (initialContainer.decoration as BoxDecoration).color,
        Theme.of(
          tester.element(find.byType(MaterialApp)),
        ).colorScheme.surfaceContainerHighest,
      );

      final initialText = tester.widget<Text>(find.text('Flutter'));
      expect(initialText.style?.color, isNotNull);
      expect(initialText.style?.color, Colors.white);

      // Hover state
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(
        location: tester.getCenter(find.byType(SkillChip)),
      );
      await tester.pumpAndSettle();

      final hoveredContainer = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      expect(
        (hoveredContainer.decoration as BoxDecoration).color,
        Theme.of(tester.element(find.byType(MaterialApp))).colorScheme.tertiary,
      );

      final hoveredText = tester.widget<Text>(find.text('Flutter'));
      expect(hoveredText.style?.color, Colors.black);
    });
  });
}
