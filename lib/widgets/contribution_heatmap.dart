import 'package:flutter/material.dart';
import 'package:thgportfolio/contribution_service.dart';
import 'package:thgportfolio/theme.dart';
import 'package:thgportfolio/widgets/heatmap_loading_indicator.dart';

class ContributionHeatmap extends StatefulWidget {
  final String gitlabUser;
  final String githubUser;
  
  const ContributionHeatmap({
    super.key, 
    required this.gitlabUser,
    required this.githubUser,
  });

  @override
  State<ContributionHeatmap> createState() => _ContributionHeatmapState();
}

class _ContributionHeatmapState extends State<ContributionHeatmap> {
  Map<String, int>? _unifiedContributions;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final results = await Future.wait([
      ContributionService.fetchGitLab(widget.gitlabUser),
      ContributionService.fetchGitHub(widget.githubUser),
    ]);

    final gitlabData = results[0];
    final githubData = results[1];

    final Map<String, int> merged = Map.from(gitlabData);
    githubData.forEach((date, count) {
      merged[date] = (merged[date] ?? 0) + count;
    });

    if (mounted) {
      setState(() {
        _unifiedContributions = merged;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contributions',
          style: TextStyle(color: gruberQuartz, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 800),
          child: _buildGridContent(),
        ),
        const SizedBox(height: 8),
        const ContributionLegend(),
      ],
    );
  }

  Widget _buildGridContent() {
    if (_isLoading) {
      return const HeatmapLoadingIndicator(key: ValueKey('loading'), showTitleAndLegend: false);
    }

    if (_unifiedContributions == null || _unifiedContributions!.isEmpty) {
      return const SizedBox(
        key: ValueKey('empty'),
        height: 100,
        child: Center(child: Text('No public contributions found.', style: TextStyle(color: gruberQuartz, fontSize: 12))),
      );
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return LayoutBuilder(
      key: const ValueKey('data'),
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth;
        const int weeksToShow = 52;
        const double spacing = 1.0;
        
        // Dynamic calculation: (Width - (Total Spacing)) / Columns
        final double squareSize = (availableWidth - (weeksToShow * spacing * 2)) / weeksToShow;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(weeksToShow, (weekIndex) {
            return Column(
              children: List.generate(7, (dayIndex) {
                final dayOffset = (weeksToShow - 1 - weekIndex) * 7 + (6 - dayIndex);
                final date = today.subtract(Duration(days: dayOffset));
                final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                final count = _unifiedContributions![dateStr] ?? 0;
                
                return Container(
                  width: squareSize,
                  height: squareSize,
                  margin: const EdgeInsets.all(spacing),
                  decoration: BoxDecoration(
                    color: _getColorForCount(count),
                    borderRadius: BorderRadius.circular(1),
                  ),
                );
              }),
            );
          }),
        );
      },
    );
  }

  Color _getColorForCount(int count) {
    if (count == 0) return gruberBgLighter.withValues(alpha: 0.3);
    if (count < 3) return gruberYellow.withValues(alpha: 0.3);
    if (count < 6) return gruberYellow.withValues(alpha: 0.6);
    if (count < 10) return gruberYellow.withValues(alpha: 0.8);
    return gruberYellow;
  }
}

class ContributionLegend extends StatelessWidget {
  const ContributionLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Text('Less ', style: TextStyle(color: gruberQuartz, fontSize: 10)),
        _LegendBox(color: gruberBgLighter.withValues(alpha: 0.3)),
        _LegendBox(color: gruberYellow.withValues(alpha: 0.3)),
        _LegendBox(color: gruberYellow.withValues(alpha: 0.6)),
        _LegendBox(color: gruberYellow.withValues(alpha: 0.8)),
        const _LegendBox(color: gruberYellow),
        const Text(' More', style: TextStyle(color: gruberQuartz, fontSize: 10)),
      ],
    );
  }
}

class _LegendBox extends StatelessWidget {
  final Color color;
  const _LegendBox({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}
