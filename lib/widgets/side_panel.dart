import 'package:flutter/material.dart';
import 'package:thgportfolio/pages/portfolio_page.dart';

class SidePanel extends StatelessWidget {
  final ScrollController scrollController;

  const SidePanel({super.key, required this.scrollController});

  void _scrollToSection(GlobalKey key) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: 200, // Adjust width as needed
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Outline', style: textTheme.headlineSmall),
          const SizedBox(height: 16),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: ListTile(
              title: Text('Hero Section', style: textTheme.bodyMedium),
              onTap: () => _scrollToSection(heroSectionKey),
            ),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: ListTile(
              title: Text('Tech Stack', style: textTheme.bodyMedium),
              onTap: () => _scrollToSection(skillsSectionKey),
            ),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: ListTile(
              title: Text('Featured Projects', style: textTheme.bodyMedium),
              onTap: () => _scrollToSection(projectsSectionKey),
            ),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: ListTile(
              title: Text(
                'Professional Experience',
                style: textTheme.bodyMedium,
              ),
              onTap: () => _scrollToSection(experienceSectionKey),
            ),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: ListTile(
              title: Text('Contact', style: textTheme.bodyMedium),
              onTap: () => _scrollToSection(footerSectionKey),
            ),
          ),
        ],
      ),
    );
  }
}
