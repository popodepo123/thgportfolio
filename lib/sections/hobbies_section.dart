import 'package:flutter/material.dart';
import 'package:thgportfolio/portfolio_data.dart';
import 'package:thgportfolio/theme.dart';

class HobbiesSection extends StatelessWidget {
  const HobbiesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hobbies & Interests', style: textTheme.headlineMedium),
        const SizedBox(height: 24),
        ...portfolio.hobbies.map((category) => _HobbyCategoryWidget(category: category)),
      ],
    );
  }
}

class _HobbyCategoryWidget extends StatelessWidget {
  final HobbyCategory category;
  const _HobbyCategoryWidget({required this.category});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category.title,
            style: const TextStyle(
              color: gruberNiagara,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: category.items.map((item) => _HobbyListItem(item: item)).toList(),
          ),
        ],
      ),
    );
  }
}

class _HobbyListItem extends StatelessWidget {
  final HobbyItem item;
  const _HobbyListItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: gruberBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: gruberBgLighter),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.imageUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                item.imageUrl!,
                height: 48,
                width: 48,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 48,
                  width: 48,
                  color: gruberBgDarker,
                  alignment: Alignment.center,
                  child: const Icon(Icons.videogame_asset, size: 24, color: gruberQuartz),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ] else ...[
             Container(
               height: 48,
               width: 48,
               decoration: BoxDecoration(
                 color: gruberBgDarker,
                 borderRadius: BorderRadius.circular(6),
               ),
               alignment: Alignment.center,
               child: const Icon(Icons.star, size: 24, color: gruberQuartz),
             ),
             const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    color: gruberYellow,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Fira Code',
                  ),
                ),
                if (item.description != null && item.description!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    item.description!,
                    style: const TextStyle(
                      color: gruberFg,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}
