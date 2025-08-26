import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:thgportfolio/portfolio_data.dart';

import 'package:thgportfolio/widgets/skill_widgets.dart';

class CustomSkillChip extends StatefulWidget {
  final SkillDetail skillDetail;
  final IconData? icon;
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
                  FaIcon(
                    widget.icon!,
                    size: 16,
                    color: _isHovering
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurface,
                    semanticLabel: widget.skillDetail.name,
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
