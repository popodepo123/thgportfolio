import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:thgportfolio/contribution_service.dart';
import 'package:thgportfolio/portfolio_data.dart';
import 'package:thgportfolio/theme.dart';
import 'package:thgportfolio/view_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

const double _terminalFontSize = 14.0;
const String _terminalFontFamily = 'Iosevka';

class DevView extends ConsumerStatefulWidget {
  const DevView({super.key});

  @override
  ConsumerState<DevView> createState() => _DevViewState();
}

class _DevViewState extends ConsumerState<DevView> {
  String _currentFile = 'README.md';
  final List<String> _openBuffers = ['README.md'];
  int _activeBufferIndex = 0;

  bool _isPickerOpen = true;
  bool _isLoading = false;
  bool _isImage = false;
  bool _isPreviewMode = false;
  bool _isCRTEnabled = true;
  
  // Typewriter Mode
  String? _typingContent;
  int _visibleChars = 0;
  Timer? _typingTimer;

  String? _remoteContent;
  String? _imageUrl;
  
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  // Command & Search Mode
  bool _isCommandMode = false;
  bool _isSearchMode = false;
  String _searchQuery = '';
  final TextEditingController _commandController = TextEditingController();
  final FocusNode _commandFocusNode = FocusNode();

  final Map<String, List<Map<String, dynamic>>> _childrenCache = {};
  final Set<String> _expandedPaths = {};

