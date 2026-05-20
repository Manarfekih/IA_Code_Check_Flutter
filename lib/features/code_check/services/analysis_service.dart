import 'package:flutter/foundation.dart';

import 'gemini_service.dart';
import 'groq_service.dart';
import '../models/analysis_result.dart';

class AnalysisService {
  final GeminiService _geminiService;
  final GroqService _groqService;

  AnalysisService({
    required GeminiService geminiService,
    required GroqService groqService,
  })  : _geminiService = geminiService,
        _groqService = groqService;

  Future<Map<String, AnalysisResult>> analyzeWithBoth(String code) async {
    if (kDebugMode) {
      print('📊 Starting parallel analysis (Gemini + Groq)');
    }

    final results = await Future.wait([
      _geminiService.analyzeCode(code),
      _groqService.analyzeCode(code),
    ]);

    final gemini = results[0];
    final groq = results[1];

    if (kDebugMode) {
      print(' Gemini success: ${gemini.success}');
      print('Groq success: ${groq.success}');
    }

    return {
      'gemini': gemini,
      'groq': groq,
    };
  }

  Future<AnalysisResult> analyzeWithFallback(String code) async {
    if (kDebugMode) {
      print('🔄 Trying Gemini first...');
    }

    final gemini = await _geminiService.analyzeCode(code);

    if (gemini.success) {
      if (kDebugMode) {
        print('✅ Gemini succeeded');
      }
      return gemini;
    }

    if (kDebugMode) {
      print('⚠️ Gemini failed: ${gemini.error}');
      print('🔄 Falling back to Groq...');
    }

    final groq = await _groqService.analyzeCode(code);

    if (groq.success) {
      if (kDebugMode) {
        print('✅ Groq succeeded as fallback');
      }
      return groq;
    }

    if (kDebugMode) {
      print('❌ Both APIs failed');
    }

    return AnalysisResult.failure(
      'Both APIs',
      'Gemini: ${gemini.error}\nGroq: ${groq.error}',
    );
  }
}