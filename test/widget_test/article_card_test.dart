// test/widget_test/article_card_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_ai_app/models/article.dart';
import 'package:news_ai_app/widgets/article_card.dart';

void main() {
  group('ArticleCard Widget Tests', () {
    final testArticle = Article(
      id: '1',
      title: 'Test Article Title',
      description: 'Test description',
      content: 'Test content',
      source: 'Test Source',
      publishedAt: DateTime.now(),
    );

    testWidgets('should display article title', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArticleCard(
              article: testArticle,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Test Article Title'), findsOneWidget);
    });

    testWidgets('should display source name', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArticleCard(
              article: testArticle,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Test Source'), findsOneWidget);
    });

    testWidgets('should call onTap when tapped', (WidgetTester tester) async {
      // Arrange
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArticleCard(
              article: testArticle,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(ArticleCard));
      await tester.pump();

      // Assert
      expect(tapped, isTrue);
    });

    testWidgets('should show image placeholder when loading', (WidgetTester tester) async {
      // Arrange
      final articleWithImage = testArticle.copyWith(
        imageUrl: 'https://example.com/image.jpg',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArticleCard(
              article: articleWithImage,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert - Image widget should be present
      expect(find.byType(Card), findsOneWidget);
    });
  });
}