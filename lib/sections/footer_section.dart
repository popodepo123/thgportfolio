import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:thgportfolio/portfolio_data.dart';
import 'package:url_launcher/url_launcher.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  Future<void> _launchUrl(String link) async {
    if (await canLaunchUrl(Uri.parse(link))) {
      await launchUrl(Uri.parse(link));
    }
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
          Text(portfolio.email, style: textTheme.bodyMedium),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (portfolio.githubUrl != null)
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.github),
                  onPressed: () => _launchUrl(portfolio.githubUrl!),
                  tooltip: 'GitHub',
                ),
              if (portfolio.gitlabUrl != null)
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.gitlab),
                  onPressed: () => _launchUrl(portfolio.gitlabUrl!),
                  tooltip: 'GitLab',
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
        ],
      ),
    );
  }
}
