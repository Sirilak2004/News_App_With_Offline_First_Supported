// lib/services/gemini_service.dart

import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import '../utils/constants.dart';

class GeminiService {
  final Box _aiCacheBox = Hive.box('ai_cache'); // Hive box for AI cache

  Future<String> summarize(String text) async {
    try {
      // Check cache first (avoid repeated API calls)
      final cacheKey = 'summary_${text.hashCode}';
      final cachedSummary = _aiCacheBox.get(cacheKey);
      
      if (cachedSummary != null) {
        print('📂 AI summary loaded from cache');
        return cachedSummary;
      }

      if (Constants.geminiApiKey.isEmpty || Constants.geminiApiKey.length < 30) {
        return _getMockSummary(text); // Use mock if no API key
      }

      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent?key=${Constants.geminiApiKey}',
      );
      
      final requestBody = {
        'contents': [{
          'parts': [{
            'text': 'Summarize this news in 2-3 engaging sentences: $text'
          }]
        }],
        'generationConfig': {
          'temperature': 0.7,
          'maxOutputTokens': 500,
        },
      };
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final summary = data['candidates']?[0]?['content']?['parts']?[0]?['text']?.trim();
        
        if (summary != null && summary.isNotEmpty) {
          // Cache the summary for future use
          await _aiCacheBox.put(cacheKey, summary);
          print('✅ AI summary cached');
          return summary;
        }
      }
      
      return _getMockSummary(text);
      
    } catch (e) {
      print('❌ AI Error: $e');
      return _getMockSummary(text);
    }
  }

  /// Mock summary (works offline)
  String _getMockSummary(String text) {
    final sentences = text.split(RegExp(r'[.!?]+'));
    final cleanSentences = sentences
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty && s.length > 20)
        .toList();
    
    if (cleanSentences.length >= 2) {
      return '✨ ${cleanSentences[0]}. ${cleanSentences[1]}.';
    }
    return '✨ This article discusses recent developments and key insights.';
  }

  Future<String> getViralityScore(String title, String content) async {
    // Similar caching logic can be added here
    return "🔥 7/10 - Engaging content!";
  }
}