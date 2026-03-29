// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/article.dart';
import '../services/news_service.dart';
import '../services/offline_service.dart'; // Import
import '../widgets/article_card.dart';
import '../widgets/loading_indicator.dart';
import 'detail_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(bool)? onThemeChanged;
  const HomeScreen({super.key, this.onThemeChanged});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _newsService = NewsService();
  final _offlineService = OfflineService(); // Add offline service
  List<Article> _articles = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _loadNews();
  }

  void _checkConnectivity() {
    _isOnline = _offlineService.isOnline;

    // Listen for connectivity changes
    _offlineService.onConnectivityChanged.listen((isOnline) {
      setState(() => _isOnline = isOnline);

      if (!isOnline) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📴 You are offline. Showing cached news.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
        _loadNews(); // Reload from cache
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📶 Back online!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  Future<void> _loadNews() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final articles = await _newsService.fetchTopHeadlines();
      setState(() {
        _articles = articles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trending News'),
        actions: [
          // ✅ Offline/Online Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: _isOnline ? Colors.green : Colors.orange,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isOnline ? Icons.wifi : Icons.wifi_off,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  _isOnline ? 'Online' : 'Offline',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ).animate().scale(),

          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      SettingsScreen(onThemeChanged: widget.onThemeChanged)),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadNews,
        child: _isLoading
            ? const LoadingIndicator()
            : _errorMessage != null
                ? _buildErrorWidget()
                : _articles.isEmpty
                    ? _buildEmptyWidget()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _articles.length,
                        itemBuilder: (context, index) {
                          final article = _articles[index];
                          return ArticleCard(
                            article: article,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      DetailScreen(article: article)),
                            ),
                          ).animate().fadeIn(
                              delay: Duration(milliseconds: index * 100));
                        },
                      ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadNews,
        child: const Icon(Icons.refresh),
      ).animate().scale(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isOnline ? Icons.error_outline : Icons.wifi_off,
              size: 64,
              color: _isOnline ? Colors.red : Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              _isOnline ? 'Failed to load news' : 'You are offline',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _isOnline ? _errorMessage! : 'Showing cached articles',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadNews,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.newspaper, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No articles found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _isOnline
                ? 'Check your internet connection or API key'
                : 'No cached articles available',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _offlineService.dispose();
    super.dispose();
  }
}
