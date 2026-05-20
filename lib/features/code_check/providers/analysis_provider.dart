import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/analysis_service.dart';
import '../models/analysis_result.dart';
import '../../../core/network/api_client.dart';
import '../services/gemini_service.dart';
import '../services/groq_service.dart';

/// ----------------------------
/// SERVICE PROVIDERS
/// ----------------------------

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService(ref.watch(apiClientProvider));
});

final groqServiceProvider = Provider<GroqService>((ref) {
  return GroqService(ref.watch(apiClientProvider));
});

final analysisServiceProvider = Provider<AnalysisService>((ref) {
  return AnalysisService(
    geminiService: ref.watch(geminiServiceProvider),
    groqService: ref.watch(groqServiceProvider),
  );
});

/// ----------------------------
/// STATE
/// ----------------------------

class AnalysisState {
  final bool isLoading;
  final EnsembleResult? result;
  final String? error;

  const AnalysisState({
    this.isLoading = false,
    this.result,
    this.error,
  });

  AnalysisState copyWith({
    bool? isLoading,
    EnsembleResult? result,
    String? error,
  }) {
    return AnalysisState(
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      error: error,
    );
  }
}

/// ----------------------------
/// NOTIFIER
/// ----------------------------

class AnalysisNotifier extends StateNotifier<AnalysisState> {
  final AnalysisService _analysisService;

  AnalysisNotifier(this._analysisService) : super(const AnalysisState());

  Future<void> analyzeWithBoth(String code) async {
    if (code.trim().isEmpty) {
      state = state.copyWith(
        error: 'Please enter some code to analyze',
      );
      return;
    }

    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    try {
      final results = await _analysisService.analyzeWithBoth(code);

      final ensemble = EnsembleResult.fromResults(
        results['gemini'],
        results['groq'],
      );

      state = state.copyWith(
        isLoading: false,
        result: ensemble,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearResult() {
    state = const AnalysisState();
  }
}

/// ----------------------------
/// MAIN PROVIDER
/// ----------------------------

final analysisProvider =
    StateNotifierProvider<AnalysisNotifier, AnalysisState>((ref) {
  final service = ref.watch(analysisServiceProvider);
  return AnalysisNotifier(service);
});
