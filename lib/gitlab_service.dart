import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class GitLabService {
  // corsproxy.io is generally more permissive for localhost origin
  static String _wrapUrl(String url) => kIsWeb ? 'https://corsproxy.io/?${Uri.encodeComponent(url)}' : url;

  static Future<List<Map<String, dynamic>>> fetchTree(String repoUrl, {String branch = 'main', String path = ''}) async {
    try {
      final projectPath = Uri.parse(repoUrl).path.replaceFirst('/', '');
      final encodedPath = Uri.encodeComponent(projectPath);
      final encodedSubPath = Uri.encodeComponent(path);
      
      final apiUrl = 'https://gitlab.com/api/v4/projects/$encodedPath/repository/tree?recursive=false&per_page=100&ref=$branch&path=$encodedSubPath';
      
      final response = await http.get(Uri.parse(_wrapUrl(apiUrl))).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final List<dynamic> tree = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(tree);
      } else if (response.statusCode == 404 && branch == 'main' && path.isEmpty) {
        return fetchTree(repoUrl, branch: 'master', path: path);
      }
      return [];
    } catch (e) {
      debugPrint('GitLab fetchTree error: $e');
      return [];
    }
  }

  static Future<String> fetchRawFile(String repoUrl, {String filePath = 'README.md', String branch = 'main'}) async {
    final String rawUrl = '$repoUrl/-/raw/$branch/$filePath';
    
    try {
      final response = await http.get(Uri.parse(_wrapUrl(rawUrl))).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return response.body;
      } else if (response.statusCode == 404 && branch == 'main') {
        return fetchRawFile(repoUrl, filePath: filePath, branch: 'master');
      } else {
        return 'Error: Failed to fetch file (HTTP ${response.statusCode})';
      }
    } catch (e) {
      return 'Error: Could not connect to GitLab ($e)';
    }
  }
}
