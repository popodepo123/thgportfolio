import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:thgportfolio/sections/projects_section.dart";
import "package:thgportfolio/theme.dart";

void main() {
  testWidgets("renders separate featured and personal project groups", (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: portfolioTheme,
        home: const Scaffold(
          body: SingleChildScrollView(child: ProjectsSection()),
        ),
      ),
    );

    expect(find.text("Featured Projects"), findsOneWidget);
    expect(find.text("Personal Projects"), findsOneWidget);

    final featuredHeadingY = tester
        .getTopLeft(find.text("Featured Projects"))
        .dy;
    final lastFeaturedProjectY = tester
        .getTopLeft(find.text("EV Navi - Electric Vehicle Charging Map"))
        .dy;
    final personalHeadingY = tester
        .getTopLeft(find.text("Personal Projects"))
        .dy;
    final firstPersonalProjectY = tester
        .getTopLeft(find.text("Flutter Simple Architecture (FSA)"))
        .dy;

    expect(featuredHeadingY, lessThan(lastFeaturedProjectY));
    expect(lastFeaturedProjectY, lessThan(personalHeadingY));
    expect(personalHeadingY, lessThan(firstPersonalProjectY));
  });
}
