import 'package:flutter/material.dart';
import 'package:thgportfolio/sections/experience_section.dart';
import 'package:thgportfolio/sections/footer_section.dart';
import 'package:thgportfolio/sections/hero_section.dart';
import 'package:thgportfolio/sections/projects_section.dart';
import 'package:thgportfolio/sections/skills_section.dart';
import 'package:thgportfolio/widgets/side_panel.dart';

final GlobalKey heroSectionKey = GlobalKey();
final GlobalKey skillsSectionKey = GlobalKey();
final GlobalKey projectsSectionKey = GlobalKey();
final GlobalKey experienceSectionKey = GlobalKey();
final GlobalKey footerSectionKey = GlobalKey();

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SelectionArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 768) {
              // Wide screen layout
              return Row(
                children: [
                  // Side Panel
                  SidePanel(scrollController: _scrollController),
                  // Main Content
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(
                            context,
                          ).copyWith(scrollbars: false),
                          child: SingleChildScrollView(
                            controller: _scrollController, // Attach controller
                            physics: const ClampingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(vertical: 48),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                HeroSection(key: heroSectionKey),
                                SkillsSection(key: skillsSectionKey),
                                ProjectsSection(key: projectsSectionKey),
                                ExperienceSection(key: experienceSectionKey),
                                FooterSection(key: footerSectionKey),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            } else {
              // Narrow screen layout
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(
                      context,
                    ).copyWith(scrollbars: false),
                    child: SingleChildScrollView(
                      controller: _scrollController, // Attach controller
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          HeroSection(key: heroSectionKey),
                          SkillsSection(key: skillsSectionKey),
                          ProjectsSection(key: projectsSectionKey),
                          ExperienceSection(key: experienceSectionKey),
                          FooterSection(key: footerSectionKey),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
