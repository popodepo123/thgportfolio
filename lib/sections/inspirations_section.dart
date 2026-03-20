import 'package:flutter/material.dart';
import 'package:thgportfolio/portfolio_data.dart';
import 'package:thgportfolio/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class InspirationsSection extends StatelessWidget {
  const InspirationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Inspirations', style: textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          'Creators and developers who shape my perspective on engineering and craft.',
          style: textTheme.bodyMedium?.copyWith(color: gruberQuartz),
        ),
        const SizedBox(height: 24),
        ...portfolio.inspirations.map((inspiration) => _InspirationCard(inspiration: inspiration)),
      ],
    );
  }
}

class _InspirationCard extends StatelessWidget {
  final Inspiration inspiration;
  const _InspirationCard({required this.inspiration});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: gruberBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: gruberBgLighter, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  inspiration.name,
                  style: const TextStyle(
                    color: gruberYellow,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (inspiration.twitchHandle != null)
                    _LinkButton(
                      label: inspiration.twitchHandle!,
                      icon: Icons.live_tv,
                      onTap: () => launchUrl(Uri.parse('https://twitch.tv/${inspiration.twitchHandle}')),
                    ),
                  if (inspiration.youtubeHandle != null)
                    _LinkButton(
                      label: inspiration.youtubeHandle!,
                      icon: Icons.play_circle_outline,
                      onTap: () => launchUrl(Uri.parse('https://youtube.com/${inspiration.youtubeHandle}')),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            inspiration.description,
            style: const TextStyle(
              color: gruberFg,
              height: 1.4,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _LinkButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: gruberBgLighter,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: gruberNiagara),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: gruberNiagara,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