  final List<String> _localFiles = ['README.md', 'SKILLS.sh', 'PROJECTS.json', 'EXPERIENCE.log', 'CONTACT.cfg'];

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
    _startTypewriter(_getMarkdownString('README.md'));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _scrollController.dispose();
    _commandController.dispose();
    _commandFocusNode.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  void _startTypewriter(String content) {
    _typingTimer?.cancel();
    setState(() {
      _typingContent = content;
      _visibleChars = 0;
    });
    
    _typingTimer = Timer.periodic(const Duration(milliseconds: 5), (timer) {
      setState(() {
        if (_visibleChars < _typingContent!.length) {
          _visibleChars += 15;
          if (_visibleChars > _typingContent!.length) _visibleChars = _typingContent!.length;
        } else {
          timer.cancel();
        }
      });
    });
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
    
    _typingTimer?.cancel();
    setState(() {
      if (!_openBuffers.contains(file)) {
        _openBuffers.add(file);
      }
      _activeBufferIndex = _openBuffers.indexOf(file);
      _currentFile = file;
      _remoteContent = null;
      _imageUrl = null;
      _isImage = isImg;
      _typingContent = null;
      _searchQuery = ''; // Reset search on file change
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

          if (scrollToLine != null && _scrollController.hasClients) {
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) {
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
    } else if (_localFiles.contains(file)) {
      _startTypewriter(_getLocalRawContent(file));
    }
  }

  String _getLocalRawContent(String file) {
     return switch (file) {
      'README.md' => portfolio.summary,
      'SKILLS.sh' => portfolio.skills.map((c) => '# ${c.categoryName}\n${c.skills.map((s) => "add_skill \"${s.name}\"").join("\n")}').join('\n\n'),
      'PROJECTS.json' => portfolio.projects.map((p) => '{\n  "title": "${p.title}",\n  "desc": "${p.description}"\n}').join(',\n'),
      'EXPERIENCE.log' => portfolio.experiences.map((e) => '[${e.period}] ${e.role} at ${e.company}').join('\n'),
      'CONTACT.cfg' => 'email = "${portfolio.email}"\navailable = true',
      _ => '',
    };
  }

  void _closeBuffer(int index) {
    setState(() {
      final String closedFile = _openBuffers.removeAt(index);
      if (_openBuffers.isEmpty) {
        _openBuffers.add('README.md');
      }
      if (_activeBufferIndex >= _openBuffers.length) {
        _activeBufferIndex = _openBuffers.length - 1;
      }
      _currentFile = _openBuffers[_activeBufferIndex];
      if (_currentFile != closedFile) {
        _handleFileSelection(_currentFile);
      }
    });
  }

  void _executeCommand(String input) {
    if (_isSearchMode) {
      setState(() {
        _searchQuery = input;
        _isSearchMode = false;
        _commandController.clear();
        _focusNode.requestFocus();
      });
      return;
    }

    final trimmed = input.trim();
    final int? lineNumber = int.tryParse(trimmed);

    if (lineNumber != null) {
       // Go to line command
       if (_scrollController.hasClients) {
          // Zero-indexed, approx 20px per line
          final double targetPos = ((lineNumber - 1) * 20.0).clamp(0, _scrollController.position.maxScrollExtent);
          _scrollController.animateTo(
            targetPos,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
       }
    } else if (trimmed == 'q') {
      ref.read(viewModeProvider.notifier).setProView();
    } else if (trimmed.startsWith('open ')) {
      final file = trimmed.substring(5).trim();
      if (_localFiles.contains(file)) {
        _handleFileSelection(file);
      }
    } else if (trimmed == 'tree') {
      setState(() => _isPickerOpen = !_isPickerOpen);
    } else if (trimmed == 'crt') {
      setState(() => _isCRTEnabled = !_isCRTEnabled);
    }
    
    setState(() {
      _isCommandMode = false;
      _commandController.clear();
      _focusNode.requestFocus();
    });
  }

  _BufferStats _getStats() {
    String content = '';
    if (_remoteContent != null) {
      content = _remoteContent!;
    } else if (_typingContent != null) {
      content = _typingContent!;
    } else {
      content = _getMarkdownString(_currentFile);
    }
    
    if (content.isEmpty && _remoteContent == null) {
       content = _getBufferLines(_currentFile).map((l) => l.span.toPlainText()).join('\n');
    }

    final lines = content.split('\n').length;
    final words = content.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    final size = content.length;
    return _BufferStats(lines: lines, words: words, size: size);
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.space): () => setState(() => _isPickerOpen = !_isPickerOpen),
        const SingleActivator(LogicalKeyboardKey.semicolon, shift: true): () {
          setState(() {
            _isCommandMode = true;
            _isSearchMode = false;
            _commandController.clear();
          });
          _commandFocusNode.requestFocus();
        },
        const SingleActivator(LogicalKeyboardKey.slash): () {
          setState(() {
            _isSearchMode = true;
            _isCommandMode = false;
            _commandController.text = _searchQuery;
            // Move cursor to end
            _commandController.selection = TextSelection.fromPosition(TextPosition(offset: _commandController.text.length));
          });
          _commandFocusNode.requestFocus();
        },
      },
      child: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (node, event) {
          if ((_isCommandMode || _isSearchMode) && event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
            setState(() {
              _isCommandMode = false;
              _isSearchMode = false;
              if (_searchQuery.isEmpty) {
                 _commandController.clear();
              }
              _focusNode.requestFocus();
            });
            return KeyEventResult.handled;
          }
          
          // Vim-style navigation when in normal mode
          if (!_isCommandMode && !_isSearchMode && event is KeyDownEvent && _scrollController.hasClients) {
            const double scrollAmount = 40.0; // Approx two lines
            
            if (event.logicalKey == LogicalKeyboardKey.keyJ || event.logicalKey == LogicalKeyboardKey.arrowDown) {
              final newPos = (_scrollController.offset + scrollAmount).clamp(0.0, _scrollController.position.maxScrollExtent);
              _scrollController.jumpTo(newPos);
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.keyK || event.logicalKey == LogicalKeyboardKey.arrowUp) {
              final newPos = (_scrollController.offset - scrollAmount).clamp(0.0, _scrollController.position.maxScrollExtent);
              _scrollController.jumpTo(newPos);
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.keyG) {
               if (HardwareKeyboard.instance.isShiftPressed) {
                 // G (Bottom)
                 _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
               } else {
                 // g (Top)
                 _scrollController.jumpTo(0.0);
               }
               return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: Stack(
          children: [
            Container(
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
                              child: Column(
                                children: [
                                  _HelixTabBar(
                                    openBuffers: _openBuffers,
                                    activeIndex: _activeBufferIndex,
                                    onTabSelected: (idx) => _handleFileSelection(_openBuffers[idx]),
                                    onTabClosed: _closeBuffer,
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
                          ],
                        ),
                      ),
                      _HelixStatusArea(
                        currentFile: _currentFile,
                        localFiles: _localFiles,
                        isCommandMode: _isCommandMode,
                        isSearchMode: _isSearchMode,
                        commandController: _commandController,
                        commandFocusNode: _commandFocusNode,
                        onCommandSubmit: _executeCommand,
                        onSearchChanged: (val) {
                          if (_isSearchMode) {
                            setState(() => _searchQuery = val);
                          }
                        },
                        stats: _getStats(),
                      ),
                    ],
                  );
                },
              ),
            ),
            if (_isCRTEnabled) const IgnorePointer(child: _CRTOverlay()),
          ],
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
    
    String? contentToRender = _remoteContent;
    if (_typingContent != null) {
      contentToRender = _typingContent!.substring(0, _visibleChars);
    }

    if (contentToRender != null) {
      final ext = buffer.split('.').last.toLowerCase();
      return switch (ext) {
        'dart' => _DartHighlighter.highlight(contentToRender, searchQuery: _searchQuery, onSymbolClick: (symbol) async {
            debugPrint('JTD: Tapped symbol $symbol in $buffer');
            final gitlabUrl = _findGitlabUrlForPath(buffer);
            if (gitlabUrl != null) {
              setState(() => _isLoading = true);
              final remoteBufferPath = _extractRemotePath(buffer);
              final match = await ContributionService.searchSymbol(gitlabUrl, symbol, currentFilePath: remoteBufferPath);
              if (match != null) {
                final project = portfolio.projects.firstWhere((p) => p.gitlabLink == gitlabUrl);
                final slug = _getSlug(project);
                _handleFileSelection('$slug/${match.path}', gitlabUrl: gitlabUrl, remotePath: match.path, scrollToLine: match.lineIndex);
              } else {
                setState(() => _isLoading = false);
              }
            }
          }),
        'rs' => _RustHighlighter.highlight(contentToRender, searchQuery: _searchQuery),
        'js' || 'ts' => _JavascriptHighlighter.highlight(contentToRender, searchQuery: _searchQuery),
        'html' || 'htm' => _HtmlHighlighter.highlight(contentToRender, searchQuery: _searchQuery),
        'css' => _CssHighlighter.highlight(contentToRender, searchQuery: _searchQuery),
        'sh' || 'bash' => _BashHighlighter.highlight(contentToRender, searchQuery: _searchQuery),
        'yaml' || 'yml' => _YamlHighlighter.highlight(contentToRender, searchQuery: _searchQuery),
        'toml' => _TomlHighlighter.highlight(contentToRender, searchQuery: _searchQuery),
        'bat' || 'cmd' => _BatchHighlighter.highlight(contentToRender, searchQuery: _searchQuery),
        _ => _GenericHighlighter.highlightPlain(contentToRender, _getRemoteStyle(buffer), searchQuery: _searchQuery),
      };
    }
    
    // For local non-remote content (simulated via hardcoded methods) we'll use a basic search wrapper
    final baseLines = switch (buffer) {
      'README.md' => _MarkdownContent.getLines(),
      'SKILLS.sh' => _ShellContent.getLines(),
      'PROJECTS.json' => _JsonContent.getLines(),
      'EXPERIENCE.log' => _LogContent.getLines(),
      'CONTACT.cfg' => _ConfigContent.getLines(),
      _ => [LineData(span: const TextSpan(text: 'Error: Buffer not found'))],
    };
    
    if (_searchQuery.isNotEmpty) {
      return baseLines.map((l) => LineData(span: _applySearchHighlight(l.span, _searchQuery))).toList();
    }
    return baseLines;
  }
  
  // A helper to inject search highlights into already generated TextSpans (used for the hardcoded local files)
  TextSpan _applySearchHighlight(TextSpan span, String query) {
     if (span.text != null && span.text!.isNotEmpty) {
       return _GenericHighlighter.highlightSearchInText(span.text!, span.style, query);
     }
     if (span.children != null) {
        return TextSpan(
          style: span.style,
          children: span.children!.map((c) {
             if (c is TextSpan) return _applySearchHighlight(c, query);
             return c;
          }).toList(),
        );
     }
     return span;
  }

  Color _getRemoteStyle(String fileName) {
    if (fileName.endsWith('.dart')) return gruberGreen;
    if (fileName.endsWith('.rs')) return gruberOrange;
    if (fileName.endsWith('.js') || fileName.endsWith('.ts')) return gruberYellow;
    if (fileName.endsWith('.html')) return gruberOrange;
    if (fileName.endsWith('.css')) return gruberNiagara;
    if (fileName.endsWith('.sh') || fileName.endsWith('.bash')) return gruberGreen;
    if (fileName.endsWith('.yaml') || fileName.endsWith('.json') || fileName.endsWith('.toml')) return gruberNiagara;
    return gruberFg.withValues(alpha: 0.8);
  }
}

class LineData {
  final TextSpan span;
  LineData({required this.span});
}

class _BufferStats {
  final int lines;
  final int words;
  final int size;
  _BufferStats({required this.lines, required this.words, required this.size});
}

class _HelixTabBar extends StatelessWidget {
  final List<String> openBuffers;
  final int activeIndex;
  final Function(int) onTabSelected;
  final Function(int) onTabClosed;

