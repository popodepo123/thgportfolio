import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";
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
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.byType(SkillDetailDialog), findsOneWidget);
      expect(
        find.textContaining("Flutter is an open-source UI framework"),
        findsOneWidget,
      );
      expect(find.text("Summary"), findsOneWidget);
      expect(find.text("Source: flutter.dev"), findsOneWidget);
      expect(find.byType(SkillPreviewCard), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      final previewImage = tester.widget<Image>(find.byType(Image));
      expect(previewImage.image, isA<AssetImage>());
      expect(previewImage.frameBuilder, isNotNull);
      final previewCard = tester.widget<Container>(
        find.byKey(const ValueKey("skill-preview-card")),
      );
      final foregroundDecoration =
          previewCard.foregroundDecoration as BoxDecoration;
      expect(foregroundDecoration.border, isA<Border>());
      expect(find.text("Open Website"), findsOneWidget);

      final frameBuilder = previewImage.frameBuilder!;
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        MaterialApp(
          theme: portfolioTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) =>
                  frameBuilder(context, const SizedBox(), null, false),
            ),
          ),
        ),
      );

      final loadingIndicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(loadingIndicator.semanticsLabel, "Loading Flutter artwork");
    });

    testWidgets("shows the correct bundled logo instead of unrelated artwork", (
      WidgetTester tester,
    ) async {
      const skillDetail = SkillDetail(
        name: "PowerShell",
        description: "Cross-platform shell and task automation.",
        websiteUrl: "https://learn.microsoft.com/powershell/",
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: portfolioTheme,
          home: const Scaffold(body: CustomSkillChip(skillDetail: skillDetail)),
        ),
      );

      await tester.tap(find.text("PowerShell"));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.byType(SvgPicture), findsOneWidget);
      expect(
        tester.widget<SvgPicture>(find.byType(SvgPicture)).semanticsLabel,
        "PowerShell logo",
      );
      final previewLogo = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(previewLogo.placeholderBuilder, isNotNull);
      expect(find.byType(Image), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        MaterialApp(
          theme: portfolioTheme,
          home: Scaffold(
            body: Builder(builder: previewLogo.placeholderBuilder!),
          ),
        ),
      );

      final loadingIndicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(loadingIndicator.semanticsLabel, "Loading PowerShell logo");
    });
  });
}
