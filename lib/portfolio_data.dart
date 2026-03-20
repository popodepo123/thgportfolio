import 'package:flutter/material.dart'; // Added for GlobalKey

class PortfolioData {
  final String name;
  final String title;
  final String email;
  final String? gitlabUrl;
  final String? githubUrl;
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
  final String? url;
  final String? youtubeHandle;

  const Inspiration({
    required this.name,
    required this.description,
    this.url,
    this.youtubeHandle,
  });
}

class HobbyCategory {
  final String title;
  final List<String> items;

  const HobbyCategory({required this.title, required this.items});
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
  summary:
      'I am a proactive and deeply curious software developer who thrives on solving complex bottlenecks and building efficient, scalable systems. My approach to technology is intensely hands-on: I don\'t just use tools; I build custom automations, optimize workflows, and actively mold my development environment to enforce clean architecture.\n\nMy learning philosophy is rooted in practical, tenacious problem-solving. Whether I am untangling deep dependency conflicts, building secure backend proxy functions, or diving into terminal logs to bypass infrastructure friction, I view technical roadblocks as opportunities to master the underlying mechanics of a system. I am consistently expanding my boundaries across the full stack—exploring new languages, robust backend solutions, and cloud architectures to ensure I am always building smarter, faster, and more securely.',
  skills: [
    SkillCategory(
      categoryName: 'Programming Languages',
      skills: [
        SkillDetail(
          name: 'Dart',
          description:
              'An open-source, client-optimized programming language developed by Google for developing fast applications across various platforms, including web, mobile, and desktop, and is the foundational language for the Flutter UI framework.',
          websiteUrl: 'https://dart.dev',
        ),
        SkillDetail(
          name: 'Web (Javascript, HTML, CSS)',
          description:
              'A foundational set of technologies for building web pages and web applications. HTML provides the structure, CSS handles the styling, and JavaScript adds interactivity and dynamic behavior.',
        ),
        SkillDetail(
          name: 'VBA',
          description:
              'Visual Basic for Applications (VBA) is an implementation of Microsoft\'s event-driven programming language Visual Basic 6, which is built into most Microsoft Office applications. It allows for automation of tasks and extension of application functionality.',
          websiteUrl:
              'https://learn.microsoft.com/en-us/office/vba/library-reference/concepts/getting-started-with-vba',
        ),
        SkillDetail(
          name: 'SQL',
          description:
              'Structured Query Language (SQL) is a domain-specific language used to manage and manipulate data in relational database management systems. It is used for data querying, manipulation, definition, and control.',
          websiteUrl: 'https://www.iso.org/standard/76583.html',
        ),
      ],
    ),
    SkillCategory(
      categoryName: 'Frameworks',
      skills: [
        SkillDetail(
          name: 'Flutter',
          description:
              'An open-source UI software development kit (SDK) created by Google for crafting beautiful, fast user experiences for mobile, web, and desktop from a single codebase.',
          websiteUrl: 'https://flutter.dev',
        ),
        SkillDetail(
          name: 'Jaspr (Dart Web Framework)',
          description:
              'A modern, free, and open-source web framework for building websites using the Dart programming language, offering a development experience similar to Flutter but rendering native HTML and CSS.',
          websiteUrl: 'https://jaspr.site',
        ),
        SkillDetail(
          name: 'MIT App Inventor',
          description:
              'An intuitive, visual programming environment that enables individuals to build fully functional applications for Android and iOS devices using a blocks-based coding approach.',
          websiteUrl: 'https://appinventor.mit.edu/',
        ),
        SkillDetail(
          name: 'Serverpod (dart backend server)',
          description:
              'An open-source, scalable app server and backend framework written in Dart, specifically designed for the Flutter community, enabling full-stack Dart development with features like automatic code generation, caching, and ORM.',
          websiteUrl: 'https://serverpod.dev',
        ),
      ],
    ),
    SkillCategory(
      categoryName: 'Other Tools',
      skills: [
        SkillDetail(
          name: 'VS Code',
          description:
              'Visual Studio Code (VS Code) is a free, lightweight, and powerful source code editor developed by Microsoft, designed for building and debugging modern web and cloud applications with extensive language support and extensions.',
          websiteUrl: 'https://code.visualstudio.com/',
        ),
        SkillDetail(
          name: 'Android Studio',
          description:
              'Android Studio is the official Integrated Development Environment (IDE) for Android app development, providing a comprehensive suite of tools for code editing, testing, performance analysis, and deployment.',
          websiteUrl: 'https://developer.android.com/studio',
        ),
        SkillDetail(
          name: 'Xcode',
          description:
              'Xcode is Apple\'s integrated development environment (IDE) designed for developing software across all Apple platforms, including macOS, iOS, iPadOS, watchOS, tvOS, and visionOS, offering tools for coding, debugging, and interface design.',
          websiteUrl: 'https://developer.apple.com/xcode/',
        ),
        SkillDetail(
          name: 'Helix/Vim',
          description:
              'Helix is a modern, modal terminal-based text editor inspired by Vim, focusing on efficiency and a customizable editing experience. Vim (Vi IMproved) is a highly configurable text editor built to enable efficient text editing.',
          websiteUrl: 'https://helix-editor.com/',
        ),
        SkillDetail(
          name: 'Code Magic',
          description:
              'CodeMagic CI/CD is a cloud-based Continuous Integration/Continuous Delivery platform specifically designed for mobile application development, automating the build, test, and release pipeline for Flutter, React Native, and native apps.',
          websiteUrl: 'https://codemagic.io/',
        ),
        SkillDetail(
          name: 'Git',
          description:
              'Git is a free and open-source distributed version control system (DVCS) that efficiently tracks changes to files, commonly used by programmers for collaborative software development.',
          websiteUrl: 'https://git-scm.com/',
        ),
        SkillDetail(
          name: 'Github',
          description:
              'GitHub is a web-based platform for version control and collaboration, built around Git. It provides hosting for software development and version control using Git, and offers features like issue tracking, pull requests, and project management.',
          websiteUrl: 'https://github.com/',
        ),
        SkillDetail(
          name: 'Bitbucket',
          description:
              'Bitbucket is a Git-based source code repository hosting service owned by Atlassian, providing features for code and code review, continuous delivery, and integration with other Atlassian tools.',
          websiteUrl: 'https://bitbucket.org/',
        ),
        SkillDetail(
          name: 'Sourcetree',
          description:
              'Sourcetree is a free Git GUI (Graphical User Interface) client for Windows and Mac, developed by Atlassian, simplifying interaction with Git and Mercurial repositories through a visual interface.',
          websiteUrl: 'https://www.sourcetreeapp.com/',
        ),
        SkillDetail(
          name: 'Google Apps Script',
          description:
              'Google Apps Script is a cloud-based scripting platform developed by Google for lightweight application development within the Google Workspace ecosystem, allowing automation and extension of Google apps functionality using JavaScript.',
          websiteUrl: 'https://developers.google.com/apps-script',
        ),
        SkillDetail(
          name: 'Trello',
          description:
              'Trello is a visual project management tool that utilizes boards, lists, and cards to organize tasks and track progress, based on the Kanban board system, facilitating team collaboration and workflow customization.',
          websiteUrl: 'https://trello.com/',
        ),
        SkillDetail(
          name: 'Postman',
          description:
              'Postman is an API platform for building and using APIs, helping teams collaboratively build APIs that power workflows and intelligent agents. It supports the entire API lifecycle, including development, testing, management, and monitoring.',
          websiteUrl: 'https://www.postman.com/',
        ),
        SkillDetail(
          name: 'Gemini CLI',
          description:
              'A command-line interface for interacting with Google\'s Gemini API, enabling developers to integrate AI capabilities into their workflows.',
          websiteUrl: 'https://ai.google.dev/gemini-api/docs/reference/rest',
        ),
        SkillDetail(
          name: 'Ollama',
          description:
              'A tool for running large language models locally, providing a simple way to experiment with and deploy open-source models on your own machine.',
          websiteUrl: 'https://ollama.ai/',
        ),
      ],
    ),
  ],
  projects: [
    Project(
      title: 'KitaKits POS',
      webLink: 'https://kitakits-pos.web.app/',
      description:
          'A modern, secure, and highly efficient Point of Sale (POS) system built with Flutter and Firebase. Designed for store owners with powerful management tools and a simple ordering interface for staff.',
      features: [
        'Dual-Mode Authentication: Store Owner (Admin) and Kiosk Staff accounts',
        'Advanced Security: Root/Jailbreak detection, 2FA (TOTP), Biometric Lock, and Screen Protection',
        'Store & Item Management: Item registration with barcode support and SKU tracking',
        'Ordering & Sales: Real-time cart, responsive UI (Mobile/Tablet/Desktop), and Bluetooth thermal printer integration',
        'Architecture: Feature-First structure with Hooks Riverpod and GoRouter',
        'Maintenance: Force update system directly from Firestore',
      ],
    ),
    Project(
      title: 'Lapit: Rent Nearby',
      webLink: 'https://rentsearch-482010.web.app/',
      description:
          'A location-based peer-to-peer rental platform that allows users to find and rent items in their immediate vicinity using an interactive map interface.',
      features: [
        'Interactive Map: Real-time discovery of rental items using Google Maps SDK and Places API',
        'Anonymous Authentication: Low-friction entry for users to browse and interact with the platform',
        'FSA Architecture: Built using the Flutter Simple Architecture pattern for high maintainability and scalability',
        'Functional Programming: Robust logic implementation using fpdart (Either, Task, Unit)',
        'State Management: Manual Riverpod Notifiers and AsyncNotifiers with custom ViewBuilder pattern',
        'Responsive Design: Optimized for seamless performance across mobile and web platforms',
      ],
    ),
    Project(
      appstoreLink:
          'https://apps.apple.com/jp/app/easyorder-selfordersystem/id6446138891?l=en-US',
      playstoreLink:
          "https://play.google.com/store/apps/details?id=com.u10ff.easyorder&amp%3Bhl=es_US",
      title: 'Multi-Store Management & Point-of-Sale System',
      description:
          'Developed a mobile application used for multi store management. A combination of point of sales and menu management system.',
      features: [
        'REST API integration',
        'Thermal printer integration via Bluetooth (Classic and BLE) (used platform channels for printer SDK integration using obj-C in iOS)',
        'Image and video capturing',
        'Media editing (image and video viewport cropping with ffmpeg) (used dart isolates to prevent main thread freeze)',
        'MVVM code structure/architecture with riverpod for state management',
      ],
      images: [
        ProjectImageFromAsset(
          asset: 'assets/images/eo1.webp',
          title: '',
          description: '',
        ),
        ProjectImageFromAsset(
          asset: 'assets/images/eo2.webp',
          title: '',
          description: '',
        ),
        ProjectImageFromAsset(
          asset: 'assets/images/eo3.webp',
          title: '',
          description: '',
        ),
        ProjectImageFromAsset(
          asset: 'assets/images/eo4.webp',
          title: '',
          description: '',
        ),
      ],
    ),
    Project(
      appstoreLink:
          'https://apps.apple.com/jp/app/ev-navi/id6473770215?l=en-US',
      playstoreLink:
          "https://play.google.com/store/apps/details?id=com.evapp.evms",
      title: 'Electric Vehicle Charging Station Map',
      description:
          'Developed an electric vehicle charging station map. Includes navigation, account tiers, station comments with media and user based station detail corrections suggestions.',
      features: [
        'REST API integration',
        'Image capturing and cropping',
        'Google Maps API integration (SDK, Geolocation, Routes and Places)',
        'Maps application integration (Google, and Apple)',
        'Firebase Auth Integration',
        'Device Geolocation',
        'MVVM code structure/architecture with riverpod for state management',
        'SWApay payment integration',
      ],
      images: [
        ProjectImageFromAsset(
          asset: 'assets/images/ev1.webp',
          title: '',
          description: '',
        ),
        ProjectImageFromAsset(
          asset: 'assets/images/ev2.webp',
          title: '',
          description: '',
        ),
        ProjectImageFromAsset(
          asset: 'assets/images/ev3.webp',
          title: '',
          description: '',
        ),
      ],
    ),
    Project(
      gitlabLink: "https://gitlab.com/godoytristanh/fsa",
      title: 'Flutter Simple Architecture (FSA)',
      description:
          'A clean, scalable architectural pattern for Flutter applications emphasizing strict separation of concerns, View-Isolation, and maintainability.',
      features: [
        'Strict Page Types: Smart (Async/Complex), Simple (Sync/Forms), and Static (Stateless)',
        'Component Isolation: Logic-heavy (Smart) vs. Pure UI (Dumb) components',
        'State Management: Riverpod for global state and Flutter Hooks for local state',
        'Theme Management: Manual theme persistence using shared_preferences',
        'CLI Tooling: Custom \'fsa generate\' CLI for project scaffolding',
      ],
      images: [],
    ),
    Project(
      gitlabLink: "https://gitlab.com/godoytristanh/dart_filetree",
      githubLink: "https://github.com/popodepo123/dart_filetree",
      title: 'Dart Filetree for Helix',
      description:
          'A terminal-based file tree picker built with Dart and nocterm for integration with editors like Helix.',
      features: [
        "Interactive file tree navigation in terminal using nocterm UI framework",
        "File selection and operations with chooser file integration",
        "Local storage using Hive for settings persistence",
        "Cross-platform file system operations",
        "Helix editor integration via zellij for seamless file opening",
      ],
      images: [],
    ),
    Project(
      gitlabLink: "https://gitlab.com/godoytristanh/flutter_hotreload",
      title: 'Flutter Hotreload Automation',
      description:
          'Enhancing Flutter development cycles with automated hot reload capabilities and custom state preservation hooks.',
      features: [
        'Development Workflow: Reduces iteration time during Flutter development',
        'State Preservation: Mechanisms to ensure state is maintained or correctly reset during reload',
        'Integration: Programmatic reload triggers via external events',
      ],
      images: [],
    ),
  ],
  experiences: [
    Experience(
      role: 'Mobile Application Developer',
      company: 'Freelance / Individual Contractor',
      period: 'July 2023 - PRESENT',
      description:
          'Spearheaded the end-to-end development of two distinct mobile applications, enhancing operational efficiency and user engagement. For Project 1, designed and implemented a comprehensive multi-store management and point-of-sale system, streamlining inventory and sales processes. For Project 2, engineered an electric vehicle charging station map with advanced features including navigation, tiered accounts, and user-driven data correction, significantly improving user experience and data accuracy. Actively engaged in continuous feature development and project improvement for both applications.',
    ),
    Experience(
      role: 'Business and Technology Integration Delivery Analyst',
      company: 'Accenture, Inc. [ Full Time ]',
      period: 'October 2023 - August 2025',
      description:
          'Drove digital transformation initiatives by developing robust web applications and automation scripts using SQL, JavaScript, HTML, CSS, and Google Apps Script. Successfully designed and implemented data CRUD operations, cleanup, transformation, and reporting solutions, resulting in enhanced data integrity and streamlined business processes. Created interactive dashboards, optimized data pipelines, and automated critical workflows, significantly improving operational efficiency and decision-making capabilities.',
    ),
    Experience(
      role: 'Office Engineer',
      company: 'Mighty Construction [ Full Time ]',
      period: 'March 2021 - September 2023',
      description:
          'Engineered and deployed critical database and system solutions using MS Access and VBA, optimizing processes for payroll, contracts, project expenses, and materials management. Leveraged VBA and MS Excel to conduct comprehensive project analysis, including budget, expense, and profitability assessments, providing key insights for strategic decision-making. Contributed to the successful preparation of detailed project bidding estimates, directly impacting project acquisition.',
    ),
  ],
  education: [
    Education(
      degree: 'BS in Civil Engineering',
      institution: 'Pamantasan ng Lungsod ng Valenzuela',
      period: 'June 2014 - April 2019',
    ),
  ],
  awards: [
    Award(
      name:
          'Manulife Ureka Innovation Camp 2016 Consultant Developer for ETSI Nexus App (3rd Place) (Ionic Prototype Application)',
      issuer: 'Manulife',
    ),
    Award(
      name: 'PRC Civil Engineering Professional (0176577)',
      issuer: 'Professional Regulation Commission',
    ),
  ],
  inspirations: [
    Inspiration(
      name: 'ThePrimeagen',
      description:
          'A Vim/Neovim enthusiast and Netflix engineer known for his high-energy educational content on development workflow, tooling, and low-level engineering. His focus on "moving fast" and mastering your editor has heavily influenced my approach to developer productivity.',
      url: 'https://www.theprimeagen.com/',
      youtubeHandle: '@ThePrimeagen',
    ),
    Inspiration(
      name: 'Tsoding (Alexey Kutepov)',
      description:
          'A legendary low-level programmer who builds everything from scratch—from compilers to game engines. His "painless" approach to complex problems and deep dives into C, assembly, and custom tooling inspire me to understand systems at their most fundamental level.',
      url: 'https://tsoding.org/',
      youtubeHandle: '@tsoding',
    ),
    Inspiration(
      name: 'Teej (TJ DeVries)',
      description:
          'A Neovim core contributor and Lua enthusiast. His work on Telescope and his deep knowledge of editor internals demonstrate how powerful a highly-tailored development environment can be.',
      url: 'https://github.com/tjdevries',
      youtubeHandle: '@teejdv',
    ),
    Inspiration(
      name: 'Casey Muratori',
      description:
          'A veteran game developer and performance advocate. His work on Handmade Hero and "Performance-Aware Programming" has taught me the importance of understanding the hardware and writing software that is efficient by design.',
      url: 'https://handmade.network/',
      youtubeHandle: '@cmuratori',
    ),
    Inspiration(
      name: 'Theo - t3.gg',
      description:
          'A sharp, opinionated developer focusing on the modern web ecosystem and AI updates. His focus on "DX" (Developer Experience) and the T3 stack has helped me stay on top of rapid changes in the web and AI landscape.',
      url: 'https://t3.gg/',
      youtubeHandle: '@t3dotgg',
    ),
  ],
  hobbies: [
    HobbyCategory(
      title: 'Gaming',
      items: ['League of Legends (PC)', 'WildRift', 'Valorant', 'Gunz the Duel', 'Dragon Nest'],
    ),
    HobbyCategory(
      title: 'Rhythm Games',
      items: ['osu! (Mania)', 'Deemo', 'Cytus', 'O2Jam', 'DJMax Respect V'],
    ),
    HobbyCategory(
      title: 'Mobile JRPG & Gacha',
      items: ['Soccer Spirits', 'Seven Knights Rebirth'],
    ),
  ],
);
