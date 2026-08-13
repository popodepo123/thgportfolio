class SkillPreviewContent {
  final String imageAssetPath;
  final String summary;

  const SkillPreviewContent({
    required this.imageAssetPath,
    required this.summary,
  });
}

const Map<String, SkillPreviewContent> skillPreviewContentByName = {
  "Dart": SkillPreviewContent(
    imageAssetPath: "assets/images/skills/dart.webp",
    summary:
        "Dart is a portable, productive programming language designed for building fast applications across mobile, web, desktop, and server platforms.",
  ),
  "Flutter": SkillPreviewContent(
    imageAssetPath: "assets/images/skills/flutter.webp",
    summary:
        "Flutter is an open-source UI framework for building natively compiled mobile, web, desktop, and embedded applications from one Dart codebase.",
  ),
  "Kotlin": SkillPreviewContent(
    imageAssetPath: "assets/images/skills/kotlin.webp",
    summary:
        "Kotlin is a concise, multiplatform language from JetBrains used for Android, backend, web, and desktop development with strong Java interoperability.",
  ),
  "Swift": SkillPreviewContent(
    imageAssetPath: "assets/images/skills/swift.webp",
    summary:
        "Swift is Apple's modern general-purpose language for building safe, fast software across iOS, macOS, watchOS, tvOS, and other platforms.",
  ),
  "MIT App Inventor": SkillPreviewContent(
    imageAssetPath: "assets/images/skills/mit_app_inventor.webp",
    summary:
        "MIT App Inventor is a browser-based, block-programming platform for rapidly creating, testing, and sharing Android and iOS applications.",
  ),
  "Web (JavaScript, HTML, CSS)": SkillPreviewContent(
    imageAssetPath: "assets/images/skills/web.webp",
    summary:
        "HTML structures web content, CSS controls presentation, and JavaScript adds behavior—together forming the core technology stack of the open web.",
  ),
  "Jaspr (Dart Web Framework)": SkillPreviewContent(
    imageAssetPath: "assets/images/skills/jaspr.webp",
    summary:
        "Jaspr is an open-source Dart framework for creating server-rendered and client-rendered websites using component-based, Flutter-inspired APIs.",
  ),
  "Serverpod": SkillPreviewContent(
    imageAssetPath: "assets/images/skills/serverpod.webp",
    summary:
        "Serverpod is an open-source, scalable Dart application server built for Flutter teams, with generated APIs, persistence, caching, and deployment tooling.",
  ),
  "SQL": SkillPreviewContent(
    imageAssetPath: "assets/images/skills/sql.webp",
    summary:
        "SQL is the standard language for defining, querying, transforming, and managing structured data stored in relational database systems.",
  ),
  "Google Apps Script": SkillPreviewContent(
    imageAssetPath: "assets/images/skills/google_apps_script.webp",
    summary:
        "Google Apps Script is a cloud-based JavaScript platform for automating Google Workspace, integrating services, and publishing lightweight web applications.",
  ),
  "VBA": SkillPreviewContent(
    imageAssetPath: "assets/images/skills/vba.webp",
    summary:
        "Visual Basic for Applications is Microsoft's event-driven language for extending Office applications and automating repetitive document and data workflows.",
  ),
  "Firebase": SkillPreviewContent(
    imageAssetPath: "assets/images/skills/firebase.webp",
    summary:
        "Firebase is Google's application platform for authentication, databases, functions, hosting, storage, messaging, analytics, and production monitoring.",
  ),
  "Google Cloud Platform": SkillPreviewContent(
    imageAssetPath: "assets/images/skills/google_cloud_platform.webp",
    summary:
        "Google Cloud provides managed compute, storage, networking, data, security, and AI services for building and operating applications at scale.",
  ),
  "Postman": SkillPreviewContent(
    imageAssetPath: "assets/images/skills/postman.webp",
    summary:
        "Postman is an API platform for designing requests, testing behavior, documenting contracts, sharing collections, and automating API lifecycle workflows.",
  ),
  "VS Code": SkillPreviewContent(
    imageAssetPath: "assets/images/skills/vs_code.webp",
    summary:
        "Visual Studio Code is a free, extensible source-code editor with integrated debugging, terminal access, version control, and language tooling.",
  ),
  "Android Studio": SkillPreviewContent(
    imageAssetPath: "assets/images/skills/android_studio.webp",
    summary:
        "Android Studio is Google's official Android IDE, combining code tools, emulators, profilers, build integration, and device debugging.",
  ),
  "Xcode": SkillPreviewContent(
    imageAssetPath: "assets/images/skills/xcode.webp",
    summary:
        "Xcode is Apple's development suite for building, testing, profiling, signing, and distributing applications across Apple platforms.",
  ),
  "Helix/Vim/Neovim": SkillPreviewContent(
    imageAssetPath: "assets/images/skills/helix_vim_neovim.webp",
    summary:
        "Helix, Vim, and Neovim are keyboard-driven modal editors built around composable commands, efficient navigation, and highly customizable development workflows.",
  ),
  "Git": SkillPreviewContent(
    imageAssetPath: "assets/images/skills/git.webp",
    summary:
        "Git is a distributed version-control system for tracking source history, branching safely, reviewing changes, and collaborating without a central dependency.",
  ),
  "GitHub": SkillPreviewContent(
    imageAssetPath: "assets/images/skills/github.webp",
    summary:
        "GitHub is a collaborative software-development platform built around Git repositories, pull requests, code review, issues, automation, and releases.",
  ),
  "Bitbucket": SkillPreviewContent(
    imageAssetPath: "assets/images/skills/bitbucket.webp",
    summary:
        "Bitbucket is Atlassian's Git hosting and CI/CD platform, with repository collaboration and close integration with Jira-based team workflows.",
  ),
  "Sourcetree": SkillPreviewContent(
    imageAssetPath: "assets/images/skills/sourcetree.webp",
    summary:
        "Sourcetree is Atlassian's desktop Git client for visualizing repository history and managing commits, branches, merges, and remote workflows.",
  ),
  "Codemagic": SkillPreviewContent(
    imageAssetPath: "assets/images/skills/codemagic.webp",
    summary:
        "Codemagic is a mobile-focused CI/CD platform that automates application builds, tests, signing, and delivery across major app ecosystems.",
  ),
  "Bash": SkillPreviewContent(
    imageAssetPath: "assets/images/skills/bash.webp",
    summary:
        "Bash is the GNU project's command shell and scripting language, widely used for interactive Unix workflows, build scripts, and task automation.",
  ),
  "PowerShell": SkillPreviewContent(
    imageAssetPath: "assets/images/skills/powershell.webp",
    summary:
        "PowerShell is a cross-platform command shell and automation language built around structured objects, reusable modules, and system-management tooling.",
  ),
  "Codex": SkillPreviewContent(
    imageAssetPath: "assets/images/skills/codex.webp",
    summary:
        "Codex is OpenAI's coding agent for reading repositories, editing code, running commands, reviewing changes, and completing software tasks across parallel workflows.",
  ),
  "Claude Code": SkillPreviewContent(
    imageAssetPath: "assets/images/skills/claude_code.webp",
    summary:
        "Claude Code is Anthropic's agentic development tool for understanding codebases, editing files, running commands, and assisting terminal-based engineering work.",
  ),
  "OMP": SkillPreviewContent(
    imageAssetPath: "assets/images/skills/omp.webp",
    summary:
        "Oh My Pi is a terminal coding agent with repository editing, language-server integration, browser tools, subagents, and an optimized tool harness.",
  ),
  "OpenCode": SkillPreviewContent(
    imageAssetPath: "assets/images/skills/opencode.webp",
    summary:
        "OpenCode is an open-source coding agent designed for terminal workflows, repository exploration, code modification, and model-flexible software assistance.",
  ),
  "Gemini CLI": SkillPreviewContent(
    imageAssetPath: "assets/images/skills/gemini_cli.webp",
    summary:
        "Gemini CLI is Google's open-source terminal agent for applying Gemini models to coding, research, automation, and repository-scale tasks.",
  ),
  "Antigravity 2": SkillPreviewContent(
    imageAssetPath: "assets/images/skills/antigravity_2.webp",
    summary:
        "Google Antigravity is an agent-first development platform for launching, coordinating, and monitoring coding agents across editor, terminal, and browser workflows.",
  ),
  "Google AI Studio": SkillPreviewContent(
    imageAssetPath: "assets/images/skills/google_ai_studio.webp",
    summary:
        "Google AI Studio is a browser workspace for prototyping Gemini prompts, testing multimodal models, configuring generation, and moving experiments toward production.",
  ),
  "Ollama": SkillPreviewContent(
    imageAssetPath: "assets/images/skills/ollama.webp",
    summary:
        "Ollama is a local model runtime and command-line tool for downloading, running, serving, and integrating open-weight language models.",
  ),
  "Firebase Studio": SkillPreviewContent(
    imageAssetPath: "assets/images/skills/firebase_studio.webp",
    summary:
        "Firebase Studio is a browser-based workspace for full-stack application development with Gemini assistance, cloud emulators, and integrated app previews.",
  ),
  "LM Studio": SkillPreviewContent(
    imageAssetPath: "assets/images/skills/lm_studio.webp",
    summary:
        "LM Studio is a desktop environment for discovering, running, testing, and serving local language models through a graphical interface and compatible APIs.",
  ),
  "Figma": SkillPreviewContent(
    imageAssetPath: "assets/images/skills/figma.webp",
    summary:
        "Figma is a collaborative design platform for interface design, interactive prototyping, shared design systems, developer handoff, and product ideation.",
  ),
  "Trello": SkillPreviewContent(
    imageAssetPath: "assets/images/skills/trello.webp",
    summary:
        "Trello is a visual work-management tool that organizes tasks and projects through boards, lists, cards, schedules, and team automation.",
  ),
};
