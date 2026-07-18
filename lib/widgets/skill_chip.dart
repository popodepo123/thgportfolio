import 'package:flutter/material.dart';
import 'package:thgportfolio/portfolio_data.dart';
import 'package:thgportfolio/widgets/skill_widgets.dart';

class SkillChip extends StatefulWidget {
  final SkillDetail skillDetail;
  final IconData icon;
  final TextTheme textTheme;
  const SkillChip({
    super.key,
    required this.skillDetail,
    required this.icon,
    required this.textTheme,
  });

  @override
  State<SkillChip> createState() => _SkillChipState();
}

class _SkillChipState extends State<SkillChip> {
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
        onEnter: (event) {
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
            decoration: BoxDecoration(
              color: _isHovering
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Chip(
              avatar: Icon(
                widget.icon,
                size: 16,
                color: _isHovering
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface,
                semanticLabel: widget.skillDetail.name,
              ),
              label: SelectionContainer.disabled(
                child: DefaultTextStyle(
                  style: TextStyle(
                    color: _isHovering
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                  child: Text(widget.skillDetail.name),
                ),
              ),
              backgroundColor: Colors
                  .transparent, // Set to transparent as AnimatedContainer handles color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
