import 'package:flutter/material.dart';
import 'package:thgportfolio/portfolio_data.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Divider(),
          Text(
            'Get in Touch',
            style: textTheme.headlineMedium?.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 8),
          Text(portfolio.email, style: textTheme.bodyMedium),
          const SizedBox(height: 24),
          Text(
            'Awards & Certificates',
            style: textTheme.titleLarge?.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 8),
          ...portfolio.awards.map(
            (award) => Text(
              '${award.name} - ${award.issuer}',
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
