import "package:flutter/material.dart";

class WebsitePreview extends StatelessWidget {
  final Uri uri;
  final String title;

  const WebsitePreview({super.key, required this.uri, required this.title});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            "Website preview is available in the web portfolio.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }
}
