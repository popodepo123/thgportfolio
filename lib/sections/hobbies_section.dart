import 'package:flutter/material.dart';
import 'package:thgportfolio/portfolio_data.dart';
import 'package:thgportfolio/theme.dart';

class HobbiesSection extends StatelessWidget {
  const HobbiesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hobbies & Interests', style: textTheme.titleLarge),
        const SizedBox(height: 16),
        ...portfolio.hobbies.map((category) => _HobbyCategoryWidget(category: category)),
      ],
    );
  }
}

class _HobbyCategoryWidget extends StatelessWidget {
  final HobbyCategory category;
  const _HobbyCategoryWidget({required this.category});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category.title,
            style: const TextStyle(
              color: gruberNiagara,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: category.items.map((item) => _HobbyChip(label: item)).toList(),
          ),
        ],
      ),
    );
  }
}

class _HobbyChip extends StatelessWidget {
  final String label;
  const _HobbyChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: gruberBg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: gruberBgLighter),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: gruberFg,
          fontSize: 13,
          fontFamily: 'Fira Code',
        ),
      ),
    );
  }
}
