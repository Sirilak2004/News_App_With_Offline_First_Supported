// lib/services/news_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import '../models/article.dart';
import '../utils/constants.dart';
import 'offline_service.dart'; // Import

class NewsService {
  static const _baseUrl = 'https://newsapi.org/v2';
  final _offlineService = OfflineService();
  final Box _cacheBox = Hive.box('saved_articles');

  Future<List<Article>> fetchTopHeadlines({String country = 'us'}) async {
    try {
      // If offline, load from cache immediately
      if (!_offlineService.isOnline) {
        print('📴 Offline mode: Loading from cache');
        return _getCachedArticles();
      }

      final response = await http.get(
        Uri.parse(
            '$_baseUrl/top-headlines?country=$country&pageSize=20&apiKey=${Constants.newsApiKey}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'error') {
          throw Exception(data['message'] ?? 'API Error');
        }

        final List articlesJson = data['articles'] ?? [];

        final validArticles = articlesJson
            .where((json) =>
                json['title'] != '[Removed]' &&
                json['title'] != null &&
                json['title'].toString().isNotEmpty)
            .take(15)
            .map((json) => Article.fromJson(json))
            .toList();

        // Cache articles for offline use
        if (validArticles.isNotEmpty) {
          await _cacheArticles(validArticles);
        }

        return validArticles;
      } else if (response.statusCode == 429) {
        throw Exception('Daily API limit reached');
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ News API Error: $e');
      // Fallback to cached articles on error
      print('⚠️ Loading cached articles...');
      return _getCachedArticles();
    }
  }

  /// Cache articles to Hive
  Future<void> _cacheArticles(List<Article> articles) async {
    for (final article in articles) {
      await _cacheBox.put(article.id, article.toJson());
    }
    print('✅ Cached ${articles.length} articles');
  }

  /// Get cached articles
  Future<List<Article>> _getCachedArticles() async {
    final articles = _cacheBox.values.map((json) {
      return Article.fromJson(Map<String, dynamic>.from(json));
    }).toList();

    print('📂 Loaded ${articles.length} cached articles');
    return articles;
  }

  List<Article> _getMockArticles() {
    return [
      Article(
        id: '1',
        title: '🚀 Flutter 3.22 Released!',
        description: 'New features include improved performance.',
        content: 'Flutter 3.22 brings amazing updates...',
        imageUrl: 'https://flutter.dev/images/flutter-logo.png',
        source: 'Flutter Blog',
        publishedAt: DateTime.now(),
      ),
    ];
  }
}
