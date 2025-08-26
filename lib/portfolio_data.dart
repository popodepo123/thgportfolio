import 'package:flutter/material.dart'; // Added for GlobalKey

class PortfolioData {
  final String name;
  final String title;
  final String email;
  final String summary;
  final List<SkillCategory> skills;
  final List<Project> projects;
  final List<Experience> experiences;
  final List<Education> education;
  final List<Award> awards;

  const PortfolioData({
    required this.name,
    required this.title,
    required this.email,
    required this.summary,
    required this.skills,
    required this.projects,
    required this.experiences,
    required this.education,
    required this.awards,
  });
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
  final List<String> features;
  final List<ProjectImage>? images;

  const Project({
    required this.title,
    required this.description,
    required this.features,
    this.images,
  });
}

class ProjectImage {
  final String url;
  final String title;
  final String description;

  const ProjectImage({
    required this.url,
    required this.title,
    required this.description,
  });
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
final GlobalKey footerSectionKey = GlobalKey();

const portfolio = PortfolioData(
  name: 'Tristan Harvey Godoy',
  title: 'Mobile Application Developer',
  email: 'godoytristanh@gmail.com',
  summary:
      'A versatile Mobile Application Developer specializing in Flutter and full-stack Dart. Experienced in creating intuitive, high-performance mobile applications from concept to deployment, with a strong background in system automation and data analysis.',
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
        ProjectImage(
          url: 'https://picsum.photos/seed/project1_1/200/300',
          title: 'Login Screen',
          description:
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
        ),
        ProjectImage(
          url: 'https://picsum.photos/seed/project1_2/200/300',
          title: 'Dashboard View',
          description:
              'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
        ),
        ProjectImage(
          url: 'https://picsum.photos/seed/project1_3/200/300',
          title: 'Product Catalog',
          description:
              'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',
        ),
        ProjectImage(
          url: 'https://picsum.photos/seed/project1_4/200/300',
          title: 'POS Interface',
          description:
              'Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
        ),
        ProjectImage(
          url: 'https://picsum.photos/seed/project1_5/200/300',
          title: 'Order Management',
          description:
              'Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt.',
        ),
        ProjectImage(
          url: 'https://picsum.photos/seed/project1_6/200/300',
          title: 'Inventory Tracking',
          description:
              'Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.',
        ),
        ProjectImage(
          url: 'https://picsum.photos/seed/project1_7/200/300',
          title: 'Reporting Analytics',
          description:
              'Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur?',
        ),
        ProjectImage(
          url: 'https://picsum.photos/seed/project1_8/200/300',
          title: 'User Profile',
          description:
              'Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?',
        ),
        ProjectImage(
          url: 'https://picsum.photos/seed/project1_9/200/300',
          title: 'Settings Page',
          description:
              'At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident.',
        ),
        ProjectImage(
          url: 'https://picsum.photos/seed/project1_10/200/300',
          title: 'Printer Setup',
          description:
              'Similique sunt in culpa qui officia deserunt mollitia animi, id est laborum et dolorum fuga.',
        ),
      ],
    ),
    Project(
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
      ],
      images: [
        ProjectImage(
          url: 'https://picsum.photos/seed/project2_1/200/300',
          title: 'Map View with Stations',
          description:
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
        ),
        ProjectImage(
          url: 'https://picsum.photos/seed/project2_2/200/300',
          title: 'Station Details',
          description:
              'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
        ),
        ProjectImage(
          url: 'https://picsum.photos/seed/project2_3/200/300',
          title: 'Navigation Route',
          description:
              'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',
        ),
        ProjectImage(
          url: 'https://picsum.photos/seed/project2_4/200/300',
          title: 'User Account Tiers',
          description:
              'Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
        ),
        ProjectImage(
          url: 'https://picsum.photos/seed/project2_5/200/300',
          title: 'Comments Section',
          description:
              'Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt.',
        ),
        ProjectImage(
          url: 'https://picsum.photos/seed/project2_6/200/300',
          title: 'Media Upload',
          description:
              'Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.',
        ),
        ProjectImage(
          url: 'https://picsum.photos/seed/project2_7/200/300',
          title: 'Correction Suggestion Form',
          description:
              'Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur?',
        ),
        ProjectImage(
          url: 'https://picsum.photos/seed/project2_8/200/300',
          title: 'Search Functionality',
          description:
              'Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?',
        ),
        ProjectImage(
          url: 'https://picsum.photos/seed/project2_9/200/300',
          title: 'Filter Options',
          description:
              'At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident.',
        ),
        ProjectImage(
          url: 'https://picsum.photos/seed/project2_10/200/300',
          title: 'Settings and Preferences',
          description:
              'Similique sunt in culpa qui officia deserunt mollitia animi, id est laborum et dolorum fuga.',
        ),
      ],
    ),
  ],
  experiences: [
    Experience(
      role: 'Mobile Application Developer',
      company: 'Freelance',
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
);
