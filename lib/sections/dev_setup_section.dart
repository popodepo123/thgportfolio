import 'package:flutter/material.dart';
import 'package:thgportfolio/theme.dart';

class DevSetupSection extends StatelessWidget {
  const DevSetupSection({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dev Setup', style: textTheme.headlineMedium),
        const SizedBox(height: 24),
        _buildSetupCategory(
          context,
          'Hardware & OS',
          [
            'MacBook Air (M3) - Main Workstation',
            'macOS Sequoia - Primary OS',
            'Custom Built PC - Windows 11 (For Gaming & Heavily Threaded Tasks)',
          ],
        ),
        const SizedBox(height: 16),
        _buildSetupCategory(
          context,
          'Terminal & Shell',
          [
            'Ghostty / Alacritty - High-performance GPU accelerated terminals',
            'Zsh with custom Zoxide integration for fast navigation',
            'Tmux / Zellij - Terminal multiplexers for session management',
          ],
        ),
        const SizedBox(height: 16),
        _buildSetupCategory(
          context,
          'Editors & IDEs',
          [
            'Helix / Neovim - Primary modal editors for speed and efficiency',
            'OpenCode - Open-source VS Code distribution',
            'VS Code - For complex web debugging and Dart/Flutter heavy projects',
            'Android Studio / Xcode - Native mobile development and builds',
          ],
        ),
        const SizedBox(height: 16),
        _buildSetupCategory(
          context,
          'Tools & Workflow',
          [
            'Gemini CLI - AI-powered terminal workflows and automation',
            'Ollama & LM Studio - Local LLM execution and experimentation',
            'Git / GitHub / GitLab - Version control and CI/CD automation',
            'FVM (Flutter Version Management) - Managing project-specific Flutter SDKs',
            'Custom Dart CLI Tooling - Automation for boilerplate and architecture enforcement',
          ],
        ),
      ],
    );
  }

  Widget _buildSetupCategory(BuildContext context, String title, List<String> items) {
    return Container(
      width: double.infinity,
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
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(color: gruberNiagara)),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(color: gruberFg, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