  const _HelixTabBar({
    required this.openBuffers,
    required this.activeIndex,
    required this.onTabSelected,
    required this.onTabClosed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      color: gruberBgDarker,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: openBuffers.length,
        itemBuilder: (context, i) {
          final isSelected = i == activeIndex;
          final fileName = openBuffers[i].split('/').last;
          
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => onTabSelected(i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isSelected ? gruberBg : gruberBgDarker,
                  border: Border(
                    top: BorderSide(color: isSelected ? gruberYellow : Colors.transparent, width: 2),
                    right: const BorderSide(color: gruberBgLighter, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      fileName,
                      style: TextStyle(
                        color: isSelected ? gruberFg : gruberQuartz,
                        fontFamily: _terminalFontFamily,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => onTabClosed(i),
                      child: Icon(Icons.close, size: 12, color: isSelected ? gruberRed : gruberQuartz),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HelixPicker extends StatelessWidget {
  final List<String> localFiles;
  final String selectedFile;
  final Set<String> expandedPaths;
  final Map<String, List<Map<String, dynamic>>> childrenCache;
  final Function(String, {String? gitlabUrl, String? remotePath, int? scrollToLine}) onFileSelected;
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
            child: RawScrollbar(
              controller: scrollController,
              thumbColor: gruberBgLighter,
              radius: Radius.zero,
              thickness: 10,
              thumbVisibility: true,
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
        ),
      ],
    );
  }
}

class _HelixStatusArea extends StatelessWidget {
  final String currentFile;
  final List<String> localFiles;
  final bool isCommandMode;
  final bool isSearchMode;
  final TextEditingController commandController;
  final FocusNode commandFocusNode;
  final Function(String) onCommandSubmit;
  final Function(String) onSearchChanged;
  final _BufferStats stats;
  
  const _HelixStatusArea({
    required this.currentFile,
    required this.localFiles,
    required this.isCommandMode,
    required this.isSearchMode,
    required this.commandController,
    required this.commandFocusNode,
    required this.onCommandSubmit,
    required this.onSearchChanged,
    required this.stats,
  });
  
  @override
  Widget build(BuildContext context) {
    final bool isLocal = localFiles.contains(currentFile);
    final String displayPath = isLocal ? '~/system/$currentFile' : '~/projects/$currentFile';
    final String lang = _getLangLabel(currentFile);
    final String sizeStr = stats.size > 1024 ? '${(stats.size / 1024).toStringAsFixed(1)}kb' : '${stats.size}b';

    return Column(
      children: [
        Container(
          height: 24, color: gruberBgLighter,
          child: Row(children: [
            const _StatusBlock(text: ' NOR ', bgColor: gruberYellow, textColor: Colors.black),
            _StatusBlock(text: ' $displayPath ', bgColor: gruberBg, textColor: gruberFg),
            const Spacer(),
            _StatusBlock(text: ' ${stats.words} words ', bgColor: gruberBg, textColor: gruberQuartz),
            _StatusBlock(text: ' $sizeStr ', bgColor: gruberBg, textColor: gruberNiagara),
            _StatusBlock(text: ' ${stats.lines} lines ', bgColor: gruberBg, textColor: gruberFg),
            _StatusBlock(text: ' $lang ', bgColor: gruberYellow, textColor: Colors.black),
          ]),
        ),
        Container(
          height: 24,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          color: gruberBgDarker,
          child: Row(
            children: [
              Text(
                isSearchMode ? '/' : ':',
                style: TextStyle(color: isSearchMode ? gruberNiagara : gruberFg, fontFamily: _terminalFontFamily, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              if (isCommandMode || isSearchMode)
                Expanded(
                  child: TextField(
                    controller: commandController,
                    focusNode: commandFocusNode,
                    style: const TextStyle(color: gruberFg, fontFamily: _terminalFontFamily, fontSize: 13),
                    cursorColor: isSearchMode ? gruberNiagara : gruberYellow,
                    decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                    onSubmitted: onCommandSubmit,
                    onChanged: isSearchMode ? onSearchChanged : null,
                  ),
                )
              else
                const _BlinkingCursor(),
            ],
          ),
        ),
      ],
    );
  }

  String _getLangLabel(String file) {
    final ext = file.split('.').last.toLowerCase();
    return switch (ext) {
      'dart' => 'DART',
      'rs' => 'RUST',
      'js' || 'ts' => 'JS',
      'html' || 'htm' => 'HTML',
      'css' => 'CSS',
      'sh' || 'bash' => 'SH',
      'yaml' || 'yml' => 'YAML',
      'toml' => 'TOML',
      'bat' || 'cmd' => 'BAT',
      'md' => 'MD',
      'json' => 'JSON',
      _ => 'TXT',
    };
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

class _CRTOverlay extends StatefulWidget {
  const _CRTOverlay();
  @override
  State<_CRTOverlay> createState() => _CRTOverlayState();
}

class _CRTOverlayState extends State<_CRTOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100))..repeat(reverse: true);
  }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.02 + (_controller.value * 0.01)),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
              tileMode: TileMode.repeated,
              transform: const GradientRotation(0),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.005 * _controller.value),
            ),
          ),
        );
      },
    );
  }
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

