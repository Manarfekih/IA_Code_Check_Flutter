import 'package:flutter/material.dart';
import '../models/analysis_result.dart';
import '../../../core/theme/app_theme.dart';

class ResultCard extends StatelessWidget {
  final AnalysisResult result;
  final Color color;

  const ResultCard({
    super.key,
    required this.result,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!result.success) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border(
              left: BorderSide(color: color, width: 5),
            ),
            color: color.withOpacity(0.05),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============= HEADER =============
              Row(
                children: [
                  Icon(
                    _getApiIcon(result.apiName),
                    color: color,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      result.apiName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.error_outline,
                      color: AppTheme.errorColor,
                      size: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ============= ERROR MESSAGE =============
              Text(
                (result.error ?? '').trim().isEmpty
                    ? 'This service is unavailable right now. Please try again later.'
                    : result.error!.trim(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final double probability =
        result.probability.clamp(0, 100).toDouble();
    final probColor = _getProbabilityColor(probability);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: BorderSide(color: color, width: 5),
          ),
          color: isDark
              ? Theme.of(context).cardColor
              : Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============= HEADER =============
            Row(
              children: [
                Icon(
                  _getApiIcon(result.apiName),
                  color: color,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.apiName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        result.label,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: _getLabelColor(result.label),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ============= PROBABILITY PROGRESS =============
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'AI Probability',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    Text(
                      '${probability.toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: probColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: probability / 100,
                    minHeight: 10,
                    backgroundColor: Theme.of(context)
                        .dividerColor
                        .withOpacity(0.3),
                    color: probColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ============= LABEL BADGE =============
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: _getLabelColor(result.label).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getLabelColor(result.label).withOpacity(0.3),
                ),
              ),
              child: Text(
                result.label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: _getLabelColor(result.label),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ============= EXPLANATION =============
            if (result.explanation.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .dividerColor
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  result.explanation,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    height: 1.6,
                  ),
                ),
              ),
            ] else ...[
              Text(
                'No detailed explanation available',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============= HELPER FUNCTIONS =============

  IconData _getApiIcon(String apiName) {
    switch (apiName.toLowerCase()) {
      case 'gemini':
        return Icons.auto_awesome;
      case 'groq':
        return Icons.speed;
      default:
        return Icons.analytics;
    }
  }

  Color _getProbabilityColor(double probability) {
    if (probability >= 70) return AppTheme.errorColor;
    if (probability >= 40) return AppTheme.warningColor;
    return AppTheme.successColor;
  }

  Color _getLabelColor(String label) {
    final lower = label.toLowerCase();

    if (lower.contains('ai') || lower.contains('likely')) {
      return AppTheme.errorColor;
    }
    if (lower.contains('human') || lower.contains('unlikely')) {
      return AppTheme.successColor;
    }
    if (lower.contains('error') || lower.contains('unable')) {
      return Colors.grey;
    }

    return AppTheme.warningColor;
  }
}