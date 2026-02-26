import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:thgportfolio/contribution_service.dart';
import 'package:thgportfolio/portfolio_data.dart';
import 'package:thgportfolio/theme.dart';

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
  bool _isLoading = false;
  bool _isImage = false;
  bool _isPreviewMode = false;
  String? _remoteContent;
  String? _imageUrl;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  final Map<String, List<Map<String, dynamic>>> _childrenCache = {};
  final Set<String> _expandedPaths = {};

  final List<String> _localFiles = ['README.md', 'SKILLS.sh', 'PROJECTS.json', 'EXPERIENCE.log', 'CONTACT.cfg'];

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _getSlug(Project p) => p.title.toLowerCase().replaceAll(' ', '_').replaceAll('(', '').replaceAll(')', '');

  Future<void> _togglePath(String path, {Project? project, String? remoteRelativePath}) async {
    if (_expandedPaths.contains(path)) {
      setState(() => _expandedPaths.remove(path));
    } else {
      setState(() {
        _expandedPaths.add(path);
      });

      if (!_childrenCache.containsKey(path)) {
        setState(() => _isLoading = true);
        final gitlabUrl = project?.gitlabLink ?? _findGitlabUrlForPath(path);
        if (gitlabUrl != null) {
          final tree = await ContributionService.fetchTree(gitlabUrl, path: remoteRelativePath ?? _extractRemotePath(path));
          setState(() {
            _childrenCache[path] = tree;
            _isLoading = false;
          });
        }
      }
    }
  }

  String? _findGitlabUrlForPath(String path) {
    for (var p in portfolio.projects) {
      if (path.startsWith(_getSlug(p))) return p.gitlabLink;
    }
    return null;
  }

  String _extractRemotePath(String path) {
    final parts = path.split('/');
    if (parts.length <= 1) return '';
    return parts.sublist(1).join('/');
  }

  Future<void> _handleFileSelection(String file, {String? gitlabUrl, String? remotePath, int? scrollToLine}) async {
    final isImg = file.endsWith('.png') || file.endsWith('.jpg') || file.endsWith('.jpeg') || file.endsWith('.webp') || file.endsWith('.gif');
    
    setState(() {
      _currentFile = file;
      _remoteContent = null;
      _imageUrl = null;
      _isImage = isImg;
    });

    if (gitlabUrl != null && remotePath != null) {
      setState(() => _isLoading = true);
      
      if (isImg) {
        final rawUrl = '$gitlabUrl/-/raw/main/$remotePath';
        setState(() {
          _imageUrl = ContributionService.wrapUrl(rawUrl);
          _isLoading = false;
        });
      } else {
        final content = await ContributionService.fetchRawFile(gitlabUrl, filePath: remotePath);
        if (mounted && _currentFile == file) {
          setState(() {
            _remoteContent = content;
            _isLoading = false;
          });

          // Auto-scroll if line specified
          if (scrollToLine != null && _scrollController.hasClients) {
            // Wait for list to render
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) {
                // Approximate line height is 20px
                final double position = (scrollToLine * 20.0).clamp(0, _scrollController.position.maxScrollExtent);
                _scrollController.animateTo(
                  position,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                );
              }
            });
          } else if (_scrollController.hasClients) {
            _scrollController.jumpTo(0);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.space): () => setState(() => _isPickerOpen = !_isPickerOpen),
      },
      child: Focus(
        focusNode: _focusNode,
        autofocus: true,
        child: Container(
          color: gruberBg,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool shouldShowPicker = _isPickerOpen && constraints.maxWidth >= 800;
              
              return Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        if (shouldShowPicker)
                          _HelixPicker(
                            localFiles: _localFiles,
                            selectedFile: _currentFile,
                            expandedPaths: _expandedPaths,
                            childrenCache: _childrenCache,
                            onFileSelected: _handleFileSelection,
                            onPathToggle: _togglePath,
                          ),
                        Expanded(
                          child: Stack(
                            children: [
                              _isImage && _imageUrl != null
                                  ? _buildImageBuffer()
                                  : (_isPreviewMode && _currentFile.endsWith('.md'))
                                      ? _buildMarkdownPreview()
                                      : _HelixBuffer(
                                          fileName: _currentFile,
                                          isLoading: _isLoading,
                                          lines: _getBufferLines(_currentFile),
                                          scrollController: _scrollController,
                                        ),
                              if (_currentFile.endsWith('.md'))
                                Positioned(
                                  top: 16,
                                  right: 16,
                                  child: _buildPreviewToggle(),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _HelixStatusArea(currentFile: _currentFile, localFiles: _localFiles),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildImageBuffer() {
    return Container(
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_currentFile, style: const TextStyle(color: gruberQuartz, fontFamily: _terminalFontFamily, fontSize: 12)),
          const SizedBox(height: 16),
          Expanded(
            child: Image.network(
              _imageUrl!,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator(color: gruberYellow));
              },
              errorBuilder: (context, error, stackTrace) => Text('Error loading image: $error', style: const TextStyle(color: gruberRed)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarkdownPreview() {
    final String content = _remoteContent ?? _getMarkdownString(_currentFile);
    return Container(
      color: gruberBg,
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      child: Markdown(
        data: content,
        styleSheet: MarkdownStyleSheet(
          p: const TextStyle(color: gruberFg, fontFamily: _terminalFontFamily),
          h1: const TextStyle(color: gruberYellow, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: _terminalFontFamily),
          h2: const TextStyle(color: gruberYellow, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: _terminalFontFamily),
          h3: const TextStyle(color: gruberYellow, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: _terminalFontFamily),
          code: const TextStyle(backgroundColor: gruberBgDarker, color: gruberGreen, fontFamily: _terminalFontFamily),
          blockquote: const TextStyle(color: gruberQuartz, fontStyle: FontStyle.italic, fontFamily: _terminalFontFamily),
          blockquoteDecoration: const BoxDecoration(
            border: Border(left: BorderSide(color: gruberBgLighter, width: 4)),
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewToggle() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => _isPreviewMode = !_isPreviewMode),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: gruberBgLighter,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: gruberYellow.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isPreviewMode ? Icons.code : Icons.remove_red_eye_outlined,
                size: 14,
                color: gruberYellow,
              ),
              const SizedBox(width: 6),
              Text(
                _isPreviewMode ? 'RAW' : 'PREVIEW',
                style: const TextStyle(color: gruberYellow, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: _terminalFontFamily),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getMarkdownString(String buffer) {
    if (buffer == 'README.md') {
      return portfolio.summary;
    }
    return '';
  }

  List<LineData> _getBufferLines(String buffer) {
    if (_isLoading && _remoteContent == null) {
      return [LineData(span: const TextSpan(text: '// Communicating with Contribution API...', style: TextStyle(color: gruberQuartz)))];
    }
    if (_remoteContent != null) {
      if (buffer.endsWith('.dart')) {
        return _DartHighlighter.highlight(
          _remoteContent!,
          onSymbolClick: (symbol) async {
            debugPrint('JTD: Tapped symbol $symbol in $buffer');
            final gitlabUrl = _findGitlabUrlForPath(buffer);
            if (gitlabUrl != null) {
              setState(() => _isLoading = true);
              final remoteBufferPath = _extractRemotePath(buffer);
              final match = await ContributionService.searchSymbol(gitlabUrl, symbol, currentFilePath: remoteBufferPath);
              if (match != null) {
                debugPrint('JTD: Navigating to ${match.path} at line ${match.lineIndex}');
                final project = portfolio.projects.firstWhere((p) => p.gitlabLink == gitlabUrl);
                final slug = _getSlug(project);
                _handleFileSelection('$slug/${match.path}', gitlabUrl: gitlabUrl, remotePath: match.path, scrollToLine: match.lineIndex);
              } else {
                debugPrint('JTD: Symbol not found in repo');
                setState(() => _isLoading = false);
              }
            } else {
              debugPrint('JTD: No GitLab URL found for $buffer');
            }
          },
        );
      }
      return _remoteContent!.split('\n').map((l) => LineData(span: TextSpan(text: l, style: TextStyle(color: _getRemoteStyle(buffer))))).toList();
    }
    return switch (buffer) {
      'README.md' => _MarkdownContent.getLines(),
      'SKILLS.sh' => _ShellContent.getLines(),
      'PROJECTS.json' => _JsonContent.getLines(),
      'EXPERIENCE.log' => _LogContent.getLines(),
      'CONTACT.cfg' => _ConfigContent.getLines(),
      _ => [LineData(span: const TextSpan(text: 'Error: Buffer not found'))],
    };
  }

  Color _getRemoteStyle(String fileName) {
    if (fileName.endsWith('.dart')) return gruberGreen;
    if (fileName.endsWith('.yaml') || fileName.endsWith('.json')) return gruberNiagara;
    if (fileName.endsWith('.md')) return gruberFg;
    return gruberFg.withValues(alpha: 0.8);
  }
}

class LineData {
  final TextSpan span;
  LineData({required this.span});
}

class _HelixPicker extends StatelessWidget {
  final List<String> localFiles;
  final String selectedFile;
  final Set<String> expandedPaths;
  final Map<String, List<Map<String, dynamic>>> childrenCache;
  final Function(String, {String? gitlabUrl, String? remotePath}) onFileSelected;
  final Function(String, {Project? project, String? remoteRelativePath}) onPathToggle;

  const _HelixPicker({
    required this.localFiles,
    required this.selectedFile,
    required this.expandedPaths,
    required this.childrenCache,
    required this.onFileSelected,
    required this.onPathToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: const BoxDecoration(color: gruberBgDarker, border: Border(right: BorderSide(color: gruberBgLighter, width: 1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: gruberBgLighter,
            child: const Row(children: [Icon(Icons.folder_open, size: 16, color: gruberQuartz), SizedBox(width: 8), Text('explorer', style: TextStyle(color: gruberFg, fontFamily: _terminalFontFamily, fontSize: 13))]),
          ),
          Expanded(
            child: ListView(
              children: [
                const Padding(padding: EdgeInsets.fromLTRB(16, 12, 16, 4), child: Text('SYSTEM', style: TextStyle(color: gruberQuartz, fontSize: 10, fontWeight: FontWeight.bold))),
                ...localFiles.map((f) => _buildItem(f, f == selectedFile, Icons.description_outlined, () => onFileSelected(f), 0)),
                
                const Padding(padding: EdgeInsets.fromLTRB(16, 20, 16, 4), child: Text('PUBLIC PROJECTS', style: TextStyle(color: gruberQuartz, fontSize: 10, fontWeight: FontWeight.bold))),
                ...portfolio.projects.where((p) => p.gitlabLink != null).map((p) {
                  final slug = p.title.toLowerCase().replaceAll(' ', '_').replaceAll('(', '').replaceAll(')', '');
                  return _buildLazyTree(p, slug, '', 0);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLazyTree(Project p, String fullPath, String remoteRelativePath, int depth) {
    final isExpanded = expandedPaths.contains(fullPath);
    final children = childrenCache[fullPath] ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildItem(
          depth == 0 ? p.title : fullPath.split('/').last,
          false,
          isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
          () => onPathToggle(fullPath, project: depth == 0 ? p : null, remoteRelativePath: remoteRelativePath),
          depth,
          color: depth == 0 ? gruberYellow : gruberNiagara,
        ),
        if (isExpanded)
          ...children.map((node) {
            final name = node['name'] as String;
            final type = node['type'] as String;
            final nodePath = node['path'] as String;
            final nodeFullPath = '${fullPath.split('/').first}/$nodePath';
            
            if (type == 'tree') {
              return _buildLazyTree(p, nodeFullPath, nodePath, depth + 1);
            } else {
              final isSelected = selectedFile == nodeFullPath;
              return _buildItem(name, isSelected, Icons.code, () => onFileSelected(nodeFullPath, gitlabUrl: p.gitlabLink, remotePath: nodePath), depth + 1);
            }
          }),
      ],
    );
  }

  Widget _buildItem(String text, bool isSelected, IconData icon, VoidCallback onTap, int depth, {Color? color}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.fromLTRB(16.0 + (depth * 12), 6, 16, 6),
          color: isSelected ? gruberBgLighter : Colors.transparent,
          child: Row(
            children: [
              Icon(icon, size: 14, color: isSelected ? gruberYellow : (color ?? gruberQuartz)),
              const SizedBox(width: 8),
              Expanded(child: Text(text, style: TextStyle(color: isSelected ? gruberYellow : (color ?? gruberFg.withValues(alpha: 0.7)), fontFamily: _terminalFontFamily, fontSize: 13), overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
      ),
    );
  }
}

class _HelixBuffer extends StatelessWidget {
  final String fileName;
  final List<LineData> lines;
  final bool isLoading;
  final ScrollController? scrollController;
  
  const _HelixBuffer({
    required this.fileName,
    required this.lines,
    this.isLoading = false,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(children: [
            Text(fileName, style: const TextStyle(color: gruberQuartz, fontFamily: _terminalFontFamily, fontSize: 12)),
            if (isLoading) ...[const SizedBox(width: 8), const SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 2, color: gruberYellow))],
          ]),
        ),
        Expanded(
          child: SelectionArea(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: lines.length,
              itemBuilder: (context, i) {
                final line = lines[i];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectionContainer.disabled(
                      child: SizedBox(width: 40, child: Text('${i + 1}'.padLeft(3), style: const TextStyle(color: gruberBgLighter, fontFamily: _terminalFontFamily, fontSize: 13))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text.rich(line.span, maxLines: 1, softWrap: false, overflow: TextOverflow.clip, style: const TextStyle(fontFamily: _terminalFontFamily, fontSize: _terminalFontSize, color: gruberFg))),
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
  final List<String> localFiles;
  
  const _HelixStatusArea({required this.currentFile, required this.localFiles});
  
  @override
  Widget build(BuildContext context) {
    final bool isLocal = localFiles.contains(currentFile);
    final String displayPath = isLocal ? '~/system/$currentFile' : '~/projects/$currentFile';

    return Column(
      children: [
        Container(
          height: 24, color: gruberBgLighter,
          child: Row(children: [
            const _StatusBlock(text: ' NOR ', bgColor: gruberYellow, textColor: Colors.black),
            _StatusBlock(text: ' $displayPath ', bgColor: gruberBg, textColor: gruberFg),
            const Spacer(),
            const _StatusBlock(text: ' 1 sel ', bgColor: gruberBg, textColor: gruberQuartz),
            const _StatusBlock(text: ' 1:1 ', bgColor: gruberBg, textColor: gruberFg),
            const _StatusBlock(text: ' DART ', bgColor: gruberYellow, textColor: Colors.black),
          ]),
        ),
        Container(height: 24, padding: const EdgeInsets.symmetric(horizontal: 12), color: gruberBgDarker, child: const Row(children: [Text(':', style: TextStyle(color: gruberFg, fontFamily: _terminalFontFamily, fontWeight: FontWeight.bold)), SizedBox(width: 8), _BlinkingCursor()])),
      ],
    );
  }
}

class _StatusBlock extends StatelessWidget {
  final String text; final Color bgColor; final Color textColor;
  const _StatusBlock({required this.text, required this.bgColor, required this.textColor});
  @override
  Widget build(BuildContext context) {
    return Container(color: bgColor, padding: const EdgeInsets.symmetric(horizontal: 8), alignment: Alignment.center, child: Text(text, style: TextStyle(color: textColor, fontFamily: _terminalFontFamily, fontSize: 12, fontWeight: FontWeight.bold)));
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
  void initState() { super.initState(); _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..repeat(reverse: true); }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) { return FadeTransition(opacity: _controller, child: Container(width: 8, height: 16, color: gruberYellow)); }
}

// --- Content Data Providers ---

class _MarkdownContent {
  static List<LineData> getLines() {
    final List<LineData> lines = [];
    lines.add(LineData(span: const TextSpan(text: '# README.md', style: TextStyle(color: gruberNiagara, fontWeight: FontWeight.bold))));
    lines.add(LineData(span: const TextSpan(text: '')));
    lines.add(LineData(span: TextSpan(text: '## ${portfolio.name}', style: const TextStyle(color: gruberYellow))));
    lines.add(LineData(span: TextSpan(text: '> ${portfolio.title}', style: const TextStyle(color: gruberBrown))));
    lines.add(LineData(span: const TextSpan(text: '')));
    final words = portfolio.summary.split(' ');
    String current = '';
    for (var w in words) {
      if ((current + w).length > 60) {
        lines.add(LineData(span: TextSpan(text: current.trim(), style: const TextStyle(color: gruberQuartz, fontStyle: FontStyle.italic))));
        current = '$w ';
      } else {
        current = '$current$w ';
      }
    }
    if (current.isNotEmpty) {
      lines.add(LineData(span: TextSpan(text: current.trim(), style: const TextStyle(color: gruberQuartz, fontStyle: FontStyle.italic))));
    }
    return lines;
  }
}

class _ShellContent {
  static List<LineData> getLines() {
    final List<LineData> lines = [LineData(span: const TextSpan(text: '#!/bin/bash', style: TextStyle(color: gruberQuartz))), LineData(span: const TextSpan(text: ''))];
    for (var cat in portfolio.skills) {
      lines.add(LineData(span: TextSpan(text: 'echo "Loading ${cat.categoryName}..."', style: const TextStyle(color: gruberGreen))));
      for (var s in cat.skills) {
        lines.add(LineData(span: TextSpan(text: '  add_skill "${s.name}"', style: const TextStyle(color: gruberFg))));
      }
      lines.add(LineData(span: const TextSpan(text: '')));
    }
    return lines;
  }
}

class _JsonContent {
  static List<LineData> getLines() {
    final List<LineData> lines = [];
    lines.add(LineData(span: const TextSpan(text: '{', style: TextStyle(color: gruberYellow))));
    lines.add(LineData(span: const TextSpan(text: '  "projects": [', style: TextStyle(color: gruberFg))));
    for (var i = 0; i < portfolio.projects.length; i++) {
      final p = portfolio.projects[i];
      lines.add(LineData(span: const TextSpan(text: '    {', style: TextStyle(color: gruberQuartz))));
      _addRichField(lines, 'title', p.title, color: gruberGreen);
      _addRichField(lines, 'description', p.description, color: gruberFg);
      if (p.githubLink != null) _addRichField(lines, 'github', p.githubLink!, color: gruberNiagara);
      if (p.gitlabLink != null) _addRichField(lines, 'gitlab', p.gitlabLink!, color: gruberNiagara);
      lines.add(LineData(span: const TextSpan(children: [TextSpan(text: '      "features"', style: TextStyle(color: gruberFg)), TextSpan(text: '    : [', style: TextStyle(color: gruberQuartz))])));
      for (var f in p.features) {
        lines.add(LineData(span: TextSpan(text: '        "$f"${f == p.features.last ? "" : ","}', style: const TextStyle(color: gruberBrown))));
      }
      lines.add(LineData(span: const TextSpan(text: '      ]', style: TextStyle(color: gruberQuartz))));
      lines.add(LineData(span: TextSpan(text: '    }${i == portfolio.projects.length - 1 ? "" : ","}', style: const TextStyle(color: gruberQuartz))));
    }
    lines.add(LineData(span: const TextSpan(text: '  ]', style: TextStyle(color: gruberFg))));
    lines.add(LineData(span: const TextSpan(text: '}', style: TextStyle(color: gruberYellow))));
    return lines;
  }
  static void _addRichField(List<LineData> lines, String key, String value, {required Color color}) {
    const int keyWidth = 12;
    final String k = '"$key"'.padRight(keyWidth);
    final String p = '      ';
    final words = value.split(' ');
    String current = '';
    bool first = true;
    for (var w in words) {
      if ((current + w).length > 60) {
        if (first) {
          lines.add(LineData(span: TextSpan(children: [TextSpan(text: '$p$k', style: const TextStyle(color: gruberFg)), const TextSpan(text: ' : "', style: TextStyle(color: gruberQuartz)), TextSpan(text: current.trim(), style: TextStyle(color: color))])));
          first = false;
        } else {
          lines.add(LineData(span: TextSpan(children: [TextSpan(text: ' ' * (p.length + keyWidth + 4)), TextSpan(text: current.trim(), style: TextStyle(color: color))])));
        }
        current = '$w ';
      } else {
        current = '$current$w ';
      }
    }
    if (first) {
      lines.add(LineData(span: TextSpan(children: [TextSpan(text: '$p$k', style: const TextStyle(color: gruberFg)), const TextSpan(text: ' : "', style: TextStyle(color: gruberQuartz)), TextSpan(text: current.trim(), style: TextStyle(color: color)), const TextSpan(text: '",', style: TextStyle(color: gruberQuartz))])));
    } else {
      lines.add(LineData(span: TextSpan(children: [TextSpan(text: ' ' * (p.length + keyWidth + 4)), TextSpan(text: current.trim(), style: TextStyle(color: color)), const TextSpan(text: '",', style: TextStyle(color: gruberQuartz))])));
    }
  }
}

class _LogContent {
  static List<LineData> getLines() {
    final List<LineData> lines = [];
    for (var e in portfolio.experiences) {
      lines.add(LineData(span: TextSpan(children: [const TextSpan(text: '● ', style: TextStyle(color: gruberNiagara)), TextSpan(text: e.period, style: const TextStyle(color: gruberQuartz)), const TextSpan(text: ' - ', style: TextStyle(color: gruberQuartz)), TextSpan(text: e.role, style: const TextStyle(color: gruberGreen, fontWeight: FontWeight.bold))])));
      lines.add(LineData(span: TextSpan(children: [const TextSpan(text: '  Status: ', style: TextStyle(color: gruberQuartz)), const TextSpan(text: 'ACTIVE ', style: TextStyle(color: gruberNiagara)), const TextSpan(text: '@ ', style: TextStyle(color: gruberQuartz)), TextSpan(text: e.company, style: const TextStyle(color: gruberYellow))])));
      lines.add(LineData(span: const TextSpan(text: '  Details:', style: TextStyle(color: gruberQuartz))));
      final words = e.description.split(' ');
      String current = '    ';
      for (var w in words) {
        if ((current + w).length > 70) {
          lines.add(LineData(span: TextSpan(text: current.trimRight(), style: const TextStyle(color: gruberFg))));
          current = '    $w ';
        } else {
          current = '$current$w ';
        }
      }
      if (current.trim().isNotEmpty) {
        lines.add(LineData(span: TextSpan(text: current.trimRight(), style: const TextStyle(color: gruberFg))));
      }
      lines.add(LineData(span: const TextSpan(text: '')));
    }
    return lines;
  }
}

class _ConfigContent {
  static List<LineData> getLines() {
    return [
      LineData(span: const TextSpan(text: '[contact]', style: TextStyle(color: gruberWisteria))),
      LineData(span: TextSpan(text: 'email = "${portfolio.email}"', style: const TextStyle(color: gruberFg))),
      if (portfolio.githubUrl != null) LineData(span: TextSpan(text: 'github = "${portfolio.githubUrl}"', style: const TextStyle(color: gruberFg))),
      if (portfolio.gitlabUrl != null) LineData(span: TextSpan(text: 'gitlab = "${portfolio.gitlabUrl}"', style: const TextStyle(color: gruberFg))),
      LineData(span: const TextSpan(text: '')),
      LineData(span: const TextSpan(text: '[status]', style: TextStyle(color: gruberWisteria))),
      LineData(span: const TextSpan(text: 'available = true', style: TextStyle(color: gruberGreen))),
    ];
  }
}

class _DartHighlighter {
  static final keywords = {
    'abstract', 'as', 'assert', 'async', 'await', 'break', 'case', 'catch', 'class', 'const', 'continue',
    'covariant', 'default', 'deferred', 'do', 'dynamic', 'else', 'enum', 'export', 'extends', 'extension',
    'external', 'factory', 'false', 'final', 'finally', 'for', 'function', 'get', 'hide', 'if', 'implements',
    'import', 'in', 'interface', 'is', 'late', 'library', 'mixin', 'new', 'null', 'on', 'operator', 'part',
    'rethrow', 'return', 'set', 'show', 'static', 'super', 'switch', 'sync', 'this', 'throw', 'true', 'try',
    'typedef', 'var', 'void', 'while', 'with', 'yield'
  };

  static List<LineData> highlight(String code, {Function(String)? onSymbolClick}) {
    final List<LineData> lines = [];
    final rawLines = code.split('\n');

    for (var line in rawLines) {
      final List<TextSpan> spans = [];
      int commentIndex = line.indexOf('//');
      String textToHighlight = commentIndex != -1 ? line.substring(0, commentIndex) : line;
      String commentPart = commentIndex != -1 ? line.substring(commentIndex) : '';

      final tokens = _tokenize(textToHighlight);
      for (var token in tokens) {
        final text = token.text;
        final trimmed = text.trim();
        final isType = RegExp(r'^[A-Z]\w*$').hasMatch(trimmed);
        
        spans.add(TextSpan(
          text: text,
          style: _getStyleForToken(token, isClickable: isType && onSymbolClick != null),
          recognizer: (isType && onSymbolClick != null) 
              ? (TapGestureRecognizer()..onTap = () {
                  debugPrint('Tapped symbol: $trimmed');
                  onSymbolClick(trimmed);
                })
              : null,
        ));
      }

      if (commentPart.isNotEmpty) {
        spans.add(TextSpan(text: commentPart, style: const TextStyle(color: gruberQuartz, fontStyle: FontStyle.italic)));
      }

      lines.add(LineData(span: TextSpan(children: spans)));
    }
    return lines;
  }

  static List<_Token> _tokenize(String text) {
    final List<_Token> tokens = [];
    final pattern = RegExp('("[^"]*"|\'[^\']*\'|\\b[a-zA-Z_]\\w*\\b|\\d+|[^\\s\\w]+|\\s+)');
    final matches = pattern.allMatches(text);
    for (var match in matches) {
      tokens.add(_Token(match.group(0)!));
    }
    return tokens;
  }

  static TextStyle _getStyleForToken(_Token token, {bool isClickable = false}) {
    final t = token.text.trim();
    if (t.isEmpty) return const TextStyle();
    if (t.startsWith("'") || t.startsWith('"')) return const TextStyle(color: gruberGreen);
    if (keywords.contains(t)) return const TextStyle(color: gruberYellow, fontWeight: FontWeight.bold);
    if (RegExp(r'^[A-Z]\w*$').hasMatch(t)) {
      return TextStyle(
        color: gruberNiagara,
        decoration: isClickable ? TextDecoration.underline : null,
        decorationColor: gruberNiagara.withValues(alpha: 0.5),
      );
    }
    if (RegExp(r'^\d+$').hasMatch(t)) return const TextStyle(color: gruberBrown);
    return const TextStyle(color: gruberFg);
  }
}

class _Token {
  final String text;
  _Token(this.text);
}
