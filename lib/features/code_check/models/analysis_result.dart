class AnalysisResult {
  final String apiName;
  final double probability;
  final String label;
  final String explanation;
  final bool success;
  final String? error;

  const AnalysisResult({
    required this.apiName,
    required this.probability,
    required this.label,
    required this.explanation,
    required this.success,
    this.error,
  });

  /// Failure constructor
  factory AnalysisResult.failure(String apiName, String errorMessage) {
    return AnalysisResult(
      apiName: apiName,
      probability: 0.0,
      label: 'Error',
      explanation: '',
      success: false,
      error: errorMessage,
    );
  }

  /// Safe JSON parsing (VERY IMPORTANT)
  factory AnalysisResult.fromJson(
    String apiName,
    Map<String, dynamic> json,
  ) {
    return AnalysisResult(
      apiName: apiName,
      probability: (json['probability'] ?? 0).toDouble(),
      label: json['label']?.toString() ?? 'Unknown',
      explanation: json['explanation']?.toString() ?? 'No explanation',
      success: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'apiName': apiName,
      'probability': probability,
      'label': label,
      'explanation': explanation,
      'success': success,
      'error': error,
    };
  }
}

class EnsembleResult {
  final AnalysisResult? geminiResult;
  final AnalysisResult? groqResult;
  final double averageProbability;
  final String verdict;
  final String confidence;
  final String? recommendation;
  final bool bothSuccess;

  const EnsembleResult({
    this.geminiResult,
    this.groqResult,
    required this.averageProbability,
    required this.verdict,
    required this.confidence,
    this.recommendation,
    required this.bothSuccess,
  });

  factory EnsembleResult.fromResults(
    AnalysisResult? gemini,
    AnalysisResult? groq,
  ) {
    final geminiOk = gemini?.success == true;
    final groqOk = groq?.success == true;
    final successfulGemini = geminiOk ? gemini : null;
    final successfulGroq = groqOk ? groq : null;

    final anySuccess = geminiOk || groqOk;
    final bothSuccess = geminiOk && groqOk;

    if (!anySuccess) {
      return const EnsembleResult(
        averageProbability: 0,
        verdict: 'Analysis Failed',
        confidence: 'Low',
        recommendation: 'We could not reach the AI services. Please check your internet connection and try again in a moment.',
        bothSuccess: false,
      );
    }

    double total = 0;
    int count = 0;

    if (geminiOk) {
      total += gemini!.probability;
      count++;
    }

    if (groqOk) {
      total += groq!.probability;
      count++;
    }

    final avg = total / count;

    double diff = 0;
    if (bothSuccess) {
      diff = (gemini!.probability - groq!.probability).abs();
    }

    String confidence;
    String verdict;
    String? recommendation;

    if (bothSuccess && diff < 20) {
      confidence = 'High';
      verdict = avg > 50 ? 'AI-generated' : 'Human-written';
    } else if (bothSuccess && diff < 50) {
      confidence = 'Medium';
      verdict = avg > 50 ? 'Likely AI-generated' : 'Likely Human-written';
      recommendation = 'Moderate disagreement between models';
    } else if (bothSuccess) {
      confidence = 'Low';
      verdict = 'Uncertain';
      recommendation = 'Models disagree significantly';
    } else {
      confidence = 'Medium';
      verdict = avg > 50 ? 'Probably AI-generated' : 'Probably Human-written';
      recommendation = successfulGemini != null
          ? 'Analysis completed using Gemini only.'
          : 'Analysis completed using Groq only.';
    }

    return EnsembleResult(
      geminiResult: successfulGemini,
      groqResult: successfulGroq,
      averageProbability: avg,
      verdict: verdict,
      confidence: confidence,
      recommendation: recommendation,
      bothSuccess: bothSuccess,
    );
  }
}