class _GenericHighlighter {
  static List<LineData> highlight(String code, Set<String> keywords, {Color keywordColor = gruberYellow, String commentPrefix = '//', String searchQuery = ''}) {
    final List<LineData> lines = [];
    final rawLines = code.split('\n');
    for (var line in rawLines) {
      final List<TextSpan> spans = [];
      int commentIndex = line.indexOf(commentPrefix);
      String textToHighlight = commentIndex != -1 ? line.substring(0, commentIndex) : line;
      String commentPart = commentIndex != -1 ? line.substring(commentIndex) : '';
      
      final tokens = _tokenize(textToHighlight);
      for (var token in tokens) {
        final text = token.text;
        final trimmed = text.trim();
        Color color = gruberFg;
        FontWeight weight = FontWeight.normal;
        if (trimmed.startsWith("'") || trimmed.startsWith('"')) {
          color = gruberGreen;
        } else if (keywords.contains(trimmed)) {
          color = keywordColor;
          weight = FontWeight.bold;
        } else if (RegExp(r'^\d+$').hasMatch(trimmed)) {
          color = gruberBrown;
        } else if (RegExp(r'^[A-Z]\w*$').hasMatch(trimmed)) {
          color = gruberNiagara;
        }
        spans.add(highlightSearchInText(text, TextStyle(color: color, fontWeight: weight), searchQuery));
      }
      if (commentPart.isNotEmpty) {
        spans.add(highlightSearchInText(commentPart, const TextStyle(color: gruberQuartz, fontStyle: FontStyle.italic), searchQuery));
      }
      lines.add(LineData(span: TextSpan(children: spans)));
    }
    return lines;
  }
  
