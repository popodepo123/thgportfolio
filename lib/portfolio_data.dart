import 'package:flutter/material.dart'; // Added for GlobalKey

class PortfolioData {
  final String name;
  final String title;
  final String email;
  final String? gitlabUrl;
  final String? githubUrl;
  final String resumeAssetPath;
  final String summary;
  final List<SkillCategory> skills;
  final List<Project> projects;
  final List<Experience> experiences;
  final List<Education> education;
  final List<Award> awards;
  final List<Inspiration> inspirations;
  final List<HobbyCategory> hobbies;

  const PortfolioData({
    required this.name,
    required this.title,
    required this.email,
    this.gitlabUrl,
    this.githubUrl,
    required this.resumeAssetPath,
    required this.summary,
    required this.skills,
    required this.projects,
    required this.experiences,
    required this.education,
    required this.awards,
    required this.inspirations,
    required this.hobbies,
  });
}

class Inspiration {
  final String name;
  final String description;
  final String? twitchHandle;
  final String? youtubeHandle;

  const Inspiration({
    required this.name,
    required this.description,
    this.twitchHandle,
    this.youtubeHandle,
  });
}

class HobbyCategory {
  final String title;
  final List<HobbyItem> items;

  const HobbyCategory({required this.title, required this.items});
}

class HobbyItem {
  final String name;
  final String? imageUrl;
  final String? imageAsset;
  final String? description;

  const HobbyItem({
    required this.name,
    this.imageUrl,
    this.imageAsset,
    this.description,
  }) : assert(imageUrl == null || imageAsset == null);
}

class SkillDetail {
  final String name;
  final String description;
  final String? websiteUrl;

  const SkillDetail({
    required this.name,
    this.description = '',
    this.websiteUrl,
  });
}

class SkillCategory {
  final String categoryName;
  final List<SkillDetail> skills;

  const SkillCategory({required this.categoryName, required this.skills});
}

class Project {
  final String title;
  final String description;
  final String? playstoreLink;
  final String? appstoreLink;
  final String? githubLink;
  final String? gitlabLink;
  final String? webLink;
  final List<String> features;
  final List<ProjectImage>? images;

  const Project({
    this.playstoreLink,
    this.appstoreLink,
    this.githubLink,
    this.gitlabLink,
    this.webLink,
    required this.title,
    required this.description,
    required this.features,
    this.images,
  });
}

sealed class ProjectImage {
  final String title;
  final String description;

  const ProjectImage({required this.title, required this.description});
}

class ProjectImageFromAsset extends ProjectImage {
  ProjectImageFromAsset({
    required this.asset,
    required super.title,
    required super.description,
  });
  final String asset;
}

class ProjectImageFromUrl extends ProjectImage {
  ProjectImageFromUrl({
    required this.url,
    required super.title,
    required super.description,
  });
  final String url;
}

class Experience {
  final String role;
  final String company;
  final String period;
  final String description;

  const Experience({
    required this.role,
    required this.company,
    required this.period,
    required this.description,
  });
}

class Education {
  final String degree;
  final String institution;
  final String period;

  const Education({
    required this.degree,
    required this.institution,
    required this.period,
  });
}

class OutlineSection {
  final String title;
  final GlobalKey key;

  const OutlineSection({required this.title, required this.key});
}

class Award {
  final String name;
  final String issuer;

  const Award({required this.name, required this.issuer});
}

final GlobalKey heroSectionKey = GlobalKey();
final GlobalKey skillsSectionKey = GlobalKey();
final GlobalKey projectsSectionKey = GlobalKey();
final GlobalKey experienceSectionKey = GlobalKey();
final GlobalKey otherMeSectionKey = GlobalKey();
final GlobalKey footerSectionKey = GlobalKey();

