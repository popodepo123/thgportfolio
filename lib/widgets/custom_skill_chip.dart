import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:thgportfolio/portfolio_data.dart';

import 'package:thgportfolio/widgets/skill_widgets.dart';

class CustomSkillChip extends StatefulWidget {
  final SkillDetail skillDetail;
  final dynamic icon;
  final TextTheme textTheme;
  const CustomSkillChip({
    super.key,
    required this.skillDetail,
    required this.icon,
    required this.textTheme,
  });

  @override
  State<CustomSkillChip> createState() => _CustomSkillChipState();
}

class _CustomSkillChipState extends State<CustomSkillChip> {
  bool _isHovering = false;

  Widget _buildIcon(dynamic iconData, Color color) {
    if (iconData == null) return const SizedBox.shrink();
    if (iconData is IconData && iconData.runtimeType.toString() != 'FaIconData') {
      return Icon(
        iconData,
        size: 16,
        color: color,
        semanticLabel: widget.skillDetail.name,
      );
    } else {
      return FaIcon(
        iconData,
        size: 16,
        color: color,
        semanticLabel: widget.skillDetail.name,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return SkillDetailDialog(skill: widget.skillDetail);
          },
        );
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onHover: (event) {
          setState(() {
            _isHovering = true;
          });
        },
        onExit: (event) {
          setState(() {
            _isHovering = false;
          });
        },
        child: AnimatedScale(
          scale: _isHovering ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _isHovering
                  ? Theme.of(context).colorScheme.tertiary
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null)
                  _buildIcon(
                    widget.icon,
                    _isHovering
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                if (widget.icon != null) const SizedBox(width: 8),
                SelectionContainer.disabled(
                  child: Text(
                    widget.skillDetail.name,
                    style: TextStyle(
                      color: _isHovering
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
