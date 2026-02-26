import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thgportfolio/portfolio_data.dart';

const double _terminalFontSize = 14.0;
const String _terminalFontFamily = 'Iosevka';

class DevView extends StatefulWidget {
  const DevView({super.key});

  @override
  State<DevView> createState() => _DevViewState();
}

class _DevViewState extends State<DevView> {
  String _currentFile = 'README.md';
  bool _isPickerOpen = true;
  final FocusNode _focusNode = FocusNode();

  final List<String> _files = [
    'README.md',
    'SKILLS.sh',
    'PROJECTS.json',
    'EXPERIENCE.log',
    'CONTACT.cfg',
  ];

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _moveSelection(int direction) {
    final currentIndex = _files.indexOf(_currentFile);
    int nextIndex = currentIndex + direction;
    if (nextIndex < 0) nextIndex = _files.length - 1;
    if (nextIndex >= _files.length) nextIndex = 0;
    setState(() {
      _currentFile = _files[nextIndex];
    });
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyJ): () => _moveSelection(1),
        const SingleActivator(LogicalKeyboardKey.keyK): () => _moveSelection(-1),
        const SingleActivator(LogicalKeyboardKey.space): () {
          setState(() {
            _isPickerOpen = !_isPickerOpen;
          });
        },
      },
      child: Focus(
        focusNode: _focusNode,
        autofocus: true,
        child: Container(
          color: const Color(0xFF1B1B23),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    if (_isPickerOpen)
                      _HelixPicker(
                        files: _files,
                        selectedFile: _currentFile,
                        onFileSelected: (f) => setState(() => _currentFile = f),
                      ),
                    Expanded(
                      child: _HelixBuffer(
                        fileName: _currentFile,
                        lines: _getBufferLines(_currentFile),
                      ),
                    ),
                  ],
                ),
              ),
              _HelixStatusArea(currentFile: _currentFile),
            ],
          ),
        ),
      ),
    );
  }

  List<LineData> _getBufferLines(String buffer) {
    return switch (buffer) {
      'README.md' => _MarkdownContent.getLines(),
      'SKILLS.sh' => _ShellContent.getLines(),
      'PROJECTS.json' => _JsonContent.getLines(),
      'EXPERIENCE.log' => _LogContent.getLines(),
      'CONTACT.cfg' => _ConfigContent.getLines(),
      _ => [LineData(span: const TextSpan(text: 'Error: Buffer not found'))],
    };
  }
}

class LineData {
  final TextSpan span;
  LineData({required this.span});
}

class _HelixPicker extends StatelessWidget {
  final List<String> files;
  final String selectedFile;
  final Function(String) onFileSelected;

