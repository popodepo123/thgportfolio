import 'package:flutter/material.dart';
import 'package:thgportfolio/portfolio_data.dart';

class ExperienceSection extends StatefulWidget {
  const ExperienceSection({super.key});

  @override
  State<ExperienceSection> createState() => _ExperienceSectionState();
}

class _ExperienceSectionState extends State<ExperienceSection> {
  final Map<int, bool> _expandedStates = {};

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Professional Experience', style: textTheme.headlineMedium),
          const SizedBox(height: 16),
          ...portfolio.experiences.asMap().entries.map((entry) {
            final index = entry.key;
            final exp = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: ExpansionTile(
                  initiallyExpanded: _expandedStates[index] ?? false,
                  onExpansionChanged: (bool expanded) {
                    setState(() {
                      _expandedStates[index] = expanded;
                    });
                  },
                  title: Text(exp.role, style: textTheme.titleLarge),
                  subtitle: Text(
                    '${exp.company} | ${exp.period}',
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(exp.description, style: textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
