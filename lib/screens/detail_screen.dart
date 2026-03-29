// lib/screens/detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/article.dart';
import '../services/gemini_service.dart';
import '../widgets/loading_indicator.dart';

class DetailScreen extends StatefulWidget {
  final Article article;
  const DetailScreen({super.key, required this.article});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final _gemini = GeminiService();
  String? _summary;
  String? _virality;
  bool _isSummarizing = false;

  Future<void> _generateSummary() async {
    setState(() => _isSummarizing = true);

    final content = widget.article.content.isNotEmpty
        ? widget.article.content
        : widget.article.description;

    final summary = await _gemini.summarize(content);
    final virality = await _gemini.getViralityScore(
      widget.article.title,
      content,
    );

    setState(() {
      _summary = summary;
      _virality = virality;
      _isSummarizing = false;
      widget.article.aiSummary = summary;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final summaryTextColor = isDark ? Colors.grey[100]! : Colors.black87;
    final metaTextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.article.source),
        backgroundColor: isDark ? const Color(0xFF1E293B) : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share feature coming soon!')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HERO ANIMATION: Image from list card
            if (widget.article.imageUrl != null)
              Hero(
                tag:
                    'article-image-${widget.article.id}', // Same tag as article_card.dart
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: widget.article.imageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      height: 200,
                      color: Colors.grey[800],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      height: 200,
                      color: Colors.grey[800],
                      child: const Icon(Icons.image_not_supported,
                          size: 40, color: Colors.grey),
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 600.ms),

            const SizedBox(height: 20),

            // Article Title
            Text(
              widget.article.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.3,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ).animate().slideX(delay: 200.ms),

            const SizedBox(height: 12),

            // Meta Info
            Row(
              children: [
                Chip(
                  label: Text(widget.article.source),
                  backgroundColor:
                      Theme.of(context).primaryColor.withOpacity(0.2),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.article.timeAgo,
                  style: TextStyle(
                    fontSize: 12,
                    color: metaTextColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // AI Summary Card with ANIMATEDOPACITY (Implicit Animation)
            Card(
              color: cardColor,
              elevation: 4,
              shadowColor: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(isDark ? 0.3 : 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: Colors.amber,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'AI Summary',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        if (_virality != null && !_isSummarizing)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _virality!,
                              style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ).animate().scale(delay: 300.ms),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ✅ IMPLICIT ANIMATION: AnimatedOpacity for summary
                    if (_isSummarizing)
                      const LoadingIndicator(mini: true)
                    else if (_summary != null)
                      AnimatedOpacity(
                        opacity: 1.0,
                        duration: const Duration(
                            milliseconds: 600), // Implicit animation
                        curve: Curves.easeInOut,
                        child: Text(
                          _summary!,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: summaryTextColor,
                          ),
                        ),
                      )
                    else
                      AnimatedOpacity(
                        opacity: 1.0,
                        duration: const Duration(milliseconds: 400),
                        child: Column(
                          children: [
                            Text(
                              'Get a quick AI-powered summary of this article.',
                              style: TextStyle(
                                fontSize: 14,
                                color: metaTextColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _generateSummary,
                                icon: const Icon(Icons.auto_awesome, size: 20),
                                label: const Text('Generate AI Summary'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 400.ms),

            const SizedBox(height: 40),
          ],
        ),
      ),

      // Bottom Action Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(
                widget.article.isSaved ? Icons.bookmark : Icons.bookmark_border,
                color: widget.article.isSaved
                    ? Colors.amber
                    : (isDark ? Colors.grey[400] : null),
              ),
              onPressed: () {
                setState(() {
                  widget.article.isSaved = !widget.article.isSaved;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      widget.article.isSaved
                          ? '✓ Saved to reading list'
                          : '✗ Removed from reading list',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.share, color: isDark ? Colors.grey[400] : null),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Share feature coming soon!')),
                );
              },
            ),
            if (_summary != null)
              IconButton(
                icon: Icon(Icons.refresh,
                    color: isDark ? Colors.grey[400] : null),
                onPressed: () {
                  setState(() {
                    _summary = null;
                    _virality = null;
                  });
                  _generateSummary();
                },
                tooltip: 'Regenerate summary',
              ),
          ],
        ),
      ),
    );
  }
}
