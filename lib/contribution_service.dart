import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ContributionService {
  static String wrapUrl(String url) => kIsWeb ? 'https://corsproxy.io/?${Uri.encodeComponent(url)}' : url;

  static Future<Map<String, int>> fetchGitLab(String username) async {
    final url = 'https://gitlab.com/users/$username/calendar.json';
    try {
      final response = await http.get(Uri.parse(wrapUrl(url))).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data.map((key, value) => MapEntry(key, value as int));
      }
      return {};
    } catch (e) {
      debugPrint('GitLab fetch error: $e');
      return {};
    }
  }

  static Future<Map<String, int>> fetchGitHub(String username) async {
    // Using the reliable jogruber API for public github data
    final url = 'https://github-contributions-api.jogruber.de/v4/$username';
    try {
      final response = await http.get(Uri.parse(wrapUrl(url))).timeout(const Duration(seconds: 10));
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
      debugPrint('GitHub fetch error: $e');
      return {};
    }
  }

  // Common GitLab File Fetching methods (moved from GitLabService)
  static Future<List<Map<String, dynamic>>> fetchTree(String repoUrl, {String branch = 'main', String path = ''}) async {
    try {
      final projectPath = Uri.parse(repoUrl).path.replaceFirst('/', '');
      final encodedPath = Uri.encodeComponent(projectPath);
      final encodedSubPath = Uri.encodeComponent(path);
      final apiUrl = 'https://gitlab.com/api/v4/projects/$encodedPath/repository/tree?recursive=false&per_page=100&ref=$branch&path=$encodedSubPath';
      final response = await http.get(Uri.parse(wrapUrl(apiUrl))).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
      return [];
    } catch (e) { return []; }
  }

  static Future<String> fetchRawFile(String repoUrl, {String filePath = 'README.md', String branch = 'main'}) async {
    final rawUrl = '$repoUrl/-/raw/$branch/$filePath';
    try {
      final response = await http.get(Uri.parse(wrapUrl(rawUrl))).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) return response.body;
      return 'Error: Failed to fetch file';
    } catch (e) { return 'Error: $e'; }
  }
}