  static List<LineData> highlightPlain(String code, Color defaultColor, {String searchQuery = ''}) {
     return code.split('\n').map((l) => LineData(span: highlightSearchInText(l, TextStyle(color: defaultColor), searchQuery))).toList();
  }

  static TextSpan highlightSearchInText(String text, TextStyle baseStyle, String query) {
    if (query.isEmpty) return TextSpan(text: text, style: baseStyle);
    
    final matches = query.toLowerCase().allMatches(text.toLowerCase()).toList();
    if (matches.isEmpty) return TextSpan(text: text, style: baseStyle);

    List<TextSpan> spans = [];
    int lastMatchEnd = 0;

    for (var match in matches) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start), style: baseStyle));
      }
      spans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: baseStyle.copyWith(backgroundColor: gruberYellow, color: Colors.black, fontWeight: FontWeight.bold),
      ));
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd), style: baseStyle));
    }

    return TextSpan(children: spans);
  }

  static List<_Token> _tokenize(String text) {
    final List<_Token> tokens = [];
    final pattern = RegExp('("[^"]*"|\'[^\']*\'|\\b[a-zA-Z_]\\w*\\b|\\d+|[^\\s\\w]+|\\s+)');
    final matches = pattern.allMatches(text);
    for (var match in matches) { tokens.add(_Token(match.group(0)!)); }
    return tokens;
  }
}

