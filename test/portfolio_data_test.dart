import "package:flutter_test/flutter_test.dart";
import "package:thgportfolio/portfolio_data.dart";
import "package:thgportfolio/skill_preview_images.dart";

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
    expect(portfolio.resumeAssetPath, "assets/resume_thg_dev_20260718.pdf");
    expect(portfolio.experiences.first.company, contains("DAPL IT Services"));
    expect(portfolio.experiences.first.period, "January 2026 - Present");
  });

  test("tech stack groups every skill by capability", () {
    final skillsByCategory = <String, Set<String>>{
      for (final category in portfolio.skills)
        category.categoryName: {
          for (final skill in category.skills) skill.name,
        },
    };
    const expectedSkillsByCategory = <String, Set<String>>{
      "Mobile & App Development": {
        "Dart",
        "Flutter",
        "Kotlin",
        "Swift",
        "MIT App Inventor",
      },
      "Web, Backend & Data": {
        "Web (JavaScript, HTML, CSS)",
        "Jaspr (Dart Web Framework)",
        "Serverpod",
        "SQL",
        "Google Apps Script",
        "VBA",
      },
      "Cloud & APIs": {"Firebase", "Google Cloud Platform", "Postman"},
      "Editors & Native Toolchains": {
        "VS Code",
        "Android Studio",
        "Xcode",
        "Helix/Vim/Neovim",
      },
      "Version Control, CI & Automation": {
        "Git",
        "GitHub",
        "Bitbucket",
        "Sourcetree",
        "Codemagic",
        "Bash",
        "PowerShell",
      },
      "AI Development Tools": {
        "Codex",
        "Claude Code",
        "OMP",
        "OpenCode",
        "Gemini CLI",
        "Antigravity 2",
        "Google AI Studio",
        "Ollama",
        "Firebase Studio",
        "LM Studio",
      },
      "Design & Planning": {"Figma", "Trello"},
    };

    expect(skillsByCategory.keys, orderedEquals(expectedSkillsByCategory.keys));
    for (final category in expectedSkillsByCategory.entries) {
      expect(skillsByCategory[category.key], equals(category.value));
    }

    final publishedSkills = portfolio.skills
        .expand((category) => category.skills)
        .map((skill) => skill.name)
        .toList();
    expect(publishedSkills.toSet(), hasLength(publishedSkills.length));
  });

  test("skill preview content is sourced and renderable", () {
    final skillsByName = {
      for (final category in portfolio.skills)
        for (final skill in category.skills) skill.name: skill,
    };

    expect(skillPreviewImageUrls.keys, everyElement(isIn(skillsByName.keys)));
    expect(skillPreviewImageUrls.values, everyElement(startsWith("https://")));
    for (final skill in skillsByName.values) {
      expect(skill.description.trim(), isNotEmpty);
    }

    expect(
      skillsByName["VBA"]?.websiteUrl,
      "https://learn.microsoft.com/en-us/office/vba/api/overview/",
    );
    expect(
      skillsByName["Antigravity 2"]?.websiteUrl,
      "https://antigravity.google/",
    );
  });

  test("AI coding agents are published as AI development tools", () {
    final aiDevelopmentTools = portfolio.skills
        .singleWhere(
          (category) => category.categoryName == "AI Development Tools",
        )
        .skills;
    final toolsByName = {
      for (final skill in aiDevelopmentTools) skill.name: skill,
    };
    const codingAgents = {"OMP", "Codex", "Claude Code"};

    expect(toolsByName.keys, containsAll(codingAgents));
    for (final agentName in codingAgents) {
      final agent = toolsByName[agentName];
      if (agent == null) continue;
      expect(agent.description.trim(), isNotEmpty);
      expect(agent.websiteUrl, startsWith("https://"));
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
