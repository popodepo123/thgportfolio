import "package:flutter/material.dart";

class WebsitePreview extends StatelessWidget {
  final Uri? uri;
  final String title;
  final String description;
  final String? imageUrl;

  const WebsitePreview({
    super.key,
    required this.uri,
    required this.title,
    required this.description,
    this.imageUrl,
  });

  String? get _resolvedImageUrl {
    if (imageUrl != null) return imageUrl;
    return uri?.resolve("/favicon.ico").toString();
  }

  Widget _fallbackArtwork(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Text(
          title.characters.first.toUpperCase(),
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resolvedImageUrl = _resolvedImageUrl;
    final sourceHost = uri?.host.replaceFirst("www.", "");

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: resolvedImageUrl == null
                  ? _fallbackArtwork(context)
                  : Image.network(
                      resolvedImageUrl,
                      fit: imageUrl == null ? BoxFit.contain : BoxFit.cover,
                      semanticLabel: "$title website artwork",
                      webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return ColoredBox(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return _fallbackArtwork(context);
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Summary",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(description),
                  if (sourceHost != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      "Source: $sourceHost",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
