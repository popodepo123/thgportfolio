import 'package:flutter/material.dart';
import 'package:thgportfolio/pages/dev_view.dart';
import 'package:thgportfolio/portfolio_data.dart';
import 'package:thgportfolio/sections/experience_section.dart';
import 'package:thgportfolio/sections/footer_section.dart';
import 'package:thgportfolio/sections/hero_section.dart';
import 'package:thgportfolio/sections/other_me_section.dart';
import 'package:thgportfolio/sections/projects_section.dart';
import 'package:thgportfolio/sections/skills_section.dart';
import 'package:thgportfolio/theme.dart';
import 'package:thgportfolio/view_provider.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _otherScrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    _otherScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<PortfolioView>(
        valueListenable: portfolioViewNotifier,
        builder: (context, view, child) {
          return Stack(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: _buildView(view, context),
              ),
              // Subtle View Toggle in Bottom Right
              Positioned(bottom: 16, right: 16, child: _buildModeToggle(view)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildModeToggle(PortfolioView currentView) {
    final isDev = currentView == PortfolioView.dev;
    final isMobile = MediaQuery.of(context).size.width < 600;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          portfolioViewNotifier.value = isDev
              ? PortfolioView.professional
              : PortfolioView.dev;
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 8 : 12,
            vertical: isMobile ? 4 : 6,
          ),
          decoration: BoxDecoration(
            color: gruberBgLighter,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: gruberYellow.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isDev ? Icons.person_outline : Icons.terminal_outlined,
                size: isMobile ? 14 : 16,
                color: gruberYellow,
              ),
              const SizedBox(width: 8),
              Text(
                isDev ? 'PROFESSIONAL' : 'DEVELOPER',
                style: TextStyle(
                  color: gruberYellow,
                  fontSize: isMobile ? 9 : 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabHeader(int index, String label, BuildContext context) {
    final tabController = DefaultTabController.maybeOf(context);
    final isMobile = MediaQuery.of(context).size.width < 600;
    if (tabController == null) {
      return Text(label);
    }
    return ListenableBuilder(
      listenable: tabController,
      builder: (context, child) {
        final isSelected = tabController.index == index;
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => tabController.animateTo(index),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 4 : 8,
                vertical: 4,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? gruberYellow : gruberFg,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: isMobile ? 12 : 14,
                      fontFamily: "Fira Code",
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 2,
                    width: label.length * (isMobile ? 7.0 : 8.0),
                    decoration: BoxDecoration(
                      color: isSelected ? gruberYellow : Colors.transparent,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildView(PortfolioView view, BuildContext context) {
    if (view == PortfolioView.dev) {
      return const DevView(key: ValueKey('dev_view'));
    }
    final isMobile = MediaQuery.of(context).size.width < 600;
    return SelectionArea(
      key: const ValueKey('prof_view'),
      child: DefaultTabController(
        length: 3,
        child: Builder(
          builder: (context) {
            return Column(
              children: [
                Container(
                  color: gruberBgDarker,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : 24,
                    vertical: 12,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildTabHeader(0, 'Work', context),
                        SizedBox(width: isMobile ? 16 : 32),
                        _buildTabHeader(1, 'Other Me', context),
                        SizedBox(width: isMobile ? 16 : 32),
                        _buildTabHeader(2, 'Blogs', context),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildProfessionalTab(context),
                      _buildOtherTab(context),
                      _buildBlogsTab(context),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBlogsTab(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.edit_note, size: 64, color: gruberQuartz),
          SizedBox(height: 16),
          Text(
            'Coming Soon',
            style: TextStyle(
              color: gruberQuartz,
              fontSize: 24,
              fontFamily: "Fira Code",
            ),
          ),
          SizedBox(height: 8),
          Text(
            'I will be sharing my thoughts and technical deep-dives here.',
            style: TextStyle(color: gruberQuartz, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalTab(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SingleChildScrollView(
            controller: _scrollController,
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

  Widget _buildOtherTab(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SingleChildScrollView(
            controller: _otherScrollController,
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [OtherMeSection(), FooterSection()],
            ),
          ),
        ),
      ),
    );
  }
}
