import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ContributionService {
  static String wrapUrl(String url) =>
      kIsWeb ? 'https://corsproxy.io/?${Uri.encodeComponent(url)}' : url;

  static final Map<String, List<dynamic>> _recursiveTreeCache = {};

  static Future<Map<String, int>> fetchGitLab(String username) async {
    final url = 'https://gitlab.com/users/$username/calendar.json';
    try {
      final response = await http
          .get(Uri.parse(wrapUrl(url)))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data.map((key, value) => MapEntry(key, value as int));
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  static Future<Map<String, int>> fetchGitHub(String username) async {
    final url = 'https://github-contributions-api.jogruber.de/v4/$username';
    try {
      final response = await http
          .get(Uri.parse(wrapUrl(url)))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> contributions = data['contributions'];
        final Map<String, int> result = {};
        for (var entry in contributions) {
          result[entry['date']] = entry['count'] as int;
        }
        return result;
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  static Future<List<Map<String, dynamic>>> fetchTree(
    String repoUrl, {
    String branch = 'main',
    String path = '',
  }) async {
    try {
      final projectPath = Uri.parse(repoUrl).path.replaceFirst('/', '');
      final encodedPath = Uri.encodeComponent(projectPath);
      final encodedSubPath = Uri.encodeComponent(path);
      final apiUrl =
          'https://gitlab.com/api/v4/projects/$encodedPath/repository/tree?recursive=false&per_page=100&ref=$branch&path=$encodedSubPath';
      final response = await http
          .get(Uri.parse(wrapUrl(apiUrl)))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<String?> fetchRawFile(
    String repoUrl, {
    String filePath = 'README.md',
    String branch = 'main',
  }) async {
    final rawUrl = '$repoUrl/-/raw/$branch/$filePath';
    try {
      final response = await http
          .get(Uri.parse(wrapUrl(rawUrl)))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) return response.body;
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<SymbolMatch?> searchSymbol(
    String repoUrl,
    String symbol, {
    String branch = 'main',
    String? currentFilePath,
  }) async {
    if (!_recursiveTreeCache.containsKey(repoUrl)) {
      debugPrint('JTD: Initializing project tree cache...');
      final List<dynamic> fullTree = [];
      final projectPath = Uri.parse(repoUrl).path.replaceFirst('/', '');
      final encodedPath = Uri.encodeComponent(projectPath);

      for (int page = 1; page <= 5; page++) {
        final apiUrl =
            'https://gitlab.com/api/v4/projects/$encodedPath/repository/tree?recursive=true&per_page=100&page=$page&ref=$branch';
        try {
          final response = await http
              .get(Uri.parse(wrapUrl(apiUrl)))
              .timeout(const Duration(seconds: 10));
          if (response.statusCode == 200) {
            final List<dynamic> results = jsonDecode(response.body);
            if (results.isEmpty) break;
            fullTree.addAll(results);
            if (results.length < 100) break;
          } else if (response.statusCode == 404 && branch == 'main') {
            return searchSymbol(
              repoUrl,
              symbol,
              branch: 'master',
              currentFilePath: currentFilePath,
            );
          } else {
            break;
          }
        } catch (e) {
          break;
        }
      }
      _recursiveTreeCache[repoUrl] = fullTree;
    }

    final tree = _recursiveTreeCache[repoUrl] ?? [];
    if (tree.isEmpty) return null;
    final snakeSymbol = symbol
        .replaceAllMapped(
          RegExp(r'([a-z0-9])([A-Z])'),
          (m) => '${m.group(1)}_${m.group(2)}',
        )
        .toLowerCase();

    final targetFile = '$snakeSymbol.dart';
    final fuzzySymbol = symbol.toLowerCase();
    final currentDir = currentFilePath != null && currentFilePath.contains('/')
        ? currentFilePath.substring(0, currentFilePath.lastIndexOf('/'))
        : null;

    List<_Candidate> candidates = [];

    for (var node in tree) {
      if (node['type'] != 'blob' ||
          !(node['path'] as String).endsWith('.dart')) {
        continue;
      }
      final String path = node['path'] as String;
      final String fileName = path.split('/').last.toLowerCase();
      int score = 0;
      if (fileName == targetFile) score += 100;
      final components = [
        'notifier',
        'state',
        'provider',
        'repository',
        'entity',
        'model',
        'view',
        'controller',
      ];
      for (var comp in components) {
        if (fuzzySymbol.contains(comp) && fileName.contains(comp)) {
          score += 40;
          if (fuzzySymbol.endsWith(comp) && fileName.contains(comp)) {
            score += 20;
          }
        }
      }
      if (currentDir != null && path.startsWith(currentDir)) {
        score += 30;
      }
      if (fileName
          .replaceAll('_', '')
          .contains(fuzzySymbol.replaceAll('_', ''))) {
        score += 10;
      }
      if (score > 0) {
        candidates.add(_Candidate(path: path, score: score));
      }
    }

    candidates.sort((a, b) => b.score.compareTo(a.score));
    final topCandidates = candidates.take(3).toList();

    debugPrint(
      'JTD: Verifying top ${topCandidates.length} candidates for definition...',
    );

    for (var candidate in topCandidates) {
      final content = await fetchRawFile(
        repoUrl,
        filePath: candidate.path,
        branch: branch,
      );
      if (content != null) {
        final lines = content.split('\n');
        final patterns = [
          'class $symbol',
          'abstract class $symbol',
          'mixin $symbol',
          'extension $symbol',
          'enum $symbol',
          'typedef $symbol',
        ];

        for (int i = 0; i < lines.length; i++) {
          final line = lines[i];
          for (var p in patterns) {
            if (line.contains(p)) {
              debugPrint(
                'JTD: CONFIRMED in ${candidate.path} at line ${i + 1}',
              );
              return SymbolMatch(path: candidate.path, lineIndex: i);
            }
          }
        }
      }
    }

    if (topCandidates.isNotEmpty && topCandidates.first.score >= 100) {
      return SymbolMatch(path: topCandidates.first.path, lineIndex: 0);
    }

    return null;
  }
}

class SymbolMatch {
  final String path;
  final int lineIndex;
  SymbolMatch({required this.path, required this.lineIndex});
}

class _Candidate {
  final String path;
  final int score;
  _Candidate({required this.path, required this.score});
}
