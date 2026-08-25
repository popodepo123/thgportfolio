import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ContributionService {
  static final Map<String, List<dynamic>> _recursiveTreeCache = {};

  static Future<Map<String, int>> fetchGitLab(
    String username, {
    http.Client? client,
    DateTime? now,
  }) async {
    final requestClient = client ?? http.Client();
    final referenceDate = now ?? DateTime.now();
    final after = DateTime(
      referenceDate.year,
      referenceDate.month,
      referenceDate.day,
    ).subtract(const Duration(days: 371));

    Uri eventsUri(int page) =>
        Uri.parse(
          'https://gitlab.com/api/v4/users/${Uri.encodeComponent(username)}/events',
        ).replace(
          queryParameters: {
            'after': _dateKey(after),
            'per_page': '100',
            'page': '$page',
          },
        );

    try {
      final firstResponse = await requestClient
          .get(eventsUri(1))
          .timeout(const Duration(seconds: 10));
      if (firstResponse.statusCode != 200) return {};

      final totalPages =
          int.tryParse(firstResponse.headers['x-total-pages'] ?? '') ?? 1;
      final responses = <http.Response>[firstResponse];
      if (totalPages > 1) {
        responses.addAll(
          await Future.wait(
            List.generate(totalPages - 1, (index) {
              return requestClient
                  .get(eventsUri(index + 2))
                  .timeout(const Duration(seconds: 10));
            }),
          ),
        );
      }

      final events = <Map<String, dynamic>>[];
      for (final response in responses) {
        if (response.statusCode != 200) continue;
        final decoded = jsonDecode(response.body);
        if (decoded is! List) continue;
        events.addAll(List<Map<String, dynamic>>.from(decoded));
      }
      return _aggregateGitLabEvents(events);
    } catch (_) {
      return {};
    } finally {
      if (client == null) requestClient.close();
    }
  }

  static Future<Map<String, int>> fetchGitHub(
    String username, {
    http.Client? client,
  }) async {
    final requestClient = client ?? http.Client();
    final url = Uri.parse(
      'https://github-contributions-api.jogruber.de/v4/${Uri.encodeComponent(username)}',
    ).replace(queryParameters: {'y': 'last'});
    try {
      final response = await requestClient
          .get(url)
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
    } catch (_) {
      return {};
    } finally {
      if (client == null) requestClient.close();
    }
  }

  static Map<String, int> _aggregateGitLabEvents(
    List<Map<String, dynamic>> events,
  ) {
    final pushedProjectDays = <String>{};
    for (final event in events) {
      if (event['push_data'] is! Map) continue;
      final date = _eventDate(event);
      final projectId = event['project_id'];
      if (date != null && projectId != null) {
        pushedProjectDays.add('$date:$projectId');
      }
    }

    final contributions = <String, int>{};
    for (final event in events) {
      final date = _eventDate(event);
      if (date == null) continue;

      final isDuplicateProjectCreation =
          event['action_name'] == 'created' &&
          event['target_type'] == 'Project' &&
          pushedProjectDays.contains('$date:${event['project_id']}');
      if (isDuplicateProjectCreation) continue;

      contributions[date] = (contributions[date] ?? 0) + 1;
    }
    return contributions;
  }

  static String? _eventDate(Map<String, dynamic> event) {
    final createdAt = event['created_at'];
    if (createdAt is! String || createdAt.length < 10) return null;
    final date = createdAt.substring(0, 10);
    return DateTime.tryParse(date) == null ? null : date;
  }

  static String _dateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  static String gitLabRawFileUrl(
    String repoUrl, {
    required String filePath,
    String branch = 'main',
  }) {
    final projectPath = _gitLabProjectPath(repoUrl);
    return 'https://gitlab.com/api/v4/projects/'
        '${Uri.encodeComponent(projectPath)}/repository/files/'
        '${Uri.encodeComponent(filePath)}/raw?ref=${Uri.encodeQueryComponent(branch)}';
  }

  static String _gitLabProjectPath(String repoUrl) {
    final path = Uri.parse(repoUrl).path;
    return path.split('/-/').first.replaceFirst(RegExp(r'^/'), '');
  }

  static Future<List<Map<String, dynamic>>> fetchTree(
    String repoUrl, {
    String branch = 'main',
    String path = '',
  }) async {
    try {
      final projectPath = _gitLabProjectPath(repoUrl);
      final encodedPath = Uri.encodeComponent(projectPath);
      final encodedSubPath = Uri.encodeComponent(path);
      final apiUrl =
          'https://gitlab.com/api/v4/projects/$encodedPath/repository/tree?recursive=false&per_page=100&ref=$branch&path=$encodedSubPath';
      final response = await http
          .get(Uri.parse(apiUrl))
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
    final rawUrl = gitLabRawFileUrl(
      repoUrl,
      filePath: filePath,
      branch: branch,
    );
    try {
      final response = await http
          .get(Uri.parse(rawUrl))
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
      final projectPath = _gitLabProjectPath(repoUrl);
      final encodedPath = Uri.encodeComponent(projectPath);

      for (int page = 1; page <= 5; page++) {
        final apiUrl =
            'https://gitlab.com/api/v4/projects/$encodedPath/repository/tree?recursive=true&per_page=100&page=$page&ref=$branch';
        try {
          final response = await http
              .get(Uri.parse(apiUrl))
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
