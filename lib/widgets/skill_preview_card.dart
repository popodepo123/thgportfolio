import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";

import "package:thgportfolio/skill_preview_content.dart";

class SkillPreviewCard extends StatelessWidget {
  final Uri? uri;
  final String title;
  final String description;
  final String? imageAssetPath;
  final List<SkillPreviewLogo> logos;

  const SkillPreviewCard({
    super.key,
    required this.uri,
    required this.title,
    required this.description,
    required this.imageAssetPath,
    required this.logos,
  });

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

  Widget _logoArtwork(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF171717),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: logos.map((logo) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: constraints.maxHeight * 0.55,
                        child: SvgPicture.asset(
                          logo.assetPath,
                          fit: BoxFit.contain,
                          semanticsLabel: "${logo.label} logo",
                          errorBuilder: (context, error, stackTrace) {
                            return _fallbackArtwork(context);
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        logo.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sourceHost = uri?.host.replaceFirst("www.", "");

    return Container(
      key: const ValueKey("skill-preview-card"),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      foregroundDecoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: imageAssetPath == null
                ? _logoArtwork(context)
                : Image.asset(
                    imageAssetPath!,
                    fit: BoxFit.cover,
                    semanticLabel: "$title artwork",
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
                Text("Summary", style: Theme.of(context).textTheme.titleMedium),
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
    );
  }
}
