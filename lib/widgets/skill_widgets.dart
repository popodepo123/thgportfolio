import "package:flutter/material.dart";
import "package:url_launcher/url_launcher.dart";

import "package:thgportfolio/portfolio_data.dart";
import "package:thgportfolio/widgets/website_preview.dart";

class SkillDetailDialog extends StatelessWidget {
  final SkillDetail skill;

  const SkillDetailDialog({super.key, required this.skill});

  Future<void> _openWebsite(BuildContext context, Uri uri) async {
    try {
      final didLaunch = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (didLaunch || !context.mounted) return;
    } catch (_) {
      if (!context.mounted) return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Could not launch $uri")));
  }

  @override
  Widget build(BuildContext context) {
    final websiteUrl = skill.websiteUrl?.trim();
    final websiteUri = websiteUrl == null || websiteUrl.isEmpty
        ? null
        : Uri.tryParse(websiteUrl);

    return AlertDialog(
      title: Text(skill.name),
      content: SizedBox(
        width: 720,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(skill.description),
              if (websiteUri != null) ...[
                const SizedBox(height: 20),
                Text(
                  "Website preview",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: WebsitePreview(uri: websiteUri, title: skill.name),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Some websites block embedded previews. Use Open Website if the preview is unavailable.",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
      actions: <Widget>[
        if (websiteUri != null)
          FilledButton(
            onPressed: () => _openWebsite(context, websiteUri),
            child: const Text("Open Website"),
          ),
        TextButton(
          child: const Text("Close"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