  const _HelixPicker({required this.files, required this.selectedFile, required this.onFileSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: Color(0xFF24242E),
        border: Border(right: BorderSide(color: Color(0xFF3B3B4D), width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: const Color(0xFF3B3B4D),
            child: const Row(
              children: [
                Icon(Icons.search, size: 16, color: Colors.white70),
                SizedBox(width: 8),
                Text('file-picker', style: TextStyle(color: Colors.white, fontFamily: _terminalFontFamily, fontSize: 13)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];
                final isSelected = selectedFile == file;
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => onFileSelected(file),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: isSelected ? const Color(0xFF3E3E52) : Colors.transparent,
                      child: Text(file, style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontFamily: _terminalFontFamily, fontSize: 14)),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HelixBuffer extends StatelessWidget {
  final String fileName;
  final List<LineData> lines;

  const _HelixBuffer({required this.fileName, required this.lines});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text(fileName, style: const TextStyle(color: Colors.white24, fontFamily: _terminalFontFamily, fontSize: 12)),
        ),
        Expanded(
          child: SelectionArea(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: lines.length,
              itemBuilder: (context, i) {
                final line = lines[i];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectionContainer.disabled(
                      child: SizedBox(
                        width: 40,
                        child: Text(
                          (i + 1).toString().padLeft(3),
                          style: const TextStyle(color: Colors.white10, fontFamily: _terminalFontFamily, fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text.rich(
                        line.span,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.clip,
                        style: const TextStyle(fontFamily: _terminalFontFamily, fontSize: _terminalFontSize),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _HelixStatusArea extends StatelessWidget {
  final String currentFile;
  const _HelixStatusArea({required this.currentFile});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 24,
          color: const Color(0xFF2D2D3A),
          child: Row(
            children: [
              const _StatusBlock(text: ' NOR ', bgColor: Color(0xFF7B5EA7), textColor: Colors.white),
              _StatusBlock(text: ' ~/projects/thgportfolio/$currentFile ', bgColor: const Color(0xFF3B3B4D), textColor: Colors.white),
              const Spacer(),
              const _StatusBlock(text: ' 1 sel ', bgColor: Color(0xFF3B3B4D), textColor: Colors.white70),
              const _StatusBlock(text: ' 1:1 ', bgColor: Color(0xFF3B3B4D), textColor: Colors.white),
              const _StatusBlock(text: ' UTF-8 ', bgColor: Color(0xFF3B3B4D), textColor: Colors.white70),
              const _StatusBlock(text: ' DART ', bgColor: Color(0xFF7B5EA7), textColor: Colors.white),
            ],
          ),
        ),
        Container(
          height: 24,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          color: const Color(0xFF1B1B23),
          child: const Row(
            children: [
              Text(':', style: TextStyle(color: Colors.white, fontFamily: _terminalFontFamily, fontWeight: FontWeight.bold)),
              SizedBox(width: 8),
              _BlinkingCursor(),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusBlock extends StatelessWidget {
  final String text;
  final Color bgColor;
  final Color textColor;
  const _StatusBlock({required this.text, required this.bgColor, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgColor,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.center,
      child: Text(text, style: TextStyle(color: textColor, fontFamily: _terminalFontFamily, fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor();
  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..repeat(reverse: true);
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _controller, child: Container(width: 8, height: 16, color: Colors.white70));
  }
}

// --- Content Data Providers ---

class _MarkdownContent {
  static List<LineData> getLines() {
    final List<LineData> lines = [];
    lines.add(LineData(span: const TextSpan(text: '# README.md', style: TextStyle(color: Color(0xFF6362CE), fontWeight: FontWeight.bold))));
    lines.add(LineData(span: const TextSpan(text: '')));
    lines.add(LineData(span: TextSpan(text: '## ${portfolio.name}', style: const TextStyle(color: Colors.cyanAccent))));
    lines.add(LineData(span: TextSpan(text: '> ${portfolio.title}', style: const TextStyle(color: Colors.orangeAccent))));
    lines.add(LineData(span: const TextSpan(text: '')));
    
    final summaryWords = portfolio.summary.split(' ');
    String current = '';
    for (var word in summaryWords) {
      if ((current + word).length > 60) {
        lines.add(LineData(span: TextSpan(text: current.trim(), style: const TextStyle(color: Colors.white54, fontStyle: FontStyle.italic))));
        current = word + ' ';
      } else { current += word + ' '; }
    }
    if (current.isNotEmpty) lines.add(LineData(span: TextSpan(text: current.trim(), style: const TextStyle(color: Colors.white54, fontStyle: FontStyle.italic))));
    return lines;
  }
}

class _ShellContent {
  static List<LineData> getLines() {
    final List<LineData> lines = [LineData(span: const TextSpan(text: '#!/bin/bash', style: TextStyle(color: Colors.white24))), LineData(span: const TextSpan(text: ''))];
    for (var cat in portfolio.skills) {
      lines.add(LineData(span: TextSpan(text: 'echo "Loading ${cat.categoryName}..."', style: const TextStyle(color: Colors.greenAccent))));
      for (var s in cat.skills) lines.add(LineData(span: TextSpan(text: '  add_skill "${s.name}"', style: const TextStyle(color: Colors.white54))));
      lines.add(LineData(span: const TextSpan(text: '')));
    }
    return lines;
  }
}

class _JsonContent {
  static List<LineData> getLines() {
    final List<LineData> lines = [];
    lines.add(LineData(span: const TextSpan(text: '{', style: TextStyle(color: Colors.yellowAccent))));
    lines.add(LineData(span: const TextSpan(text: '  "projects": [', style: TextStyle(color: Colors.white))));

    for (var i = 0; i < portfolio.projects.length; i++) {
      final p = portfolio.projects[i];
      lines.add(LineData(span: const TextSpan(text: '    {', style: TextStyle(color: Colors.white38))));
      
      _addRichField(lines, 'title', p.title, color: Colors.greenAccent);
      _addRichField(lines, 'description', p.description, color: Colors.white70);
      if (p.githubLink != null) _addRichField(lines, 'github', p.githubLink!, color: Colors.cyanAccent);
      if (p.gitlabLink != null) _addRichField(lines, 'gitlab', p.gitlabLink!, color: Colors.cyanAccent);
      
      lines.add(LineData(span: const TextSpan(children: [
        TextSpan(text: '      "features"', style: TextStyle(color: Colors.white)),
        TextSpan(text: '    : [', style: TextStyle(color: Colors.white70)),
      ])));
      
      for (var f in p.features) {
        lines.add(LineData(span: TextSpan(text: '        "$f"${f == p.features.last ? "" : ","}', style: const TextStyle(color: Colors.orangeAccent))));
      }
      lines.add(LineData(span: const TextSpan(text: '      ]', style: TextStyle(color: Colors.white70))));
      lines.add(LineData(span: TextSpan(text: '    }${i == portfolio.projects.length - 1 ? "" : ","}', style: const TextStyle(color: Colors.white38))));
    }
    lines.add(LineData(span: const TextSpan(text: '  ]', style: TextStyle(color: Colors.white))));
    lines.add(LineData(span: const TextSpan(text: '}', style: TextStyle(color: Colors.yellowAccent))));
    return lines;
  }

  static void _addRichField(List<LineData> lines, String key, String value, {required Color color}) {
    const int keyWidth = 12;
    final String keyPart = '"$key"'.padRight(keyWidth);
    final String prefix = '      ';
    
    final words = value.split(' ');
    String current = '';
    bool first = true;

    for (var word in words) {
      if ((current + word).length > 60) {
        if (first) {
          lines.add(LineData(span: TextSpan(children: [
            TextSpan(text: '$prefix$keyPart', style: const TextStyle(color: Colors.white)),
            const TextSpan(text: ' : "', style: TextStyle(color: Colors.white70)),
            TextSpan(text: current.trim(), style: TextStyle(color: color)),
          ])));
          first = false;
        } else {
          lines.add(LineData(span: TextSpan(children: [
            TextSpan(text: ' ' * (prefix.length + keyWidth + 4)),
            TextSpan(text: current.trim(), style: TextStyle(color: color)),
          ])));
        }
        current = word + ' ';
      } else { current += word + ' '; }
    }
    
    if (first) {
      lines.add(LineData(span: TextSpan(children: [
        TextSpan(text: '$prefix$keyPart', style: const TextStyle(color: Colors.white)),
        const TextSpan(text: ' : "', style: TextStyle(color: Colors.white70)),
        TextSpan(text: current.trim(), style: TextStyle(color: color)),
        const TextSpan(text: '",', style: TextStyle(color: Colors.white70)),
      ])));
    } else {
      lines.add(LineData(span: TextSpan(children: [
        TextSpan(text: ' ' * (prefix.length + keyWidth + 4)),
        TextSpan(text: current.trim(), style: TextStyle(color: color)),
        const TextSpan(text: '",', style: TextStyle(color: Colors.white70)),
      ])));
    }
  }
}

class _LogContent {
  static List<LineData> getLines() {
    final List<LineData> lines = [];
    for (var e in portfolio.experiences) {
      lines.add(LineData(span: TextSpan(text: '[${e.period}] INFO: Joined ${e.company}', style: const TextStyle(color: Colors.white38))));
      lines.add(LineData(span: TextSpan(text: '  Role: ${e.role}', style: const TextStyle(color: Colors.white))));
      lines.add(LineData(span: TextSpan(text: '  Task: ${e.description.substring(0, 50)}...', style: const TextStyle(color: Colors.white54))));
      lines.add(LineData(span: const TextSpan(text: '')));
    }
    return lines;
  }
}

class _ConfigContent {
  static List<LineData> getLines() {
    return [
      LineData(span: const TextSpan(text: '[contact]', style: TextStyle(color: Colors.purpleAccent))),
      LineData(span: TextSpan(text: 'email = "${portfolio.email}"', style: const TextStyle(color: Colors.white70))),
      if (portfolio.githubUrl != null) LineData(span: TextSpan(text: 'github = "${portfolio.githubUrl}"', style: const TextStyle(color: Colors.white70))),
      if (portfolio.gitlabUrl != null) LineData(span: TextSpan(text: 'gitlab = "${portfolio.gitlabUrl}"', style: const TextStyle(color: Colors.white70))),
      LineData(span: const TextSpan(text: '')),
      LineData(span: const TextSpan(text: '[status]', style: TextStyle(color: Colors.purpleAccent))),
      LineData(span: const TextSpan(text: 'available = true', style: TextStyle(color: Colors.greenAccent))),
    ];
  }
}