class _DartHighlighter {
  static final keywords = {'abstract', 'as', 'assert', 'async', 'await', 'break', 'case', 'catch', 'class', 'const', 'continue', 'covariant', 'default', 'deferred', 'do', 'dynamic', 'else', 'enum', 'export', 'extends', 'extension', 'external', 'factory', 'false', 'final', 'finally', 'for', 'function', 'get', 'hide', 'if', 'implements', 'import', 'in', 'interface', 'is', 'late', 'library', 'mixin', 'new', 'null', 'on', 'operator', 'part', 'rethrow', 'return', 'set', 'show', 'static', 'super', 'switch', 'sync', 'this', 'throw', 'true', 'try', 'typedef', 'var', 'void', 'while', 'with', 'yield'};
  static List<LineData> highlight(String code, {Function(String)? onSymbolClick, String searchQuery = ''}) {
    final List<LineData> lines = [];
    for (var line in code.split('\n')) {
      final List<TextSpan> spans = [];
      int commentIndex = line.indexOf('//');
      String text = commentIndex != -1 ? line.substring(0, commentIndex) : line;
      String comment = commentIndex != -1 ? line.substring(commentIndex) : '';
      for (var token in _GenericHighlighter._tokenize(text)) {
        final t = token.text;
        final isType = RegExp(r'^[A-Z]\w*$').hasMatch(t.trim());
        
        final baseStyle = _getStyle(t, isType, onSymbolClick != null);
        
        spans.add(TextSpan(
          children: [_GenericHighlighter.highlightSearchInText(t, baseStyle, searchQuery)],
          recognizer: (isType && onSymbolClick != null) ? (TapGestureRecognizer()..onTap = () => onSymbolClick(t.trim())) : null,
        ));
      }
      if (comment.isNotEmpty) {
          spans.add(_GenericHighlighter.highlightSearchInText(comment, const TextStyle(color: gruberQuartz, fontStyle: FontStyle.italic), searchQuery));
      }
      lines.add(LineData(span: TextSpan(children: spans)));
    }
    return lines;
  }
  static TextStyle _getStyle(String t, bool isType, bool clickable) {
    final trimmed = t.trim();
    if (keywords.contains(trimmed)) return const TextStyle(color: gruberYellow, fontWeight: FontWeight.bold);
    if (isType) return TextStyle(color: gruberNiagara, decoration: clickable ? TextDecoration.underline : null, decorationColor: gruberNiagara.withValues(alpha: 0.5));
    if (trimmed.startsWith("'") || trimmed.startsWith('"')) return const TextStyle(color: gruberGreen);
    if (RegExp(r'^\d+$').hasMatch(trimmed)) return const TextStyle(color: gruberBrown);
    return const TextStyle(color: gruberFg);
  }
}

