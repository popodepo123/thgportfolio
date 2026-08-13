import "package:flutter/material.dart";
import "package:url_launcher/url_launcher.dart";

import "package:thgportfolio/portfolio_data.dart";
import "package:thgportfolio/skill_preview_images.dart";
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
              WebsitePreview(
                uri: websiteUri,
                title: skill.name,
                description: skill.description,
                imageUrl: skillPreviewImageUrls[skill.name],
              ),
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