final portfolio = PortfolioData(
  name: 'Tristan Harvey Godoy',
  title: 'Mobile Application Developer',
  email: 'godoytristanh@gmail.com',
  githubUrl: 'https://github.com/popodepo123',
  gitlabUrl: 'https://gitlab.com/godoytristanh',
  resumeAssetPath: 'assets/resume_thg_dev_20260718.pdf',
  summary:
      "Mobile application developer focused on production Flutter systems, maintainable feature-first architecture, native platform integrations, and reliable developer tooling. My recent work includes online banking, restaurant ordering and point-of-sale workflows, EV charging maps, Bluetooth thermal printers, media pipelines, Firebase services, and REST APIs across Android, iOS, and web.",
  skills: [
    SkillCategory(
      categoryName: "Mobile & App Development",
      skills: [
        SkillDetail(
          name: "Dart",
          description: "Primary language for Flutter application development.",
          websiteUrl: "https://dart.dev",
        ),
        SkillDetail(
          name: "Flutter",
          description:
              "Cross-platform UI development for Android, iOS, and web.",
          websiteUrl: "https://flutter.dev",
        ),
        SkillDetail(
          name: "Kotlin",
          description:
              "Android-native integrations through Flutter platform channels.",
          websiteUrl: "https://kotlinlang.org",
        ),
        SkillDetail(
          name: "Swift",
          description: "iOS-native SDK and platform-channel integrations.",
          websiteUrl: "https://www.swift.org",
        ),
        SkillDetail(
          name: "MIT App Inventor",
          description:
              "Visual application-development environment used for rapid prototypes.",
          websiteUrl: "https://appinventor.mit.edu/",
        ),
      ],
    ),
    SkillCategory(
      categoryName: "Web, Backend & Data",
      skills: [
        SkillDetail(
          name: "Web (JavaScript, HTML, CSS)",
          description:
              "Web technologies used for interfaces, internal tools, and Google Apps Script web applications.",
          websiteUrl: "https://developer.mozilla.org/en-US/docs/Web",
        ),
        SkillDetail(
          name: "Jaspr (Dart Web Framework)",
          description:
              "Dart framework for server-rendered and client-rendered web experiences.",
          websiteUrl: "https://jaspr.site",
        ),
        SkillDetail(
          name: "Serverpod",
          description:
              "Dart backend framework designed for Flutter applications.",
          websiteUrl: "https://serverpod.dev",
        ),
        SkillDetail(
          name: "SQL",
          description:
              "Relational data querying, transformation, and reporting.",
        ),
        SkillDetail(
          name: "Google Apps Script",
          description:
              "Google Workspace automation and web application platform.",
          websiteUrl: "https://developers.google.com/apps-script",
        ),
        SkillDetail(
          name: "VBA",
          description: "Office automation and MS Access/Excel systems.",
          websiteUrl:
              "https://learn.microsoft.com/en-us/office/vba/library-reference/concepts/getting-started-with-vba",
        ),
      ],
    ),
    SkillCategory(
      categoryName: "Cloud & APIs",
      skills: [
        SkillDetail(
          name: "Firebase",
          description:
              "Authentication, Firestore, Cloud Functions, Hosting, Storage, Messaging, AI, and Crashlytics.",
          websiteUrl: "https://firebase.google.com/",
        ),
        SkillDetail(
          name: "Google Cloud Platform",
          description: "Google cloud infrastructure and managed services.",
          websiteUrl: "https://cloud.google.com/",
        ),
        SkillDetail(
          name: "Postman",
          description: "API development and testing platform.",
          websiteUrl: "https://www.postman.com/",
        ),
      ],
    ),
    SkillCategory(
      categoryName: "Editors & Native Toolchains",
      skills: [
        SkillDetail(
          name: "VS Code",
          description: "Source-code editor and debugging environment.",
          websiteUrl: "https://code.visualstudio.com/",
        ),
        SkillDetail(
          name: "Android Studio",
          description:
              "Android SDK, emulator, profiler, and native development environment.",
          websiteUrl: "https://developer.android.com/studio",
        ),
        SkillDetail(
          name: "Xcode",
          description:
              "Apple SDK, simulator, signing, and native iOS development environment.",
          websiteUrl: "https://developer.apple.com/xcode/",
        ),
        SkillDetail(
          name: "Helix/Vim/Neovim",
          description:
              "Modal terminal editors used in custom development workflows.",
          websiteUrl: "https://helix-editor.com/",
        ),
      ],
    ),
    SkillCategory(
      categoryName: "Version Control, CI & Automation",
      skills: [
        SkillDetail(
          name: "Git",
          description: "Distributed version control.",
          websiteUrl: "https://git-scm.com/",
        ),
        SkillDetail(
          name: "GitHub",
          description: "Git hosting and software collaboration platform.",
          websiteUrl: "https://github.com/",
        ),
        SkillDetail(
          name: "Bitbucket",
          description: "Atlassian Git hosting and collaboration platform.",
          websiteUrl: "https://bitbucket.org/",
        ),
        SkillDetail(
          name: "Sourcetree",
          description: "Desktop Git client from Atlassian.",
          websiteUrl: "https://www.sourcetreeapp.com/",
        ),
        SkillDetail(
          name: "Codemagic",
          description: "Mobile CI/CD build and deployment automation.",
          websiteUrl: "https://codemagic.io/",
        ),
        SkillDetail(
          name: "Bash",
          description: "Unix shell scripting and build automation.",
          websiteUrl: "https://www.gnu.org/software/bash/",
        ),
        SkillDetail(
          name: "PowerShell",
          description: "Cross-platform shell and task automation.",
          websiteUrl: "https://learn.microsoft.com/powershell/",
        ),
      ],
    ),
    SkillCategory(
      categoryName: "AI Development Tools",
      skills: [
        SkillDetail(
          name: "Codex",
          description:
              "OpenAI coding agent used for repository-scale development workflows.",
          websiteUrl: "https://openai.com/codex/",
        ),
        SkillDetail(
          name: "Claude Code",
          description: "Anthropic coding agent for terminal workflows.",
          websiteUrl: "https://www.anthropic.com/claude-code",
        ),
        SkillDetail(
          name: "OMP",
          description:
              "Oh My Pi terminal coding agent used for repository-scale development workflows.",
          websiteUrl: "https://github.com/can1357/oh-my-pi",
        ),
        SkillDetail(
          name: "OpenCode",
          description: "Open-source terminal coding agent.",
          websiteUrl: "https://opencode.ai/",
        ),
        SkillDetail(
          name: "Gemini CLI",
          description: "Open-source Gemini coding agent for the terminal.",
          websiteUrl: "https://github.com/google-gemini/gemini-cli",
        ),
        SkillDetail(
          name: "Antigravity 2",
          description:
              "Agentic development environment used for AI-assisted engineering workflows.",
        ),
        SkillDetail(
          name: "Google AI Studio",
          description: "Google interface for prototyping with Gemini models.",
          websiteUrl: "https://aistudio.google.com/",
        ),
        SkillDetail(
          name: "Ollama",
          description: "Local model runtime and command-line tooling.",
          websiteUrl: "https://ollama.com/",
        ),
        SkillDetail(
          name: "Firebase Studio",
          description:
              "Cloud development workspace for full-stack AI applications.",
          websiteUrl: "https://firebase.studio/",
        ),
        SkillDetail(
          name: "LM Studio",
          description:
              "Local large-language-model runtime and development environment.",
          websiteUrl: "https://lmstudio.ai/",
        ),
      ],
    ),
    SkillCategory(
      categoryName: "Design & Planning",
      skills: [
        SkillDetail(
          name: "Figma",
          description: "Collaborative interface design and prototyping.",
          websiteUrl: "https://www.figma.com/",
        ),
        SkillDetail(
          name: "Trello",
          description: "Kanban-based project and task management.",
          websiteUrl: "https://trello.com/",
        ),
      ],
    ),
  ],
  projects: [
    Project(
      title: "Felix - Flutter-Helix IDE",
      gitlabLink: "https://gitlab.com/godoytristanh/custom-ide",
      description:
          "An ongoing Flutter desktop IDE that combines the Helix editing engine with an Emacs-inspired, buffer-oriented workbench. Its Flutter interface communicates with pinned Helix Rust sources through a native bridge.",
      features: [
        "Flutter desktop workbench backed by a native Rust bridge to the Helix editing engine",
        "Buffer tabs and panes, project file tree, file pickers, previews, and modal editing workflows",
        "Language-server features, diagnostics, hover information, integrated terminal, and debugger support",
        "Upstream Helix keymaps, static and typable commands, syntax themes, and editor semantics",
        "Desktop targets for macOS, Linux, and Windows",
      ],
    ),
    Project(
      title: "KitaKits POS",
      webLink: "https://kitakits-pos.web.app/",
      description:
          "A Flutter and Firebase point-of-sale system for store owners and kiosk staff, with secure access, inventory controls, ordering, and responsive operation.",
      features: [
        "Store-owner and kiosk-staff authentication modes",
        "Root/jailbreak detection, TOTP two-factor authentication, biometric lock, and screen protection",
        "Store and item management with barcode and SKU support",
        "Responsive ordering and sales workflows with Bluetooth thermal printing",
        "Feature-first architecture with Hooks Riverpod and GoRouter",
        "Firestore-backed force-update controls",
      ],
    ),
    Project(
      title: "Lapit - Apartment and Condo Search",
      webLink: "https://rentsearch-482010.web.app/",
      description:
          "An in-progress apartment and condominium listings application that makes it easier to find rental homes near a preferred area or workplace.",
      features: [
        "Interactive map-based apartment and condominium discovery",
        "Nearby search using Google Maps SDK, geolocation, routes, and Places APIs",
        "Rental listing details organized around location and commute context",
        "Feature-first Flutter architecture with Riverpod",
        "Responsive mobile and web interfaces",
      ],
    ),
    Project(
      appstoreLink:
          "https://apps.apple.com/jp/app/easyorder-selfordersystem/id6446138891?l=en-US",
      playstoreLink:
          "https://play.google.com/store/apps/details?id=com.u10ff.easyorder",
      title: "Restaurant Multi-Store, POS, and Self-Ordering System",
      description:
          "A production mobile application combining multi-store management, point-of-sale, menu management, and restaurant self-ordering workflows.",
      features: [
        "REST API integration",
        "Bluetooth Classic and BLE thermal printer integration",
        "StarXpand and Epson ePOS SDK integration through Objective-C and Swift platform channels",
        "Image and video capture",
        "Media3 and AVFoundation viewport cropping, with Dart isolates protecting the main thread",
        "Android native API integration using Kotlin",
        "MVVM architecture with Riverpod state management",
      ],
      images: [
        ProjectImageFromAsset(
          asset: "assets/images/eo1.webp",
          title: "Restaurant ordering system",
          description:
              "Product overview highlighting sales growth, cost reduction, multilingual support, and operational efficiency.",
        ),
        ProjectImageFromAsset(
          asset: "assets/images/eo2.webp",
          title: "Mobile self-ordering",
          description: "Customer menu and ordering experience on a smartphone.",
        ),
        ProjectImageFromAsset(
          asset: "assets/images/eo3.webp",
          title: "Multi-device ordering",
          description:
              "Responsive ordering interface across phone and tablet devices.",
        ),
        ProjectImageFromAsset(
          asset: "assets/images/eo4.webp",
          title: "Tablet menu interface",
          description:
              "Restaurant menu and ordering workflow optimized for a tablet.",
        ),
      ],
    ),
    Project(
      appstoreLink:
          "https://apps.apple.com/jp/app/ev-navi/id6473770215?l=en-US",
      playstoreLink:
          "https://play.google.com/store/apps/details?id=com.evapp.evms",
      title: "EV Navi - Electric Vehicle Charging Map",
      description:
          "An EV and PHEV charging-station map with navigation, account tiers, media comments, and user-submitted station-detail corrections.",
      features: [
        "REST API integration",
        "Image capture and cropping",
        "Google Maps SDK, geolocation, routes, and Places API integration",
        "Google Maps and Apple Maps application integration",
        "Firebase Authentication",
        "Device geolocation",
        "MVVM architecture with Riverpod state management",
      ],
      images: [
        ProjectImageFromAsset(
          asset: "assets/images/ev1.webp",
          title: "Rapid-charger map",
          description: "Map mode focused on rapid EV charging stations.",
        ),
        ProjectImageFromAsset(
          asset: "assets/images/ev2.webp",
          title: "High-output charger details",
          description:
              "Map and station sheet for quickly identifying charger output.",
        ),
        ProjectImageFromAsset(
          asset: "assets/images/ev3.webp",
          title: "Charger pin comparison",
          description:
              "Station pins expose charger characteristics at a glance.",
        ),
      ],
    ),
    Project(
      gitlabLink: "https://gitlab.com/godoytristanh/fsa",
      title: "Flutter Simple Architecture (FSA)",
      description:
          "A CLI application for quickly bootstrapping and scaffolding a batteries-included clean Flutter architecture.",
      features: [
        "Project bootstrap and feature scaffolding commands",
        "Feature-first clean architecture defaults",
        "Riverpod state-management conventions",
        "Repeatable templates with batteries included",
      ],
    ),
    Project(
      gitlabLink: "https://gitlab.com/godoytristanh/dart_filetree",
      githubLink: "https://github.com/popodepo123/dart_filetree",
      title: "Dart File Tree",
      description:
          "A terminal file-tree explorer built with Dart for Helix editor integration.",
      features: [
        "Interactive terminal file-tree navigation",
        "Chooser-file integration for editor handoff",
        "Persistent settings",
        "Helix and terminal-multiplexer workflow integration",
      ],
    ),
    Project(
      gitlabLink:
          "https://gitlab.com/godoytristanh/dart_filetree/-/tree/main/rust_filetree?ref_type=heads",
      title: "Rust File Tree",
      description:
          "A terminal file-tree explorer built with Rust for Helix editor integration.",
      features: [
        "Terminal-native file browsing",
        "Fast Rust implementation",
        "Helix editor workflow integration",
      ],
    ),
    Project(
      gitlabLink: "https://gitlab.com/godoytristanh/flutter_hotreload",
      title: "Flutter Hotreload",
      description:
          "A TUI Flutter hot-reload application for terminal IDE integration.",
      features: [
        "Terminal UI for Flutter development sessions",
        "Hot reload and restart controls",
        "Terminal editor workflow integration",
      ],
    ),
  ],
  experiences: [
    Experience(
      role: "Mobile Application Developer",
      company: "DAPL IT Services [Contractor]",
      period: "January 2026 - Present",
      description:
          "Mobile online-banking application maintenance and new feature integration. Work includes REST APIs, feature-first clean architecture, BLoC state management, Flutter web mini-app integration, Ping SDK, Dynatrace, AppsFlyer, Thales NFC, push notifications, and developer build-script improvements.",
    ),
    Experience(
      role: "Mobile Application Developer",
      company: "Freelance",
      period: "July 2023 - Present",
      description:
          "Developed and maintained two production mobile applications: a multi-store management, point-of-sale, menu, and restaurant ordering system; and an EV charging-station map with navigation, account tiers, media comments, and user-submitted station corrections. Delivered REST APIs, Bluetooth thermal printers, native Android/iOS integrations, media capture and editing, Google Maps services, Firebase Authentication, geolocation, and MVVM/Riverpod architecture.",
    ),
    Experience(
      role:
          "Reports and Measurement Analyst / Business and Technology Integration Analyst",
      company: "Accenture, Inc. [Full Time]",
      period: "October 2023 - August 2025",
      description:
          "Recognized with two A-list awards. Built operations SLA and KPI dashboards, automated ETL data pipelines, custom Google Apps Script web applications, CRUD and reporting tools, and daily/monthly action workflows using SQL, JavaScript, HTML, and CSS. Served as an automation and custom-web-app subject matter expert; one high-utility tool was replicated across other projects.",
    ),
    Experience(
      role: "Office Engineer",
      company: "Mighty Construction [Full Time]",
      period: "March 2021 - September 2023",
      description:
          "Developed MS Access and VBA systems for payroll, contracts, project expenses, collections, material purchasing, and delivery monitoring. Used Excel and VBA for budget, expense, and profit analysis and assisted with detailed project-bid estimates.",
    ),
  ],
  education: [
    Education(
      degree: "BS in Civil Engineering",
      institution: "Pamantasan ng Lungsod ng Valenzuela",
      period: "June 2014 - April 2019",
    ),
  ],
  awards: [
    Award(
      name:
          "Manulife Ureka Innovation Camp 2016 Consultant Developer for ETSI Nexus App (3rd Place) (Ionic Prototype Application)",
      issuer: "Manulife",
    ),
    Award(
      name: "PRC Civil Engineering Professional (0176577)",
      issuer: "Professional Regulation Commission",
    ),
  ],
  inspirations: [
    Inspiration(
      name: 'ThePrimeagen',
      description:
          'A software engineer and Vim/Neovim enthusiast known for high-energy educational content on development workflow, tooling, and low-level engineering. His focus on "moving fast" and mastering your editor has heavily influenced my approach to developer productivity.',
      twitchHandle: 'ThePrimeagen',
      youtubeHandle: '@ThePrimeagen',
    ),
    Inspiration(
      name: 'Tsoding / Tsoding Daily (Alexey Kutepov)',
      description:
          'A legendary low-level programmer who builds everything from scratch—from compilers to game engines. His "painless" approach to complex problems and deep dives into C, assembly, and custom tooling inspire me to understand systems at their most fundamental level.',
      twitchHandle: 'tsoding',
      youtubeHandle: '@tsodingdaily',
    ),
    Inspiration(
      name: 'Teej (TJ DeVries)',
      description:
          'A Neovim core contributor and Lua enthusiast. His work on Telescope and his deep knowledge of editor internals demonstrate how powerful a highly-tailored development environment can be.',
      twitchHandle: 'teej_dv',
      youtubeHandle: '@teejdv',
    ),
    Inspiration(
      name: 'Casey Muratori',
      description:
          'A veteran game developer and performance advocate. His work on Handmade Hero and "Performance-Aware Programming" has taught me the importance of understanding the hardware and writing software that is efficient by design.',
      twitchHandle: 'cmuratori',
      youtubeHandle: '@MollyRocket',
    ),
    Inspiration(
      name: 'Theo - t3.gg',
      description:
          'A sharp, opinionated developer focusing on the modern web ecosystem and AI updates. His focus on "DX" (Developer Experience) and the T3 stack has helped me stay on top of rapid changes in the web and AI landscape.',
      twitchHandle: 'theo',
      youtubeHandle: '@t3dotgg',
    ),
  ],
  hobbies: [
    HobbyCategory(
      title: 'Gaming',
      items: [
        HobbyItem(
          name: "League of Legends (PC)",
          imageAsset: "assets/images/hobbies/league_of_legends.png",
          description:
              'A highly competitive, team-based strategy game where two teams of five champions face off.',
        ),
        HobbyItem(
          name: "League of Legends: Wild Rift",
          imageAsset: "assets/images/hobbies/wild_rift.png",
          description:
              'The fast-paced mobile and console adaptation of League of Legends.',
        ),
        HobbyItem(
          name: "VALORANT",
          imageAsset: "assets/images/hobbies/valorant.png",
          description:
              'A 5v5 character-based tactical shooter blending precise gunplay with unique agent abilities.',
        ),
        HobbyItem(
          name: "GunZ: The Duel",
          imageAsset: "assets/images/hobbies/gunz_the_duel.png",
          description:
              'A classic, fast-paced third-person shooter known for its acrobatic "K-Style" movement mechanics.',
        ),
        HobbyItem(
          name: "Dragon Nest",
          imageAsset: "assets/images/hobbies/dragon_nest.png",
          description:
              'A dynamic action RPG featuring intense non-targeting combat and epic boss raids.',
        ),
      ],
    ),
    HobbyCategory(
      title: 'Rhythm Games',
      items: [
        HobbyItem(
          name: "osu!mania",
          imageAsset: "assets/images/hobbies/osu.png",
          description:
              'A competitive, community-driven rhythm game mode hitting falling notes to the beat.',
        ),
        HobbyItem(
          name: "DEEMO",
          imageAsset: "assets/images/hobbies/deemo.jpg",
          description:
              'A story-driven rhythm game blending beautiful piano melodies with an emotional narrative.',
        ),
        HobbyItem(
          name: "Cytus",
          imageAsset: "assets/images/hobbies/cytus.jpg",
          description:
              'A futuristic rhythm game with a unique Active Scan Line system and electronic music.',
        ),
        HobbyItem(
          name: "O2Jam",
          imageAsset: "assets/images/hobbies/o2jam.jpg",
          description:
              'A classic PC rhythm game known for its challenging chart patterns and nostalgic tracks.',
        ),
        HobbyItem(
          name: "DJMAX RESPECT V",
          imageAsset: "assets/images/hobbies/djmax_respect_v.png",
          description:
              'The definitive edition of the legendary DJMax series with an extensive music library.',
        ),
      ],
    ),
    HobbyCategory(
      title: 'Mobile JRPG & Gacha',
      items: [
        HobbyItem(
          name: "Soccer Spirits",
          imageAsset: "assets/images/hobbies/soccer_spirits.jpg",
          description:
              'A fantasy soccer RPG card game featuring dynamic turn-based matches and anime artwork.',
        ),
        HobbyItem(
          name: "Seven Knights Re:BIRTH",
          imageAsset: "assets/images/hobbies/seven_knights_rebirth.png",
          description:
              'The highly anticipated remake of the classic mobile RPG with modernized 3D graphics.',
        ),
      ],
    ),
  ],
);
