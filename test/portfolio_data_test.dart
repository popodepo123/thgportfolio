import "package:flutter_test/flutter_test.dart";
import "package:thgportfolio/portfolio_data.dart";
import "package:thgportfolio/skill_icons.dart";

void main() {
  test("resume-backed portfolio data stays complete", () {
    final skillNames = portfolio.skills
        .expand((category) => category.skills)
        .map((skill) => skill.name)
        .toSet();

    const resumeSkills = {
      "Dart",
      "Web (JavaScript, HTML, CSS)",
      "VBA",
      "SQL",
      "Kotlin",
      "Swift",
      "Flutter",
      "Jaspr (Dart Web Framework)",
      "MIT App Inventor",
      "Serverpod",
      "Firebase",
      "Google Cloud Platform",
      "Figma",
      "Codex",
      "Bash",
      "PowerShell",
    };

    expect(skillNames, containsAll(resumeSkills));
    expect(skillNames.every(skillIcons.containsKey), isTrue);
    expect(portfolio.resumeAssetPath, "assets/resume_thg_dev_20260718.pdf");
    expect(portfolio.experiences.first.company, contains("DAPL IT Services"));
    expect(portfolio.experiences.first.period, "January 2026 - Present");
  });

  test("AI coding agents are published as other tools", () {
    final otherTools = portfolio.skills
        .singleWhere((category) => category.categoryName == "Other Tools")
        .skills;
    final toolsByName = {for (final skill in otherTools) skill.name: skill};
    const codingAgents = {"OMP", "Codex", "Claude Code"};

    expect(toolsByName.keys, containsAll(codingAgents));
    for (final agentName in codingAgents) {
      final agent = toolsByName[agentName];
      if (agent == null) continue;
      expect(agent.description.trim(), isNotEmpty);
      expect(agent.websiteUrl, startsWith("https://"));
      expect(skillIcons, contains(agentName));
    }
  });

  test("Felix is published as an ongoing Flutter-Helix IDE", () {
    final felix = portfolio.projects.singleWhere(
      (project) => project.title == "Felix - Flutter-Helix IDE",
    );

    expect(portfolio.projects.first, same(felix));
    expect(felix.description.toLowerCase(), contains("ongoing"));
    expect(felix.description, contains("Helix"));
    expect(felix.gitlabLink, "https://gitlab.com/godoytristanh/custom-ide");
    expect(
      felix.features,
      containsAll(<String>[
        "Flutter desktop workbench backed by a native Rust bridge to the Helix editing engine",
        "Buffer tabs and panes, project file tree, file pickers, previews, and modal editing workflows",
        "Language-server features, diagnostics, hover information, integrated terminal, and debugger support",
      ]),
    );
  });

  test("published project and hobby media has useful metadata", () {
    final projectImages = portfolio.projects.expand(
      (project) => project.images ?? const <ProjectImage>[],
    );
    expect(projectImages, isNotEmpty);
    for (final image in projectImages) {
      expect(image.title.trim(), isNotEmpty);
      expect(image.description.trim(), isNotEmpty);
    }

    final sevenKnights = portfolio.hobbies
        .expand((category) => category.items)
        .singleWhere((item) => item.name == "Seven Knights Re:BIRTH");
    expect(
      sevenKnights.imageAsset,
      "assets/images/hobbies/seven_knights_rebirth.png",
    );
    expect(sevenKnights.imageUrl, isNull);
  });
}
