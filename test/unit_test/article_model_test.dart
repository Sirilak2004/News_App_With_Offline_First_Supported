// test/unit_test/article_model_test.dart

import 'package:flutter_test/flutter_test.dart';
// ✅ Use relative import (adjust path if needed)
import '../../lib/models/article.dart';

void main() {
  group('Article Model Tests', () {
    test('Article.fromJson should parse valid JSON', () {
      // Arrange
      final json = {
        'id': '123',
        'title': 'Test Article',
        'description': 'Test description',
        'content': 'Test content',
        'urlToImage': 'https://example.com/image.jpg',
        'source': {'name': 'Test Source'},
        'publishedAt': '2024-01-15T10:30:00Z',
      };

      // Act
      final article = Article.fromJson(json);

      // Assert
      expect(article.id, '123');
      expect(article.title, 'Test Article');
      expect(article.source, 'Test Source');
      expect(article.imageUrl, 'https://example.com/image.jpg');
    });

    test('Article.fromJson should handle missing fields', () {
      // Arrange
      final json = {
        'title': 'Test Article',
        'description': '',
        'content': '',
        'source': 'Unknown',
        'publishedAt': '',
      };

      // Act
      final article = Article.fromJson(json);

      // Assert
      expect(article.title, 'Test Article');
      expect(article.source, 'Unknown');
      expect(article.imageUrl, isNull);
    });

    test('Article.timeAgo should return formatted string', () {
      // Arrange
      final article = Article(
        id: '1',
        title: 'Test',
        description: 'Test',
        content: 'Test',
        source: 'Test',
        publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
      );

      // Act
      final timeAgo = article.timeAgo;

      // Assert
      expect(timeAgo, contains('h ago'));
    });

    test('Article.copyWith should create new instance with updated values', () {
      // Arrange
      final original = Article(
        id: '1',
        title: 'Original',
        description: 'Test',
        content: 'Test',
        source: 'Test',
        publishedAt: DateTime.now(),
      );

      // Act
      final updated = original.copyWith(
        title: 'Updated',
        aiSummary: 'AI Summary',
      );

      // Assert
      expect(updated.title, 'Updated');
      expect(updated.aiSummary, 'AI Summary');
      expect(updated.id, original.id);
    });

    test('Article.matchesQuery should search correctly', () {
      // Arrange
      final article = Article(
        id: '1',
        title: 'Flutter News',
        description: 'About Flutter development',
        content: 'Test content',
        source: 'Tech Blog',
        publishedAt: DateTime.now(),
      );

      // Act & Assert
      expect(article.matchesQuery('flutter'), isTrue);
      expect(article.matchesQuery('Flutter'), isTrue);
      expect(article.matchesQuery('news'), isTrue);
      expect(article.matchesQuery('python'), isFalse);
    });
  });
}
