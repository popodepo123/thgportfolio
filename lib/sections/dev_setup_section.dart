import 'package:flutter/material.dart';
import 'package:thgportfolio/theme.dart';

class DevSetupSection extends StatelessWidget {
  const DevSetupSection({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dev Setup', style: textTheme.headlineMedium),
        const SizedBox(height: 24),
        _buildResponsiveGrid(context, isMobile, [
          _buildSetupCategory(context, 'Hardware & OS', [
            'MacBook Air (M3) - Main Workstation',
            'macOS - Primary OS',
            'Custom Built PC - Windows 11',
          ]),
          _buildSetupCategory(context, 'Terminal & Shell', [
            'Ghostty / WezTerm - GPU accelerated terminals',
            'Zsh with Zoxide - Fast navigation',
            'Tmux / Zellij - Multiplexers',
          ]),
          _buildSetupCategory(context, 'Editors & IDEs', [
            'Helix / Neovim - Primary modal editors',
            'VS Code / Android Studio / Xcode',
          ]),
          _buildSetupCategory(context, 'Tools & AI Workflow', [
            'OpenCode & Gemini CLI - Open-source AI terminal agents',
            'Ollama & LM Studio - Local LLM execution',
            'FVM - Flutter version management',
            'Git / GitHub / GitLab - CI/CD',
          ]),
        ]),
      ],
    );
  }

  Widget _buildResponsiveGrid(
    BuildContext context,
    bool isMobile,
    List<Widget> children,
  ) {
    if (isMobile) {
      return Column(
        children: children
            .map(
              (c) =>
                  Padding(padding: const EdgeInsets.only(bottom: 16), child: c),
            )
            .toList(),
      );
    }
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: children
          .map(
            (c) => SizedBox(
              width: (MediaQuery.of(context).size.width - 64 - 16) / 2,
              child: c,
            ),
          )
          .toList(),
    );
  }

  Widget _buildSetupCategory(
    BuildContext context,
    String title,
    List<String> items,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: gruberBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: gruberBgLighter),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: gruberYellow,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: gruberYellow)),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(color: gruberFg, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
