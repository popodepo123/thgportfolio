import 'package:flutter/material.dart';
import 'package:thgportfolio/sections/ai_summary_section.dart';
import 'package:thgportfolio/sections/dev_setup_section.dart';
import 'package:thgportfolio/sections/hobbies_section.dart';
import 'package:thgportfolio/sections/inspirations_section.dart';

class OtherMeSection extends StatelessWidget {
  const OtherMeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Other things about me', style: textTheme.headlineMedium),
          const SizedBox(height: 24),
          const AISummarySection(),
          const SizedBox(height: 48),
          const DevSetupSection(),
          const SizedBox(height: 48),
          const HobbiesSection(),
          const SizedBox(height: 48),
          const InspirationsSection(),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
