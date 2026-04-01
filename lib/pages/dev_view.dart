import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:thgportfolio/contribution_service.dart';
import 'package:thgportfolio/portfolio_data.dart';
import 'package:thgportfolio/theme.dart';
import 'package:thgportfolio/view_provider.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:convert';

const double _terminalFontSize = 14.0;
const String? _terminalFontFamily = null;
const double _lineHeight = 20.0;

class DevView extends StatefulWidget {
  const DevView({super.key});

  @override
  State<DevView> createState() => _DevViewState();
}

class _DevViewState extends State<DevView> {
  String _currentFile = 'README.md';
  final List<String> _openBuffers = ['README.md'];
  int _activeBufferIndex = 0;

  bool _isPickerOpen = true;
  bool _isLoading = false;
  bool _isImage = false;
  bool _isPreviewMode = false;
  bool _isCRTEnabled = true;

  // Logical Cursor
  int _cursorRow = 0; // 0-indexed
  int _cursorCol = 0;

  // Visual Mode
  bool _isVisualMode = false;
  int _anchorRow = -1;
  int _anchorCol = -1;

  // Typewriter Mode
  String? _typingContent;
  int _visibleChars = 0;
  Timer? _typingTimer;

  String? _remoteContent;
  String? _imageUrl;

  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  bool _relativeLineNumbers = false;
  bool _wrapText = false;
  bool _cursorLine = true;
  bool _isMatrixMode = false;
  bool _isZenMode = false;
  bool _isHexMode = false;
  bool _showBlame = false;

  // Command & Search Mode
  bool _isCommandMode = false;
  bool _isSearchMode = false;
  String _searchQuery = '';
  final TextEditingController _commandController = TextEditingController();
  final FocusNode _commandFocusNode = FocusNode();
  final List<String> _commandHistory = [];
  int _historyIndex = -1;

  final Map<String, List<Map<String, dynamic>>> _childrenCache = {};
  final Set<String> _expandedPaths = {};

