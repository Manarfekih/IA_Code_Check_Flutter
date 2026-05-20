import 'package:flutter/material.dart';
import '../models/analysis_result.dart';
import '../../../core/theme/app_theme.dart';
import 'probability_chart.dart';

class EnsembleResultCard extends StatelessWidget {
  final EnsembleResult result;

  const EnsembleResultCard({super.key, required this.result});

  Color _color(double p) {
    if (p >= 70) return AppTheme.errorColor;
    if (p >= 40) return AppTheme.warningColor;
    return AppTheme.successColor;
  }

  @override
  Widget build(BuildContext context) {
    final prob = result.averageProbability.clamp(0, 100).toDouble();
    final verdictColor = _color(prob);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Card(
        key: ValueKey(prob),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: verdictColor.withOpacity(0.35), width: 1),
        ),
        color: verdictColor.withOpacity(0.04),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ── Title ──────────────────────────────────────
              Text(
                'Ensemble Analysis',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                result.bothSuccess
                    ? 'Combined result from Gemini + Groq'
                    : 'Result from available model',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),

              const SizedBox(height: 24),

              // ── Gauge chart ────────────────────────────────
              ProbabilityChart(
                probability: prob,
                geminiProbability:
                    result.geminiResult?.probability.clamp(0, 100).toDouble() ??
                        0,
                groqProbability:
                    result.groqResult?.probability.clamp(0, 100).toDouble() ??
                        0,
                bothSuccess: result.bothSuccess,
              ),

              const SizedBox(height: 24),

              // ── Verdict badge ──────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: verdictColor.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color: verdictColor.withOpacity(0.3)),
                ),
                child: Text(
                  result.verdict,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: verdictColor,
                      ),
                ),
              ),

              const SizedBox(height: 10),

              // ── Confidence pill ───────────────────────────
              _ConfidencePill(confidence: result.confidence),

              // ── Recommendation ────────────────────────────
              if (result.recommendation != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .dividerColor
                        .withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    result.recommendation!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          height: 1.5,
                        ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfidencePill extends StatelessWidget {
  final String confidence;
  const _ConfidencePill({required this.confidence});

  Color _bg(String c) {
    switch (c.toLowerCase()) {
      case 'high':
        return AppTheme.successColor.withOpacity(0.15);
      case 'medium':
        return AppTheme.warningColor.withOpacity(0.15);
      default:
        return AppTheme.errorColor.withOpacity(0.15);
    }
  }

  Color _fg(String c) {
    switch (c.toLowerCase()) {
      case 'high':
        return AppTheme.successColor;
      case 'medium':
        return AppTheme.warningColor;
      default:
        return AppTheme.errorColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: _bg(confidence),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Confidence: $confidence',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _fg(confidence),
        ),
      ),
    );
  }
}
