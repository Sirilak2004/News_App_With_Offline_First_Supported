// lib/services/offline_service.dart

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/article.dart';

class OfflineService {
  static final OfflineService _instance = OfflineService._internal();
  factory OfflineService() => _instance;
  OfflineService._internal();

  final Connectivity _connectivity = Connectivity();
  late Box _articlesBox;
  late Box _aiCacheBox;
  
  StreamSubscription<ConnectivityResult>? _connectivitySubscription; // ✅ Single result, not List
  bool _isOnline = true;
  final _onlineController = StreamController<bool>.broadcast();

  /// Stream to listen for online/offline changes
  Stream<bool> get onConnectivityChanged => _onlineController.stream;
  bool get isOnline => _isOnline;

  /// Initialize Hive boxes and connectivity
  Future<void> init() async {
    _articlesBox = Hive.box('saved_articles');
    _aiCacheBox = Hive.box('ai_cache');
    
    // Listen for connectivity changes (FIXED: single result)
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (ConnectivityResult result) {  // Changed from List<ConnectivityResult>
        final wasOnline = _isOnline;
        _isOnline = result != ConnectivityResult.none;  // Simplified check
        
        if (wasOnline != _isOnline) {
          _onlineController.add(_isOnline);
        }
      },
    );
    
    // Check initial connection
    final result = await _connectivity.checkConnectivity();
    _isOnline = result != ConnectivityResult.none;  // ✅ Single result check
  }

  /// Save article for offline reading
  Future<void> saveArticle(Article article) async {
    await _articlesBox.put(article.id, article.toJson());
  }

  /// Get all saved articles
  Future<List<Article>> getSavedArticles() async {
    final articles = _articlesBox.values.map((json) {
      return Article.fromJson(Map<String, dynamic>.from(json));
    }).toList();
    return articles;
  }

  /// Check if article is saved
  bool isArticleSaved(String id) {
    return _articlesBox.containsKey(id);
  }

  /// Remove saved article
  Future<void> removeArticle(String id) async {
    await _articlesBox.delete(id);
  }

  /// Cache AI summary
  Future<void> cacheAISummary(String articleId, String summary) async {
    await _aiCacheBox.put('summary_$articleId', summary);
  }

  /// Get cached AI summary
  String? getCachedAISummary(String articleId) {
    return _aiCacheBox.get('summary_$articleId');
  }

  /// Clear all cache
  Future<void> clearCache() async {
    await _aiCacheBox.clear();
  }

  /// Get cache size
  int getCacheSize() {
    return _aiCacheBox.length;
  }

  /// Cleanup
  void dispose() {
    _connectivitySubscription?.cancel();
    _onlineController.close();
  }
}