class _RustHighlighter {
  static final keywords = {'as', 'async', 'await', 'break', 'const', 'continue', 'crate', 'dyn', 'else', 'enum', 'extern', 'false', 'fn', 'for', 'if', 'impl', 'import', 'in', 'let', 'loop', 'match', 'mod', 'move', 'mut', 'pub', 'ref', 'return', 'self', 'Self', 'static', 'struct', 'super', 'trait', 'true', 'type', 'union', 'unsafe', 'use', 'where', 'while'};
  static List<LineData> highlight(String code, {String searchQuery = ''}) => _GenericHighlighter.highlight(code, keywords, keywordColor: gruberOrange, searchQuery: searchQuery);
}

class _JavascriptHighlighter {
  static final keywords = {'break', 'case', 'catch', 'class', 'const', 'continue', 'debugger', 'default', 'delete', 'do', 'else', 'export', 'extends', 'finally', 'for', 'function', 'if', 'import', 'in', 'instanceof', 'new', 'return', 'super', 'switch', 'this', 'throw', 'try', 'typeof', 'var', 'void', 'while', 'with', 'yield', 'let', 'static', 'async', 'await', 'of'};
  static List<LineData> highlight(String code, {String searchQuery = ''}) => _GenericHighlighter.highlight(code, keywords, keywordColor: gruberYellow, searchQuery: searchQuery);
}

class _BashHighlighter {
  static final keywords = {'if', 'then', 'else', 'elif', 'fi', 'case', 'esac', 'for', 'while', 'until', 'do', 'done', 'in', 'function', 'return', 'local', 'export', 'alias', 'echo', 'exit', 'break', 'continue'};
  static List<LineData> highlight(String code, {String searchQuery = ''}) => _GenericHighlighter.highlight(code, keywords, keywordColor: gruberGreen, commentPrefix: '#', searchQuery: searchQuery);
}

class _YamlHighlighter {
  static List<LineData> highlight(String code, {String searchQuery = ''}) {
    final List<LineData> lines = [];
    for (var line in code.split('\n')) {
      final List<TextSpan> spans = [];
      if (line.trim().startsWith('#')) {
        spans.add(_GenericHighlighter.highlightSearchInText(line, const TextStyle(color: gruberQuartz, fontStyle: FontStyle.italic), searchQuery));
      } else if (line.contains(':')) {
        final parts = line.split(':');
        spans.add(_GenericHighlighter.highlightSearchInText(parts[0], const TextStyle(color: gruberYellow, fontWeight: FontWeight.bold), searchQuery));
        spans.add(_GenericHighlighter.highlightSearchInText(':', const TextStyle(color: gruberQuartz), searchQuery));
        spans.add(_GenericHighlighter.highlightSearchInText(parts.sublist(1).join(':'), const TextStyle(color: gruberFg), searchQuery));
      } else {
        spans.add(_GenericHighlighter.highlightSearchInText(line, const TextStyle(color: gruberFg), searchQuery));
      }
      lines.add(LineData(span: TextSpan(children: spans)));
    }
    return lines;
  }
}

