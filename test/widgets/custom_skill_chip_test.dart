import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:thgportfolio/portfolio_data.dart";
import "package:thgportfolio/theme.dart";
import "package:thgportfolio/widgets/custom_skill_chip.dart";
import "package:thgportfolio/widgets/skill_widgets.dart";
import "package:thgportfolio/widgets/skill_preview_card.dart";

void main() {
  group("CustomSkillChip", () {
    testWidgets("changes color and text color on hover without an icon", (
      WidgetTester tester,
    ) async {
      const skillDetail = SkillDetail(
        name: "Flutter",
        description: "Mobile App Development",
        websiteUrl: "https://flutter.dev",
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: portfolioTheme,
          home: const Scaffold(body: CustomSkillChip(skillDetail: skillDetail)),
        ),
      );

      final chipFinder = find.byType(CustomSkillChip);
      final theme = Theme.of(tester.element(chipFinder));
      final initialContainer = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      expect(initialContainer.decoration, isA<BoxDecoration>());
      expect(
        (initialContainer.decoration as BoxDecoration).color,
        theme.colorScheme.surfaceContainerHighest,
      );
      expect(
        find.descendant(of: chipFinder, matching: find.byType(Icon)),
        findsNothing,
      );

      final initialText = tester.widget<Text>(find.text("Flutter"));
      expect(initialText.style?.color, theme.colorScheme.onSurface);

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: tester.getCenter(chipFinder));
      await tester.pumpAndSettle();

      final hoveredContainer = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      expect(
        (hoveredContainer.decoration as BoxDecoration).color,
        theme.colorScheme.primary,
      );

      expect(
        tester.widget<Text>(find.text("Flutter")).style?.color,
        theme.colorScheme.onPrimary,
      );
      await gesture.removePointer();
    });

    testWidgets("opens details with bundled artwork and a hardcoded summary", (
      WidgetTester tester,
    ) async {
      const skillDetail = SkillDetail(
        name: "Flutter",
        description: "Cross-platform app development.",
        websiteUrl: "https://flutter.dev",
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: portfolioTheme,
          home: const Scaffold(body: CustomSkillChip(skillDetail: skillDetail)),
        ),
      );

      await tester.tap(find.text("Flutter"));
      await tester.pumpAndSettle();

      expect(find.byType(SkillDetailDialog), findsOneWidget);
      expect(
        find.textContaining("Flutter is an open-source UI framework"),
        findsOneWidget,
      );
      expect(find.text("Summary"), findsOneWidget);
      expect(find.text("Source: flutter.dev"), findsOneWidget);
      expect(find.byType(SkillPreviewCard), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      expect(tester.widget<Image>(find.byType(Image)).image, isA<AssetImage>());
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text("Open Website"), findsOneWidget);
    });
  });
}
