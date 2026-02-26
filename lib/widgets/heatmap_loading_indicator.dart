import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:thgportfolio/theme.dart';

class HeatmapLoadingIndicator extends StatefulWidget {
  final bool showTitleAndLegend;
  const HeatmapLoadingIndicator({super.key, this.showTitleAndLegend = true});

  @override
  State<HeatmapLoadingIndicator> createState() => _HeatmapLoadingIndicatorState();
}

class _HeatmapLoadingIndicatorState extends State<HeatmapLoadingIndicator> {
  final Random _random = Random();
  final Set<int> _litIndices = {};
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) {
        setState(() {
          for (int i = 0; i < 3; i++) {
            _litIndices.add(_random.nextInt(52 * 7));
          }
          if (_litIndices.length > 40) {
            _litIndices.remove(_litIndices.first);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth;
        const int weeksToShow = 52;
        const double spacing = 1.0;
        
        // Exact calculation to fill width
        final double squareSize = (availableWidth - (weeksToShow * spacing * 2)) / weeksToShow;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.showTitleAndLegend) ...[
              const Text(
                'Contributions',
                style: TextStyle(color: gruberQuartz, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(weeksToShow, (weekIndex) {
                return Column(
                  children: List.generate(7, (dayIndex) {
                    final globalIndex = weekIndex * 7 + dayIndex;
                    final isLit = _litIndices.contains(globalIndex);
                    
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: squareSize,
                      height: squareSize,
                      margin: const EdgeInsets.all(spacing),
                      decoration: BoxDecoration(
                        color: isLit 
                            ? gruberYellow.withValues(alpha: 0.4) 
                            : gruberBgLighter.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    );
                  }),
                );
              }),
            ),
          ],
        );
      },
    );
  }
}