class _TomlHighlighter {
  static List<LineData> highlight(String code, {String searchQuery = ''}) {
    final List<LineData> lines = [];
    for (var line in code.split('\n')) {
      final List<TextSpan> spans = [];
      final trimmed = line.trim();
      if (trimmed.startsWith('#')) {
        spans.add(_GenericHighlighter.highlightSearchInText(line, const TextStyle(color: gruberQuartz, fontStyle: FontStyle.italic), searchQuery));
      } else if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
        spans.add(_GenericHighlighter.highlightSearchInText(line, const TextStyle(color: gruberWisteria, fontWeight: FontWeight.bold), searchQuery));
      } else if (line.contains('=')) {
        final parts = line.split('=');
        spans.add(_GenericHighlighter.highlightSearchInText(parts[0], const TextStyle(color: gruberYellow), searchQuery));
        spans.add(_GenericHighlighter.highlightSearchInText(' = ', const TextStyle(color: gruberQuartz), searchQuery));
        spans.add(_GenericHighlighter.highlightSearchInText(parts.sublist(1).join('='), const TextStyle(color: gruberGreen), searchQuery));
      } else {
        spans.add(_GenericHighlighter.highlightSearchInText(line, const TextStyle(color: gruberFg), searchQuery));
      }
      lines.add(LineData(span: TextSpan(children: spans)));
    }
    return lines;
  }
}

class _HtmlHighlighter {
  static List<LineData> highlight(String code, {String searchQuery = ''}) {
    final List<LineData> lines = [];
    for (var line in code.split('\n')) {
      final List<TextSpan> spans = [];
      final pattern = RegExp(r'(<[^>]+>)|([^<]+)');
      final matches = pattern.allMatches(line);
      for (var m in matches) {
        final text = m.group(0)!;
        if (text.startsWith('<')) {
          spans.add(_GenericHighlighter.highlightSearchInText(text, const TextStyle(color: gruberOrange, fontWeight: FontWeight.bold), searchQuery));
        } else {
          spans.add(_GenericHighlighter.highlightSearchInText(text, const TextStyle(color: gruberFg), searchQuery));
        }
      }
      lines.add(LineData(span: TextSpan(children: spans)));
    }
    return lines;
  }
}

class _CssHighlighter {
  static List<LineData> highlight(String code, {String searchQuery = ''}) {
    final List<LineData> lines = [];
    for (var line in code.split('\n')) {
      final List<TextSpan> spans = [];
      if (line.contains('{')) {
        final parts = line.split('{');
        spans.add(_GenericHighlighter.highlightSearchInText(parts[0], const TextStyle(color: gruberYellow, fontWeight: FontWeight.bold), searchQuery));
        spans.add(_GenericHighlighter.highlightSearchInText(' {', const TextStyle(color: gruberQuartz), searchQuery));
      } else if (line.contains(':')) {
        final parts = line.split(':');
        spans.add(_GenericHighlighter.highlightSearchInText(parts[0], const TextStyle(color: gruberNiagara), searchQuery));
        spans.add(_GenericHighlighter.highlightSearchInText(': ', const TextStyle(color: gruberQuartz), searchQuery));
        spans.add(_GenericHighlighter.highlightSearchInText(parts.sublist(1).join(':'), const TextStyle(color: gruberGreen), searchQuery));
      } else {
        spans.add(_GenericHighlighter.highlightSearchInText(line, const TextStyle(color: gruberFg), searchQuery));
      }
      lines.add(LineData(span: TextSpan(children: spans)));
    }
    return lines;
  }
}

class _BatchHighlighter {
  static final keywords = {'echo', 'set', 'if', 'else', 'goto', 'pause', 'exit', 'call', 'rem', 'for', 'in', 'do'};
  static List<LineData> highlight(String code, {String searchQuery = ''}) => _GenericHighlighter.highlight(code, keywords, keywordColor: gruberYellow, commentPrefix: 'rem', searchQuery: searchQuery);
}

class _Token {
  final String text;
  _Token(this.text);
}