  final List<String> _localFiles = [
    'README.md',
    'SKILLS.sh',
    'PROJECTS.json',
    'EXPERIENCE.log',
    'OTHER_ME.md',
    'CONTACT.cfg',
  ];

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
    _startTypewriter(_getLocalRawContent('README.md'));
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
      _cursorRow = 0;
      _cursorCol = 0;
    });

    _typingTimer = Timer.periodic(const Duration(milliseconds: 5), (timer) {
      if (mounted && _typingContent != null) {
        setState(() {
          if (_visibleChars < _typingContent!.length) {
            _visibleChars += 15;
            if (_visibleChars > _typingContent!.length)
              _visibleChars = _typingContent!.length;
          } else {
            timer.cancel();
          }
        });
      }
    });
  }

  String _getSlug(Project p) => p.title
      .toLowerCase()
      .replaceAll(' ', '_')
      .replaceAll('(', '')
      .replaceAll(')', '');

  Future<void> _togglePath(
    String path, {
    Project? project,
    String? remoteRelativePath,
  }) async {
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
          final tree = await ContributionService.fetchTree(
            gitlabUrl,
            path: remoteRelativePath ?? _extractRemotePath(path),
          );
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

  Future<void> _handleFileSelection(
    String file, {
    String? gitlabUrl,
    String? remotePath,
    int? scrollToLine,
  }) async {
    final isImg =
        file.endsWith('.png') ||
        file.endsWith('.jpg') ||
        file.endsWith('.jpeg') ||
        file.endsWith('.webp') ||
        file.endsWith('.gif');

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
      _searchQuery = '';
      _cursorRow = scrollToLine ?? 0;
      _cursorCol = 0;
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
        final content = await ContributionService.fetchRawFile(
          gitlabUrl,
          filePath: remotePath,
        );
        if (mounted && _currentFile == file) {
          setState(() {
            _remoteContent = content;
            _isLoading = false;
          });
          _syncScroll();
        }
      }
    } else if (_localFiles.contains(file)) {
      _startTypewriter(_getLocalRawContent(file));
    }
  }

  String _getLocalRawContent(String file) {
    return switch (file) {
      'README.md' => portfolio.summary,
      'SKILLS.sh' =>
        portfolio.skills
            .map(
              (c) =>
                  '# ${c.categoryName}\n${c.skills.map((s) => "add_skill \"${s.name}\"").join("\n")}',
            )
            .join('\n\n'),
      'PROJECTS.json' =>
        portfolio.projects
            .map(
              (p) =>
                  '{\n  "title": "${p.title}",\n  "desc": "${p.description}"\n}',
            )
            .join(',\n'),
      'EXPERIENCE.log' =>
        portfolio.experiences
            .map((e) => '[${e.period}] ${e.role} at ${e.company}')
            .join('\n'),
      'OTHER_ME.md' =>
        '# Other things about me\n\n## Hobbies\n${portfolio.hobbies.map((h) => "### ${h.title}\n${h.items.map((i) => "* **${i.name}**: ${i.description ?? ''}").join("\n")}").join("\n\n")}\n\n## Inspirations\n${portfolio.inspirations.map((i) => "* ${i.name}: ${i.description}").join("\n")}',
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
    if (trimmed.isNotEmpty) {
      if (_commandHistory.isEmpty || _commandHistory.last != trimmed) {
        _commandHistory.add(trimmed);
      }
      _historyIndex = _commandHistory.length;
    }

    final int? lineNumber = int.tryParse(trimmed);

    if (lineNumber != null) {
      setState(() {
        _cursorRow = (lineNumber - 1).clamp(
          0,
          _getBufferLines(_currentFile).length - 1,
        );
        _cursorCol = 0;
      });
      _syncScroll();
    } else if (trimmed == 'q') {
      portfolioViewNotifier.value = PortfolioView.professional;
    } else if (trimmed.startsWith('open ')) {
      final file = trimmed.substring(5).trim();
      if (_localFiles.contains(file)) {
        _handleFileSelection(file);
      }
    } else if (trimmed == 'tree' || trimmed == 'ls') {
      setState(() => _isPickerOpen = !_isPickerOpen);
    } else if (trimmed == 'crt') {
      setState(() => _isCRTEnabled = !_isCRTEnabled);
    } else if (trimmed == 'md' && _currentFile.endsWith('.md')) {
      setState(() => _isPreviewMode = !_isPreviewMode);
    } else if (trimmed == 'close' || trimmed == 'c') {
      _closeBuffer(_activeBufferIndex);
    } else if (trimmed == 'set rnu' || trimmed == 'set relativenumber') {
      setState(() => _relativeLineNumbers = true);
    } else if (trimmed == 'set nornu' || trimmed == 'set norelativenumber') {
      setState(() => _relativeLineNumbers = false);
    } else if (trimmed == 'set wrap') {
      setState(() => _wrapText = true);
    } else if (trimmed == 'set nowrap') {
      setState(() => _wrapText = false);
    } else if (trimmed == 'set cul' || trimmed == 'set cursorline') {
      setState(() => _cursorLine = true);
    } else if (trimmed == 'set nocul' || trimmed == 'set nocursorline') {
      setState(() => _cursorLine = false);
    } else if (trimmed == 'matrix') {
      setState(() => _isMatrixMode = !_isMatrixMode);
    } else if (trimmed == 'zen') {
      setState(() => _isZenMode = !_isZenMode);
    } else if (trimmed == 'hex') {
      setState(() => _isHexMode = !_isHexMode);
    } else if (trimmed == 'blame') {
      setState(() => _showBlame = !_showBlame);
    }

    setState(() {
      _isCommandMode = false;
      _commandController.clear();
      _focusNode.requestFocus();
    });
  }

  void _syncScroll() {
    if (_scrollController.hasClients) {
      final target = _cursorRow * _lineHeight;
      final current = _scrollController.offset;
      final viewportHeight = _scrollController.position.viewportDimension;

      if (target < current) {
        _scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      } else if (target > current + viewportHeight - (_lineHeight * 2)) {
        _scrollController.animateTo(
          target - viewportHeight + (_lineHeight * 2),
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    }
  }

  _BufferStats _getStats() {
    String content =
        _remoteContent ?? _typingContent ?? _getLocalRawContent(_currentFile);
    final lines = content.split('\n').length;
    final words = content
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .length;
    final size = content.length;
    return _BufferStats(lines: lines, words: words, size: size);
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.space): () =>
            setState(() => _isPickerOpen = !_isPickerOpen),
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
            _commandController.selection = TextSelection.fromPosition(
              TextPosition(offset: _commandController.text.length),
            );
          });
          _commandFocusNode.requestFocus();
        },
      },
      child: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.escape) {
              if (_isCommandMode || _isSearchMode) {
                setState(() {
                  _isCommandMode = false;
                  _isSearchMode = false;
                  _commandController.clear();
                  _focusNode.requestFocus();
                });
                return KeyEventResult.handled;
              } else if (_isVisualMode) {
                setState(() {
                  _isVisualMode = false;
                  _anchorRow = -1;
                });
                return KeyEventResult.handled;
              } else if (_isZenMode) {
                setState(() => _isZenMode = false);
                return KeyEventResult.handled;
              }
            }

            if (_isCommandMode &&
                event.logicalKey == LogicalKeyboardKey.arrowUp) {
              if (_commandHistory.isNotEmpty && _historyIndex > 0) {
                setState(() {
                  _historyIndex--;
                  _commandController.text = _commandHistory[_historyIndex];
                  _commandController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _commandController.text.length),
                  );
                });
              }
              return KeyEventResult.handled;
            }
            if (_isCommandMode &&
                event.logicalKey == LogicalKeyboardKey.arrowDown) {
              if (_commandHistory.isNotEmpty &&
                  _historyIndex < _commandHistory.length - 1) {
                setState(() {
                  _historyIndex++;
                  _commandController.text = _commandHistory[_historyIndex];
                  _commandController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _commandController.text.length),
                  );
                });
              } else if (_historyIndex == _commandHistory.length - 1) {
                setState(() {
                  _historyIndex = _commandHistory.length;
                  _commandController.clear();
                });
              }
              return KeyEventResult.handled;
            }

            if (!_isCommandMode && !_isSearchMode) {
              final lines = _getBufferLines(_currentFile);
              if (lines.isEmpty) return KeyEventResult.ignored;

              // Helix / Vim Navigation
              if (event.logicalKey == LogicalKeyboardKey.keyJ ||
                  event.logicalKey == LogicalKeyboardKey.arrowDown) {
                setState(() {
                  _cursorRow = math.min(_cursorRow + 1, lines.length - 1);
                  final lineLen = lines[_cursorRow].span.toPlainText().length;
                  _cursorCol = math.min(_cursorCol, math.max(0, lineLen - 1));
                });
                _syncScroll();
                return KeyEventResult.handled;
              }
              if (event.logicalKey == LogicalKeyboardKey.keyK ||
                  event.logicalKey == LogicalKeyboardKey.arrowUp) {
                setState(() {
                  _cursorRow = math.max(_cursorRow - 1, 0);
                  final lineLen = lines[_cursorRow].span.toPlainText().length;
                  _cursorCol = math.min(_cursorCol, math.max(0, lineLen - 1));
                });
                _syncScroll();
                return KeyEventResult.handled;
              }
              if (event.logicalKey == LogicalKeyboardKey.keyH ||
                  event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                if (HardwareKeyboard.instance.isShiftPressed) {
                  // Cycle tab left
                  final newIndex = (_activeBufferIndex - 1) < 0
                      ? _openBuffers.length - 1
                      : (_activeBufferIndex - 1);
                  _handleFileSelection(_openBuffers[newIndex]);
                } else {
                  setState(() => _cursorCol = math.max(_cursorCol - 1, 0));
                }
                return KeyEventResult.handled;
              }
              if (event.logicalKey == LogicalKeyboardKey.keyL ||
                  event.logicalKey == LogicalKeyboardKey.arrowRight) {
                if (HardwareKeyboard.instance.isShiftPressed) {
                  // Cycle tab right
                  final newIndex =
                      (_activeBufferIndex + 1) % _openBuffers.length;
                  _handleFileSelection(_openBuffers[newIndex]);
                } else {
                  final lineLen = lines[_cursorRow].span.toPlainText().length;
                  setState(
                    () => _cursorCol = math.min(
                      _cursorCol + 1,
                      math.max(0, lineLen - 1),
                    ),
                  );
                }
                return KeyEventResult.handled;
              }

              if (event.logicalKey == LogicalKeyboardKey.keyW) {
                setState(() {
                  final text = lines[_cursorRow].span.toPlainText();
                  // Find next word start in current line
                  int nextCol = -1;
                  final regExp = RegExp(r'\w+');
                  final matches = regExp.allMatches(text);
                  for (final m in matches) {
                    if (m.start > _cursorCol) {
                      nextCol = m.start;
                      break;
                    }
                  }

                  if (nextCol != -1) {
                    _cursorCol = nextCol;
                  } else if (_cursorRow < lines.length - 1) {
                    // Wrap to next line
                    _cursorRow++;
                    final nextText = lines[_cursorRow].span.toPlainText();
                    final firstMatch = regExp.firstMatch(nextText);
                    _cursorCol = firstMatch?.start ?? 0;
                  }
                });
                _syncScroll();
                return KeyEventResult.handled;
              }

              if (event.logicalKey == LogicalKeyboardKey.keyB) {
                setState(() {
                  final text = lines[_cursorRow].span.toPlainText();
                  // Find previous word start in current line
                  int prevCol = -1;
                  final regExp = RegExp(r'\w+');
                  final matches = regExp.allMatches(text).toList();
                  for (final m in matches.reversed) {
                    if (m.start < _cursorCol) {
                      prevCol = m.start;
                      break;
                    }
                  }

                  if (prevCol != -1) {
                    _cursorCol = prevCol;
                  } else if (_cursorRow > 0) {
                    // Wrap to previous line
                    _cursorRow--;
                    final prevText = lines[_cursorRow].span.toPlainText();
                    final lastMatch = regExp.allMatches(prevText).lastOrNull;
                    _cursorCol = lastMatch?.start ?? 0;
                  }
                });
                _syncScroll();
                return KeyEventResult.handled;
              }

              if (event.logicalKey == LogicalKeyboardKey.keyG) {
                setState(() {
                  _cursorRow = HardwareKeyboard.instance.isShiftPressed
                      ? lines.length - 1
                      : 0;
                  _cursorCol = 0;
                });
                _syncScroll();
                return KeyEventResult.handled;
              }

              if (event.logicalKey == LogicalKeyboardKey.keyV) {
                setState(() {
                  _isVisualMode = !_isVisualMode;
                  _anchorRow = _cursorRow;
                  _anchorCol = _cursorCol;
                });
                return KeyEventResult.handled;
              }

              if (_isVisualMode &&
                  event.logicalKey == LogicalKeyboardKey.keyY) {
                final startRow = math.min(_anchorRow, _cursorRow);
                final endRow = math.max(_anchorRow, _cursorRow);
                final selectedText = lines
                    .sublist(startRow, endRow + 1)
                    .map((l) => l.span.toPlainText())
                    .join('\n');
                Clipboard.setData(ClipboardData(text: selectedText));
                setState(() {
                  _isVisualMode = false;
                  _anchorRow = -1;
                });
                return KeyEventResult.handled;
              }
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
                  if (constraints.maxWidth < 800) {
                    return Scaffold(
                      backgroundColor: gruberBg,
                      appBar: AppBar(
                        backgroundColor: gruberBgDarker,
                        title: Text(
                          _currentFile,
                          style: const TextStyle(
                            color: gruberYellow,
                            fontFamily: _terminalFontFamily,
                            fontSize: 14,
                          ),
                        ),
                        iconTheme: const IconThemeData(color: gruberFg),
                        actions: [
                          IconButton(
                            icon: const Icon(
                              Icons.exit_to_app,
                              color: gruberRed,
                            ),
                            tooltip: 'Exit Dev View',
                            onPressed: () {
                              portfolioViewNotifier.value =
                                  PortfolioView.professional;
                            },
                          ),
                        ],
                      ),
                      drawer: Drawer(
                        backgroundColor: gruberBgDarker,
                        child: _HelixPicker(
                          localFiles: _localFiles,
                          selectedFile: _currentFile,
                          expandedPaths: _expandedPaths,
                          childrenCache: _childrenCache,
                          onFileSelected:
                              (f, {gitlabUrl, remotePath, scrollToLine}) {
                                _handleFileSelection(
                                  f,
                                  gitlabUrl: gitlabUrl,
                                  remotePath: remotePath,
                                  scrollToLine: scrollToLine,
                                );
                                Navigator.of(context).pop();
                              },
                          onPathToggle: _togglePath,
                        ),
                      ),
                      body: Stack(
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
                                  wrapText: true,
                                  cursorRow: _cursorRow,
                                  cursorCol: _cursorCol,
                                  isVisualMode: _isVisualMode,
                                  anchorRow: _anchorRow,
                                  anchorCol: _anchorCol,
                                ),
                          if (_currentFile.endsWith('.md'))
                            Positioned(
                              top: 16,
                              right: 16,
                              child: _buildPreviewToggle(),
                            ),
                        ],
                      ),
                    );
                  }

                  final bool shouldShowPicker = !_isZenMode && _isPickerOpen;
                  return Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            if (shouldShowPicker)
                              SizedBox(
                                width: 280,
                                child: _HelixPicker(
                                  localFiles: _localFiles,
                                  selectedFile: _currentFile,
                                  expandedPaths: _expandedPaths,
                                  childrenCache: _childrenCache,
                                  onFileSelected: _handleFileSelection,
                                  onPathToggle: _togglePath,
                                ),
                              ),
                            Expanded(
                              child: Column(
                                children: [
                                  if (!_isZenMode)
                                    _HelixTabBar(
                                      openBuffers: _openBuffers,
                                      activeIndex: _activeBufferIndex,
                                      onTabSelected: (idx) =>
                                          _handleFileSelection(
                                            _openBuffers[idx],
                                          ),
                                      onTabClosed: _closeBuffer,
                                    ),
                                  Expanded(
                                    child: Stack(
                                      children: [
                                        _isImage && _imageUrl != null
                                            ? _buildImageBuffer()
                                            : (_isPreviewMode &&
                                                  _currentFile.endsWith('.md'))
                                            ? _buildMarkdownPreview()
                                            : (_isMatrixMode
                                                  ? ColorFiltered(
                                                      colorFilter:
                                                          const ColorFilter.matrix(
                                                            <double>[
                                                              0,
                                                              0,
                                                              0,
                                                              0,
                                                              0,
                                                              0.2126,
                                                              0.7152,
                                                              0.0722,
                                                              0,
                                                              0,
                                                              0,
                                                              0,
                                                              0,
                                                              0,
                                                              0,
                                                              0,
                                                              0,
                                                              0,
                                                              1,
                                                              0,
                                                            ],
                                                          ),
                                                      child: _HelixBuffer(
                                                        fileName: _currentFile,
                                                        isLoading: _isLoading,
                                                        lines: _getBufferLines(
                                                          _currentFile,
                                                        ),
                                                        scrollController:
                                                            _scrollController,
                                                        relativeLineNumbers:
                                                            _relativeLineNumbers,
                                                        currentLine:
                                                            _cursorRow + 1,
                                                        wrapText: _wrapText,
                                                        highlightCursorLine:
                                                            _cursorLine,
                                                        isVisualMode:
                                                            _isVisualMode,
                                                        cursorRow: _cursorRow,
                                                        cursorCol: _cursorCol,
                                                        anchorRow: _anchorRow,
                                                        anchorCol: _anchorCol,
                                                        showBlame: _showBlame,
                                                      ),
                                                    )
                                                  : _HelixBuffer(
                                                      fileName: _currentFile,
                                                      isLoading: _isLoading,
                                                      lines: _getBufferLines(
                                                        _currentFile,
                                                      ),
                                                      scrollController:
                                                          _scrollController,
                                                      relativeLineNumbers:
                                                          _relativeLineNumbers,
                                                      currentLine:
                                                          _cursorRow + 1,
                                                      wrapText: _wrapText,
                                                      highlightCursorLine:
                                                          _cursorLine,
                                                      isVisualMode:
                                                          _isVisualMode,
                                                      cursorRow: _cursorRow,
                                                      cursorCol: _cursorCol,
                                                      anchorRow: _anchorRow,
                                                      anchorCol: _anchorCol,
                                                      showBlame: _showBlame,
                                                    )),
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
                      if (!_isZenMode)
                        _HelixStatusArea(
                          currentFile: _currentFile,
                          localFiles: _localFiles,
                          isCommandMode: _isCommandMode,
                          isSearchMode: _isSearchMode,
                          isVisualMode: _isVisualMode,
                          commandController: _commandController,
                          commandFocusNode: _commandFocusNode,
                          onCommandSubmit: _executeCommand,
                          onSearchChanged: (val) =>
                              setState(() => _searchQuery = val),
                          stats: _getStats(),
                          currentLine: _cursorRow + 1,
                          currentCol: _cursorCol + 1,
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
          Text(
            _currentFile,
            style: const TextStyle(
              color: gruberQuartz,
              fontFamily: _terminalFontFamily,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Image.network(
              _imageUrl!,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) =>
                  loadingProgress == null
                  ? child
                  : const Center(
                      child: CircularProgressIndicator(color: gruberYellow),
                    ),
              errorBuilder: (context, error, stackTrace) => Text(
                'Error loading image: $error',
                style: const TextStyle(color: gruberRed),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarkdownPreview() {
    final String content = _remoteContent ?? _getLocalRawContent(_currentFile);
    return Container(
      color: gruberBg,
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      child: Markdown(
        data: content,
        styleSheet: MarkdownStyleSheet(
          p: const TextStyle(color: gruberFg, fontFamily: _terminalFontFamily),
          h1: const TextStyle(
            color: gruberYellow,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: _terminalFontFamily,
          ),
          h2: const TextStyle(
            color: gruberYellow,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: _terminalFontFamily,
          ),
          h3: const TextStyle(
            color: gruberYellow,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: _terminalFontFamily,
          ),
          code: const TextStyle(
            backgroundColor: gruberBgDarker,
            color: gruberGreen,
            fontFamily: _terminalFontFamily,
          ),
          blockquote: const TextStyle(
            color: gruberQuartz,
            fontStyle: FontStyle.italic,
            fontFamily: _terminalFontFamily,
          ),
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
                style: const TextStyle(
                  color: gruberYellow,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  fontFamily: _terminalFontFamily,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<LineData> _getBufferLines(String buffer) {
    if (_isLoading && _remoteContent == null) {
      return [
        LineData(
          span: const TextSpan(
            text: '// Communicating with Contribution API...',
            style: TextStyle(color: gruberQuartz),
          ),
        ),
      ];
    }

    String contentToRender =
        _remoteContent ??
        _typingContent?.substring(0, _visibleChars) ??
        _getLocalRawContent(buffer);

    if (_isHexMode) {
      final lines = _getHexDumpLines(contentToRender);
      return _searchQuery.isNotEmpty
          ? lines
                .map(
                  (l) => LineData(
                    span: _applySearchHighlight(l.span, _searchQuery),
                  ),
                )
                .toList()
          : lines;
    }

    final ext = buffer.split('.').last.toLowerCase();
    return switch (ext) {
      'dart' => _DartHighlighter.highlight(
        contentToRender,
        searchQuery: _searchQuery,
        onSymbolClick: (symbol) async {
          final gitlabUrl = _findGitlabUrlForPath(buffer);
          if (gitlabUrl != null) {
            setState(() => _isLoading = true);
            final match = await ContributionService.searchSymbol(
              gitlabUrl,
              symbol,
              currentFilePath: _extractRemotePath(buffer),
            );
            if (match != null) {
              final project = portfolio.projects.firstWhere(
                (p) => p.gitlabLink == gitlabUrl,
              );
              _handleFileSelection(
                '${_getSlug(project)}/${match.path}',
                gitlabUrl: gitlabUrl,
                remotePath: match.path,
                scrollToLine: match.lineIndex,
              );
            } else {
              setState(() => _isLoading = false);
            }
          }
        },
      ),
      'rs' => _RustHighlighter.highlight(
        contentToRender,
        searchQuery: _searchQuery,
      ),
      'js' || 'ts' => _JavascriptHighlighter.highlight(
        contentToRender,
        searchQuery: _searchQuery,
      ),
      'html' || 'htm' => _HtmlHighlighter.highlight(
        contentToRender,
        searchQuery: _searchQuery,
      ),
      'css' => _CssHighlighter.highlight(
        contentToRender,
        searchQuery: _searchQuery,
      ),
      'sh' || 'bash' => _BashHighlighter.highlight(
        contentToRender,
        searchQuery: _searchQuery,
      ),
      'yaml' || 'yml' => _YamlHighlighter.highlight(
        contentToRender,
        searchQuery: _searchQuery,
      ),
      'toml' => _TomlHighlighter.highlight(
        contentToRender,
        searchQuery: _searchQuery,
      ),
      'bat' || 'cmd' => _BatchHighlighter.highlight(
        contentToRender,
        searchQuery: _searchQuery,
      ),
      'md' => _MarkdownHighlighter.highlight(
        contentToRender,
        searchQuery: _searchQuery,
      ),
      _ => _GenericHighlighter.highlightPlain(
        contentToRender,
        _getRemoteStyle(buffer),
        searchQuery: _searchQuery,
      ),
    };
  }

  List<LineData> _getHexDumpLines(String content) {
    final List<LineData> lines = [];
    final bytes = utf8.encode(content);
    for (int i = 0; i < bytes.length; i += 16) {
      final chunk = bytes.sublist(i, math.min(i + 16, bytes.length));
      final hexPart = chunk
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join(' ');
      final paddedHex = hexPart.padRight(47, ' ');
      final asciiPart = String.fromCharCodes(
        chunk.map((b) => (b >= 32 && b <= 126) ? b : 46),
      );
      final offset = i.toRadixString(16).padLeft(8, '0');
      lines.add(
        LineData(
          span: TextSpan(
            children: [
              TextSpan(
                text: '$offset: ',
                style: const TextStyle(color: gruberNiagara),
              ),
              TextSpan(
                text: '$paddedHex  ',
                style: const TextStyle(color: gruberFg),
              ),
              const TextSpan(
                text: '|',
                style: TextStyle(color: gruberQuartz),
              ),
              TextSpan(
                text: asciiPart,
                style: const TextStyle(color: gruberGreen),
              ),
              const TextSpan(
                text: '|',
                style: TextStyle(color: gruberQuartz),
              ),
            ],
          ),
        ),
      );
    }
    return lines;
  }

  Color _getRemoteStyle(String buffer) {
    final ext = buffer.split('.').last.toLowerCase();
    return switch (ext) {
      'dart' ||
      'rs' ||
      'js' ||
      'ts' ||
      'html' ||
      'css' ||
      'sh' ||
      'bash' ||
      'yaml' ||
      'toml' ||
      'bat' ||
      'cmd' ||
      'md' => gruberFg,
      _ => gruberQuartz,
    };
  }

  TextSpan _applySearchHighlight(TextSpan span, String query) {
    if (span.text != null && span.text!.isNotEmpty)
      return _GenericHighlighter.highlightSearchInText(
        span.text!,
        span.style ?? const TextStyle(),
        query,
      );
    if (span.children != null)
      return TextSpan(
        style: span.style,
        children: span.children!
            .map((c) => c is TextSpan ? _applySearchHighlight(c, query) : c)
            .toList(),
      );
    return span;
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
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => onTabSelected(i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isSelected ? gruberBg : gruberBgDarker,
                  border: Border(
                    top: BorderSide(
                      color: isSelected ? gruberYellow : Colors.transparent,
                      width: 2,
                    ),
                    right: const BorderSide(color: gruberBgLighter, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      openBuffers[i].split('/').last,
                      style: TextStyle(
                        color: isSelected ? gruberFg : gruberQuartz,
                        fontFamily: _terminalFontFamily,
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => onTabClosed(i),
                      child: Icon(
                        Icons.close,
                        size: 12,
                        color: isSelected ? gruberRed : gruberQuartz,
                      ),
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
  final Function(
    String, {
    String? gitlabUrl,
    String? remotePath,
    int? scrollToLine,
  })
  onFileSelected;
  final Function(String, {Project? project, String? remoteRelativePath})
  onPathToggle;
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
      decoration: const BoxDecoration(
        color: gruberBgDarker,
        border: Border(right: BorderSide(color: gruberBgLighter, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: gruberBgLighter,
            child: const Row(
              children: [
                Icon(Icons.folder_open, size: 16, color: gruberQuartz),
                SizedBox(width: 8),
                Text(
                  'explorer',
                  style: TextStyle(
                    color: gruberFg,
                    fontFamily: _terminalFontFamily,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text(
                    'SYSTEM',
                    style: TextStyle(
                      color: gruberQuartz,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...localFiles.map(
                  (f) => _buildItem(
                    f,
                    f == selectedFile,
                    Icons.description_outlined,
                    () => onFileSelected(f),
                    0,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 20, 16, 4),
                  child: Text(
                    'PUBLIC PROJECTS',
                    style: TextStyle(
                      color: gruberQuartz,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...portfolio.projects
                    .where((p) => p.gitlabLink != null)
                    .map(
                      (p) => _buildLazyTree(
                        p,
                        p.title
                            .toLowerCase()
                            .replaceAll(' ', '_')
                            .replaceAll('(', '')
                            .replaceAll(')', ''),
                        '',
                        0,
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLazyTree(
    Project p,
    String fullPath,
    String remoteRelativePath,
    int depth,
  ) {
    final isExpanded = expandedPaths.contains(fullPath);
    final children = childrenCache[fullPath] ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildItem(
          depth == 0 ? p.title : fullPath.split('/').last,
          false,
          isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
          () => onPathToggle(
            fullPath,
            project: depth == 0 ? p : null,
            remoteRelativePath: remoteRelativePath,
          ),
          depth,
          color: depth == 0 ? gruberYellow : gruberNiagara,
        ),
        if (isExpanded)
          ...children.map((node) {
            final name = node['name'] as String;
            final type = node['type'] as String;
            final nodePath = node['path'] as String;
            final nodeFullPath = '${fullPath.split('/').first}/$nodePath';
            return type == 'tree'
                ? _buildLazyTree(p, nodeFullPath, nodePath, depth + 1)
                : _buildItem(
                    name,
                    selectedFile == nodeFullPath,
                    Icons.code,
                    () => onFileSelected(
                      nodeFullPath,
                      gitlabUrl: p.gitlabLink,
                      remotePath: nodePath,
                    ),
                    depth + 1,
                  );
          }),
      ],
    );
  }

  Widget _buildItem(
    String text,
    bool isSelected,
    IconData icon,
    VoidCallback onTap,
    int depth, {
    Color? color,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.fromLTRB(16.0 + (depth * 12), 6, 16, 6),
          color: isSelected ? gruberBgLighter : Colors.transparent,
          child: Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? gruberYellow : (color ?? gruberQuartz),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: isSelected
                        ? gruberYellow
                        : (color ?? gruberFg.withValues(alpha: 0.7)),
                    fontFamily: _terminalFontFamily,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
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
  final bool relativeLineNumbers;
  final int currentLine;
  final bool wrapText;
  final bool highlightCursorLine;
  final bool isVisualMode;
  final int cursorRow;
  final int cursorCol;
  final int anchorRow;
  final int anchorCol;
  final bool showBlame;

  const _HelixBuffer({
    required this.fileName,
    required this.lines,
    this.isLoading = false,
    this.scrollController,
    this.relativeLineNumbers = false,
    this.currentLine = 1,
    this.wrapText = false,
    this.highlightCursorLine = true,
    this.isVisualMode = false,
    required this.cursorRow,
    required this.cursorCol,
    required this.anchorRow,
    required this.anchorCol,
    this.showBlame = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Text(
                fileName,
                style: const TextStyle(
                  color: gruberQuartz,
                  fontFamily: _terminalFontFamily,
                  fontSize: 12,
                ),
              ),
              if (isLoading) ...[
                const SizedBox(width: 8),
                const SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: gruberYellow,
                  ),
                ),
              ],
            ],
          ),
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
                  final actualLineNum = i + 1;
                  final isCursorLine = i == cursorRow;

                  String displayNum = '$actualLineNum';
                  Color numColor = gruberBgLighter;
                  if (relativeLineNumbers) {
                    if (isCursorLine) {
                      displayNum = '$actualLineNum';
                      numColor = gruberYellow;
                    } else {
                      displayNum = '${(actualLineNum - currentLine).abs()}';
                    }
                  } else if (isCursorLine && highlightCursorLine) {
                    numColor = gruberYellow;
                  }

                  TextSpan finalSpan = line.span;
                  if (isCursorLine || isVisualMode) {
                    finalSpan = _injectCursorAndSelection(line.span, i);
                  }

                  return Container(
                    color:
                        (highlightCursorLine && isCursorLine && !isVisualMode)
                        ? gruberBgLighter.withValues(alpha: 0.5)
                        : Colors.transparent,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showBlame)
                          SizedBox(
                            width: 120,
                            child: Text(
                              _getPseudoBlame(actualLineNum),
                              style: TextStyle(
                                color: gruberQuartz.withValues(alpha: 0.6),
                                fontFamily: _terminalFontFamily,
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.clip,
                              softWrap: false,
                            ),
                          ),
                        SizedBox(
                          width: 40,
                          child: Text(
                            displayNum.padLeft(3),
                            style: TextStyle(
                              color: numColor,
                              fontFamily: _terminalFontFamily,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text.rich(
                            finalSpan,
                            maxLines: wrapText ? null : 1,
                            softWrap: wrapText,
                            overflow: wrapText
                                ? TextOverflow.visible
                                : TextOverflow.clip,
                            style: const TextStyle(
                              fontFamily: _terminalFontFamily,
                              fontSize: _terminalFontSize,
                              color: gruberFg,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  TextSpan _injectCursorAndSelection(TextSpan span, int row) {
    final text = span.toPlainText();
    final List<TextSpan> children = [];

    for (int col = 0; col < text.length; col++) {
      final char = text[col];
      bool isSelected = false;
      if (isVisualMode && anchorRow != -1) {
        final startR = math.min(anchorRow, cursorRow);
        final endR = math.max(anchorRow, cursorRow);
        if (row > startR && row < endR) {
          isSelected = true;
        } else if (row == startR && row == endR) {
          final startC = math.min(anchorCol, cursorCol);
          final endC = math.max(anchorCol, cursorCol);
          isSelected = col >= startC && col <= endC;
        } else if (row == startR) {
          final startC = (anchorRow < cursorRow) ? anchorCol : cursorCol;
          isSelected = col >= startC;
        } else if (row == endR) {
          final endC = (anchorRow > cursorRow) ? anchorCol : cursorCol;
          isSelected = col <= endC;
        }
      }

      final bool isCursor = (row == cursorRow && col == cursorCol);

      TextStyle style = span.style ?? const TextStyle();
      Color? bg;
      if (isCursor) {
        bg = gruberYellow;
      } else if (isSelected) {
        bg = gruberWisteria.withValues(alpha: 0.4);
      }

      children.add(
        TextSpan(
          text: char,
          style: style.copyWith(
            backgroundColor: bg,
            color: isCursor ? Colors.black : null,
          ),
        ),
      );
    }

    if (row == cursorRow && cursorCol >= text.length) {
      children.add(
        const TextSpan(
          text: ' ',
          style: TextStyle(backgroundColor: gruberYellow),
        ),
      );
    }

    return TextSpan(children: children);
  }

  String _getPseudoBlame(int lineNum) {
    final hash = (fileName.hashCode ^ lineNum).abs();
    final authors = ['Tristan', 'Tristan', 'harvey'];
    if (hash % 5 == 0 || lineNum == 1) {
      return '${authors[hash % authors.length]} • 2d ago'.padRight(18);
    }
    return ''.padRight(18);
  }
}

class _HelixStatusArea extends StatelessWidget {
  final String currentFile;
  final List<String> localFiles;
  final bool isCommandMode;
  final bool isSearchMode;
  final bool isVisualMode;
  final TextEditingController commandController;
  final FocusNode commandFocusNode;
  final Function(String) onCommandSubmit;
  final Function(String) onSearchChanged;
  final _BufferStats stats;
  final int currentLine;
  final int currentCol;
  const _HelixStatusArea({
    required this.currentFile,
    required this.localFiles,
    required this.isCommandMode,
    required this.isSearchMode,
    required this.isVisualMode,
    required this.commandController,
    required this.commandFocusNode,
    required this.onCommandSubmit,
    required this.onSearchChanged,
    required this.stats,
    required this.currentLine,
    required this.currentCol,
  });
  @override
  Widget build(BuildContext context) {
    final displayPath = localFiles.contains(currentFile)
        ? '~/system/$currentFile'
        : '~/projects/$currentFile';
    String modeText = ' NOR ';
    Color modeColor = gruberYellow;
    if (isCommandMode) {
      modeText = ' CMD ';
      modeColor = gruberWisteria;
    } else if (isSearchMode) {
      modeText = ' SRC ';
      modeColor = gruberNiagara;
    } else if (isVisualMode) {
      modeText = ' VIS ';
      modeColor = gruberOrange;
    }
    return Column(
      children: [
        Container(
          height: 24,
          color: gruberBgLighter,
          child: Row(
            children: [
              _StatusBlock(
                text: modeText,
                bgColor: modeColor,
                textColor: Colors.black,
              ),
              _StatusBlock(
                text: ' $displayPath ',
                bgColor: gruberBg,
                textColor: gruberFg,
              ),
              const Spacer(),
              _StatusBlock(
                text: ' ${stats.words} words ',
                bgColor: gruberBg,
                textColor: gruberQuartz,
              ),
              _StatusBlock(
                text: ' ${stats.size}b ',
                bgColor: gruberBg,
                textColor: gruberNiagara,
              ),
              _StatusBlock(
                text: ' ${stats.lines} lines ',
                bgColor: gruberBg,
                textColor: gruberFg,
              ),
              _StatusBlock(
                text: ' $currentLine:$currentCol ',
                bgColor: gruberBg,
                textColor: gruberFg,
              ),
              _StatusBlock(
                text: ' ${_getLangLabel(currentFile)} ',
                bgColor: gruberYellow,
                textColor: Colors.black,
              ),
            ],
          ),
        ),
        Container(
          height: 24,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          color: gruberBgDarker,
          child: Row(
            children: [
              Text(
                isSearchMode ? '/' : ':',
                style: TextStyle(
                  color: isSearchMode ? gruberNiagara : gruberFg,
                  fontFamily: _terminalFontFamily,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              if (isCommandMode || isSearchMode)
                Expanded(
                  child: TextField(
                    controller: commandController,
                    focusNode: commandFocusNode,
                    style: const TextStyle(
                      color: gruberFg,
                      fontFamily: _terminalFontFamily,
                      fontSize: 13,
                    ),
                    cursorColor: isSearchMode ? gruberNiagara : gruberYellow,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
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
  final String text;
  final Color bgColor;
  final Color textColor;
  const _StatusBlock({
    required this.text,
    required this.bgColor,
    required this.textColor,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgColor,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontFamily: _terminalFontFamily,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor();
  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(width: 8, height: 16, color: gruberYellow),
    );
  }
}

class _CRTOverlay extends StatefulWidget {
  const _CRTOverlay();
  @override
  State<_CRTOverlay> createState() => _CRTOverlayState();
}

class _CRTOverlayState extends State<_CRTOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Container(
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
      ),
    );
  }
}

class _GenericHighlighter {
  static List<LineData> highlight(
    String code,
    Set<String> keywords, {
    Color keywordColor = gruberYellow,
    String commentPrefix = '//',
    String searchQuery = '',
  }) {
    final List<LineData> lines = [];
    for (var line in code.split('\n')) {
      final List<TextSpan> spans = [];
      int ci = line.indexOf(commentPrefix);
      String text = ci != -1 ? line.substring(0, ci) : line;
      String comment = ci != -1 ? line.substring(ci) : '';
      for (var token in _tokenize(text)) {
        final t = token.text;
        final trimmed = t.trim();
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
        spans.add(
          highlightSearchInText(
            t,
            TextStyle(color: color, fontWeight: weight),
            searchQuery,
          ),
        );
      }
      if (comment.isNotEmpty)
        spans.add(
          highlightSearchInText(
            comment,
            const TextStyle(color: gruberQuartz, fontStyle: FontStyle.italic),
            searchQuery,
          ),
        );
      lines.add(LineData(span: TextSpan(children: spans)));
    }
    return lines;
  }

  static List<LineData> highlightPlain(
    String code,
    Color defaultColor, {
    String searchQuery = '',
  }) => code
      .split('\n')
      .map(
        (l) => LineData(
          span: highlightSearchInText(
            l,
            TextStyle(color: defaultColor),
            searchQuery,
          ),
        ),
      )
      .toList();
  static TextSpan highlightSearchInText(
    String text,
    TextStyle baseStyle,
    String query,
  ) {
    if (query.isEmpty) return TextSpan(text: text, style: baseStyle);
    final matches = query.toLowerCase().allMatches(text.toLowerCase()).toList();
    if (matches.isEmpty) return TextSpan(text: text, style: baseStyle);
    List<TextSpan> spans = [];
    int last = 0;
    for (var m in matches) {
      if (m.start > last)
        spans.add(
          TextSpan(text: text.substring(last, m.start), style: baseStyle),
        );
      spans.add(
        TextSpan(
          text: text.substring(m.start, m.end),
          style: baseStyle.copyWith(
            backgroundColor: gruberYellow,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      last = m.end;
    }
    if (last < text.length)
      spans.add(TextSpan(text: text.substring(last), style: baseStyle));
    return TextSpan(children: spans);
  }

  static List<_Token> _tokenize(String text) {
    final List<_Token> tokens = [];
    final pattern = RegExp(
      '("[^"]*"|\'[^\']*\'|\\b[a-zA-Z_]\\w*\\b|\\d+|[^\\s\\w]+|\\s+)',
    );
    final matches = pattern.allMatches(text);
    for (var match in matches) {
      tokens.add(_Token(match.group(0)!));
    }
    return tokens;
  }
}

class _DartHighlighter {
  static final keywords = {
    'abstract',
    'as',
    'assert',
    'async',
    'await',
    'break',
    'case',
    'catch',
    'class',
    'const',
    'continue',
    'covariant',
    'default',
    'deferred',
    'do',
    'dynamic',
    'else',
    'enum',
    'export',
    'extends',
    'extension',
    'external',
    'factory',
    'false',
    'final',
    'finally',
    'for',
    'function',
    'get',
    'hide',
    'if',
    'implements',
    'import',
    'in',
    'interface',
    'is',
    'late',
    'library',
    'mixin',
    'new',
    'null',
    'on',
    'operator',
    'part',
    'rethrow',
    'return',
    'set',
    'show',
    'static',
    'super',
    'switch',
    'sync',
    'this',
    'throw',
    'true',
    'try',
    'typedef',
    'var',
    'void',
    'while',
    'with',
    'yield',
  };
  static List<LineData> highlight(
    String code, {
    Function(String)? onSymbolClick,
    String searchQuery = '',
  }) {
    final List<LineData> lines = [];
    for (var line in code.split('\n')) {
      final List<TextSpan> spans = [];
      int ci = line.indexOf('//');
      String text = ci != -1 ? line.substring(0, ci) : line;
      String comment = ci != -1 ? line.substring(ci) : '';
      for (var token in _GenericHighlighter._tokenize(text)) {
        final t = token.text;
        final isType = RegExp(r'^[A-Z]\w*$').hasMatch(t.trim());
        spans.add(
          TextSpan(
            children: [
              _GenericHighlighter.highlightSearchInText(
                t,
                _getStyle(t, isType, onSymbolClick != null),
                searchQuery,
              ),
            ],
            recognizer: (isType && onSymbolClick != null)
                ? (TapGestureRecognizer()
                    ..onTap = () => onSymbolClick(t.trim()))
                : null,
          ),
        );
      }
      if (comment.isNotEmpty)
        spans.add(
          _GenericHighlighter.highlightSearchInText(
            comment,
            const TextStyle(color: gruberQuartz, fontStyle: FontStyle.italic),
            searchQuery,
          ),
        );
      lines.add(LineData(span: TextSpan(children: spans)));
    }
    return lines;
  }

  static TextStyle _getStyle(String t, bool isType, bool clickable) {
    final trimmed = t.trim();
    if (keywords.contains(trimmed))
      return const TextStyle(color: gruberYellow, fontWeight: FontWeight.bold);
    if (isType)
      return TextStyle(
        color: gruberNiagara,
        decoration: clickable ? TextDecoration.underline : null,
        decorationColor: gruberNiagara.withValues(alpha: 0.5),
      );
    if (trimmed.startsWith("'") || trimmed.startsWith('"'))
      return const TextStyle(color: gruberGreen);
    if (RegExp(r'^\d+$').hasMatch(trimmed))
      return const TextStyle(color: gruberBrown);
    return const TextStyle(color: gruberFg);
  }
}

class _RustHighlighter {
  static final keywords = {
    'as',
    'async',
    'await',
    'break',
    'const',
    'continue',
    'crate',
    'dyn',
    'else',
    'enum',
    'extern',
    'false',
    'fn',
    'for',
    'if',
    'impl',
    'import',
    'in',
    'let',
    'loop',
    'match',
    'mod',
    'move',
    'mut',
    'pub',
    'ref',
    'return',
    'self',
    'Self',
    'static',
    'struct',
    'super',
    'trait',
    'true',
    'type',
    'union',
    'unsafe',
    'use',
    'where',
    'while',
  };
  static List<LineData> highlight(String code, {String searchQuery = ''}) =>
      _GenericHighlighter.highlight(
        code,
        keywords,
        keywordColor: gruberOrange,
        searchQuery: searchQuery,
      );
}

class _JavascriptHighlighter {
  static final keywords = {
    'break',
    'case',
    'catch',
    'class',
    'const',
    'continue',
    'debugger',
    'default',
    'delete',
    'do',
    'else',
    'export',
    'extends',
    'finally',
    'for',
    'function',
    'if',
    'import',
    'in',
    'instanceof',
    'new',
    'return',
    'super',
    'switch',
    'this',
    'throw',
    'try',
    'typeof',
    'var',
    'void',
    'while',
    'with',
    'yield',
    'let',
    'static',
    'async',
    'await',
    'of',
  };
  static List<LineData> highlight(String code, {String searchQuery = ''}) =>
      _GenericHighlighter.highlight(
        code,
        keywords,
        keywordColor: gruberYellow,
        searchQuery: searchQuery,
      );
}

class _BashHighlighter {
  static final keywords = {
    'if',
    'then',
    'else',
    'elif',
    'fi',
    'case',
    'esac',
    'for',
    'while',
    'until',
    'do',
    'done',
    'in',
    'function',
    'return',
    'local',
    'export',
    'alias',
    'echo',
    'exit',
    'break',
    'continue',
  };
  static List<LineData> highlight(String code, {String searchQuery = ''}) =>
      _GenericHighlighter.highlight(
        code,
        keywords,
        keywordColor: gruberGreen,
        commentPrefix: '#',
        searchQuery: searchQuery,
      );
}

class _YamlHighlighter {
  static List<LineData> highlight(String code, {String searchQuery = ''}) {
    final List<LineData> lines = [];
    for (var line in code.split('\n')) {
      final List<TextSpan> spans = [];
      if (line.trim().startsWith('#')) {
        spans.add(
          _GenericHighlighter.highlightSearchInText(
            line,
            const TextStyle(color: gruberQuartz, fontStyle: FontStyle.italic),
            searchQuery,
          ),
        );
      } else if (line.contains(':')) {
        final p = line.split(':');
        spans.add(
          _GenericHighlighter.highlightSearchInText(
            p[0],
            const TextStyle(color: gruberYellow, fontWeight: FontWeight.bold),
            searchQuery,
          ),
        );
        spans.add(
          _GenericHighlighter.highlightSearchInText(
            ':',
            const TextStyle(color: gruberQuartz),
            searchQuery,
          ),
        );
        spans.add(
          _GenericHighlighter.highlightSearchInText(
            p.sublist(1).join(':'),
            const TextStyle(color: gruberFg),
            searchQuery,
          ),
        );
      } else {
        spans.add(
          _GenericHighlighter.highlightSearchInText(
            line,
            const TextStyle(color: gruberFg),
            searchQuery,
          ),
        );
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
        spans.add(
          _GenericHighlighter.highlightSearchInText(
            line,
            const TextStyle(color: gruberQuartz, fontStyle: FontStyle.italic),
            searchQuery,
          ),
        );
      } else if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
        spans.add(
          _GenericHighlighter.highlightSearchInText(
            line,
            const TextStyle(color: gruberWisteria, fontWeight: FontWeight.bold),
            searchQuery,
          ),
        );
      } else if (line.contains('=')) {
        final p = line.split('=');
        spans.add(
          _GenericHighlighter.highlightSearchInText(
            p[0],
            const TextStyle(color: gruberYellow),
            searchQuery,
          ),
        );
        spans.add(
          _GenericHighlighter.highlightSearchInText(
            ' = ',
            const TextStyle(color: gruberQuartz),
            searchQuery,
          ),
        );
        spans.add(
          _GenericHighlighter.highlightSearchInText(
            p.sublist(1).join('='),
            const TextStyle(color: gruberGreen),
            searchQuery,
          ),
        );
      } else {
        spans.add(
          _GenericHighlighter.highlightSearchInText(
            line,
            const TextStyle(color: gruberFg),
            searchQuery,
          ),
        );
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
        final t = m.group(0)!;
        if (t.startsWith('<')) {
          spans.add(
            _GenericHighlighter.highlightSearchInText(
              t,
              const TextStyle(color: gruberOrange, fontWeight: FontWeight.bold),
              searchQuery,
            ),
          );
        } else {
          spans.add(
            _GenericHighlighter.highlightSearchInText(
              t,
              const TextStyle(color: gruberFg),
              searchQuery,
            ),
          );
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
        final p = line.split('{');
        spans.add(
          _GenericHighlighter.highlightSearchInText(
            p[0],
            const TextStyle(color: gruberYellow, fontWeight: FontWeight.bold),
            searchQuery,
          ),
        );
        spans.add(
          _GenericHighlighter.highlightSearchInText(
            ' {',
            const TextStyle(color: gruberQuartz),
            searchQuery,
          ),
        );
      } else if (line.contains(':')) {
        final p = line.split(':');
        spans.add(
          _GenericHighlighter.highlightSearchInText(
            p[0],
            const TextStyle(color: gruberNiagara),
            searchQuery,
          ),
        );
        spans.add(
          _GenericHighlighter.highlightSearchInText(
            ': ',
            const TextStyle(color: gruberQuartz),
            searchQuery,
          ),
        );
        spans.add(
          _GenericHighlighter.highlightSearchInText(
            p.sublist(1).join(':'),
            const TextStyle(color: gruberGreen),
            searchQuery,
          ),
        );
      } else {
        spans.add(
          _GenericHighlighter.highlightSearchInText(
            line,
            const TextStyle(color: gruberFg),
            searchQuery,
          ),
        );
      }
      lines.add(LineData(span: TextSpan(children: spans)));
    }
    return lines;
  }
}

class _BatchHighlighter {
  static final keywords = {
    'echo',
    'set',
    'if',
    'else',
    'goto',
    'pause',
    'exit',
    'call',
    'rem',
    'for',
    'in',
    'do',
  };
  static List<LineData> highlight(String code, {String searchQuery = ''}) =>
      _GenericHighlighter.highlight(
        code,
        keywords,
        keywordColor: gruberYellow,
        commentPrefix: 'rem',
        searchQuery: searchQuery,
      );
}

class _MarkdownHighlighter {
  static List<LineData> highlight(String code, {String searchQuery = ''}) {
    final List<LineData> lines = [];
    for (var line in code.split('\n')) {
      final List<TextSpan> spans = [];
      final t = line.trim();
      if (t.startsWith('#')) {
        spans.add(
          _GenericHighlighter.highlightSearchInText(
            line,
            const TextStyle(color: gruberNiagara, fontWeight: FontWeight.bold),
            searchQuery,
          ),
        );
      } else if (t.startsWith('>')) {
        spans.add(
          _GenericHighlighter.highlightSearchInText(
            line,
            const TextStyle(color: gruberBrown, fontStyle: FontStyle.italic),
            searchQuery,
          ),
        );
      } else if (t.startsWith('- ') || t.startsWith('* ')) {
        final di = line.indexOf(t.substring(0, 2));
        if (di != -1) {
          spans.add(
            TextSpan(
              text: line.substring(0, di),
              style: const TextStyle(color: gruberFg),
            ),
          );
          spans.add(
            const TextSpan(
              text: '• ',
              style: TextStyle(
                color: gruberYellow,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
          spans.add(
            _GenericHighlighter.highlightSearchInText(
              line.substring(di + 2),
              const TextStyle(color: gruberFg),
              searchQuery,
            ),
          );
        } else {
          spans.add(
            _GenericHighlighter.highlightSearchInText(
              line,
              const TextStyle(color: gruberFg),
              searchQuery,
            ),
          );
        }
      } else if (t.startsWith('```')) {
        spans.add(
          _GenericHighlighter.highlightSearchInText(
            line,
            const TextStyle(color: gruberQuartz),
            searchQuery,
          ),
        );
      } else {
        final parts = line.split('`');
        for (int i = 0; i < parts.length; i++) {
          if (i % 2 == 1) {
            spans.add(
              _GenericHighlighter.highlightSearchInText(
                '`${parts[i]}`',
                const TextStyle(color: gruberGreen),
                searchQuery,
              ),
            );
          } else {
            final linkPattern = RegExp(r'\[([^\]]+)\]\(([^\)]+)\)');
            final linkMatches = linkPattern.allMatches(parts[i]);
            if (linkMatches.isEmpty) {
              spans.add(
                _GenericHighlighter.highlightSearchInText(
                  parts[i],
                  const TextStyle(color: gruberFg),
                  searchQuery,
                ),
              );
            } else {
              int last = 0;
              for (var m in linkMatches) {
                if (m.start > last)
                  spans.add(
                    _GenericHighlighter.highlightSearchInText(
                      parts[i].substring(last, m.start),
                      const TextStyle(color: gruberFg),
                      searchQuery,
                    ),
                  );
                spans.add(
                  const TextSpan(
                    text: '[',
                    style: TextStyle(color: gruberQuartz),
                  ),
                );
                spans.add(
                  _GenericHighlighter.highlightSearchInText(
                    m.group(1)!,
                    const TextStyle(
                      color: gruberYellow,
                      decoration: TextDecoration.underline,
                    ),
                    searchQuery,
                  ),
                );
                spans.add(
                  const TextSpan(
                    text: ']',
                    style: TextStyle(color: gruberQuartz),
                  ),
                );
                spans.add(
                  const TextSpan(
                    text: '(',
                    style: TextStyle(color: gruberQuartz),
                  ),
                );
                spans.add(
                  TextSpan(
                    text: m.group(2),
                    style: const TextStyle(color: gruberWisteria, fontSize: 12),
                  ),
                );
                spans.add(
                  const TextSpan(
                    text: ')',
                    style: TextStyle(color: gruberQuartz),
                  ),
                );
                last = m.end;
              }
              if (last < parts[i].length)
                spans.add(
                  _GenericHighlighter.highlightSearchInText(
                    parts[i].substring(last),
                    const TextStyle(color: gruberFg),
                    searchQuery,
                  ),
                );
            }
          }
        }
      }
      lines.add(LineData(span: TextSpan(children: spans)));
    }
    return lines;
  }
}

class _Token {
  final String text;
  _Token(this.text);
}
