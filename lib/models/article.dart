// lib/models/article.dart

class Article {
  final String id;
  final String title;
  final String description;
  final String content;
  final String? imageUrl;
  final String source;
  final String? author;
  final DateTime publishedAt;
  final String? url;
  String? aiSummary;
  String? viralityScore;
  bool isSaved;

  Article({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    this.imageUrl,
    required this.source,
    this.author,
    required this.publishedAt,
    this.url,
    this.aiSummary,
    this.viralityScore,
    this.isSaved = false,
  });

  /// Parse JSON from NewsAPI.org or GNews
  factory Article.fromJson(Map<String, dynamic> json) {
    // Handle source: could be String or Map {'name': '...'}
    final sourceData = json['source'];
    final sourceName = sourceData is Map
        ? (sourceData['name'] ?? 'Unknown')
        : (sourceData ?? 'Unknown');

    // Get content (prefer 'content', fallback to 'description')
    String content = json['content'] ?? json['description'] ?? '';

    // Skip [Removed] articles
    final title = json['title'] ?? 'No Title';
    if (title.toString() == '[Removed]') {
      throw Exception('Article removed');
    }

    // Parse published date safely
    DateTime publishedAt;
    try {
      publishedAt = DateTime.parse(
          json['publishedAt'] ?? DateTime.now().toIso8601String());
    } catch (_) {
      publishedAt = DateTime.now();
    }

    return Article(
      id: json['id'] ??
          json['url'] ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.toString().trim(),
      description: (json['description'] ?? '').toString().trim(),
      content: content.toString().trim(),
      imageUrl: _validateImageUrl(json['urlToImage'] ?? json['image']),
      source: sourceName.toString().trim(),
      author: json['author']?.toString().trim(),
      publishedAt: publishedAt,
      url: json['url'],
      aiSummary: json['aiSummary'],
      isSaved: json['isSaved'] ?? false,
    );
  }

  /// Convert to JSON for local storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'urlToImage': imageUrl,
      'source': source,
      'author': author,
      'publishedAt': publishedAt.toIso8601String(),
      'url': url,
      'aiSummary': aiSummary,
      'viralityScore': viralityScore,
      'isSaved': isSaved,
    };
  }

  /// Validate image URL
  static String? _validateImageUrl(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    final lowerUrl = url.toLowerCase();
    if (lowerUrl.contains('placeholder') ||
        lowerUrl.contains('default') ||
        lowerUrl.endsWith('.svg')) {
      return null;
    }
    return url.trim();
  }

  /// Get readable publish time (e.g., "2h ago")
  String get timeAgo {
    final diff = DateTime.now().difference(publishedAt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${publishedAt.day}/${publishedAt.month}/${publishedAt.year}';
  }

  /// Get content preview (first 200 chars)
  String get contentPreview {
    final text = content.isNotEmpty ? content : description;
    if (text.length <= 200) return text;
    return '${text.substring(0, 200)}...';
  }

  /// Generate unique hash for caching
  String get hash {
    return '${title.hashCode}-${publishedAt.millisecondsSinceEpoch}';
  }

  /// Copy with new values (for updates)
  Article copyWith({
    String? id,
    String? title,
    String? description,
    String? content,
    String? imageUrl,
    String? source,
    String? author,
    DateTime? publishedAt,
    String? url,
    String? aiSummary,
    String? viralityScore,
    bool? isSaved,
  }) {
    return Article(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      source: source ?? this.source,
      author: author ?? this.author,
      publishedAt: publishedAt ?? this.publishedAt,
      url: url ?? this.url,
      aiSummary: aiSummary ?? this.aiSummary,
      viralityScore: viralityScore ?? this.viralityScore,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  /// 🔍 Search matching
  bool matchesQuery(String query) {
    final lowerQuery = query.toLowerCase();
    return title.toLowerCase().contains(lowerQuery) ||
        description.toLowerCase().contains(lowerQuery) ||
        content.toLowerCase().contains(lowerQuery) ||
        source.toLowerCase().contains(lowerQuery);
  }

  @override
  String toString() {
    return 'Article(id: $id, title: $title, source: $source, published: $timeAgo)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Article && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
