import 'package:flutter/material.dart';
import 'package:thgportfolio/portfolio_data.dart';
import 'package:thgportfolio/loading_logo.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Text(portfolio.name, style: textTheme.displayLarge),
              ),
              const SizedBox(width: 16),
              const LoadingLogo(size: 30.0),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            portfolio.title,
            style: textTheme.headlineMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 24),
          Text(portfolio.summary, style: textTheme.bodyMedium),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
