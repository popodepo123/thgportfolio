import 'package:flutter/material.dart';
import 'package:thgportfolio/portfolio_data.dart';
import 'package:url_launcher/url_launcher.dart';

class SkillDetailDialog extends StatelessWidget {
  final SkillDetail skill;

  const SkillDetailDialog({super.key, required this.skill});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(skill.name),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 400.0),
        child: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Description: ${skill.description}'),
              if (skill.websiteUrl != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () async {
                        if (await canLaunchUrl(Uri.parse(skill.websiteUrl!))) {
                          await launchUrl(Uri.parse(skill.websiteUrl!));
                        } else {
                          // Handle error: could not launch URL
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Could not launch ${skill.websiteUrl}',
                              ),
                            ),
                          );
                        }
                      },
                      child: Text(
                        'Visit Website',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ),
              // Add more details as needed
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Close'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
