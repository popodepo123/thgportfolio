import 'package:flutter/material.dart';
import 'package:thgportfolio/portfolio_data.dart';
import 'package:url_launcher/url_launcher.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  Future<void> _launchUrl(String link) async {
    await launchUrl(Uri.parse(link));
  }

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
          TextButton.icon(
            onPressed: () => _launchUrl("mailto:${portfolio.email}"),
            icon: const Icon(Icons.email_outlined),
            label: Text(portfolio.email, style: textTheme.bodyMedium),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (portfolio.githubUrl != null)
                TextButton.icon(
                  icon: const Icon(Icons.code),
                  label: const Text("GitHub"),
                  onPressed: () => _launchUrl(portfolio.githubUrl!),
                ),
              if (portfolio.gitlabUrl != null)
                TextButton.icon(
                  icon: const Icon(Icons.source_outlined),
                  label: const Text("GitLab"),
                  onPressed: () => _launchUrl(portfolio.gitlabUrl!),
                ),
            ],
          ),
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
          Text(
            '© ${DateTime.now().year} Tristan Harvey Godoy',
            style: textTheme.bodySmall?.copyWith(color: Colors.white54),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
