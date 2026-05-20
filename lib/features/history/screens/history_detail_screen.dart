import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/history_item.dart';
import '../../../core/theme/app_theme.dart';
import '../../code_check/widgets/probability_chart.dart';
import '../../../core/widgets/responsive_center.dart';

class HistoryDetailScreen extends StatelessWidget {
  final HistoryItem item;

  const HistoryDetailScreen({super.key, required this.item});

  Color _probabilityColor(double p) {
    if (p >= 70) return AppTheme.errorColor;
    if (p >= 40) return AppTheme.warningColor;
    return AppTheme.successColor;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final prob = item.ensembleProbability.clamp(0, 100).toDouble();
    final probColor = _probabilityColor(prob);
    final bothSuccess = item.geminiSuccess && item.groqSuccess;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Analysis Details'),
        elevation: 0,
        actions: [
          Tooltip(
            message: 'Copy code',
            child: IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: item.codeSnippet));
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Row(children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 12),
                    const Text('Code copied to clipboard'),
                  ]),
                  backgroundColor: AppTheme.successColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ));
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ResponsiveCenter(
            maxWidth: 900,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Date card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: theme.dividerColor),
                ),
                child: ListTile(
                  leading:
                      Icon(Icons.calendar_today, color: theme.primaryColor),
                  title:
                      Text('Analysis Date', style: theme.textTheme.labelMedium),
                  subtitle: Text(item.formattedDate,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 24),

              // Final verdict card with chart
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side:
                      BorderSide(color: probColor.withOpacity(0.35), width: 1),
                ),
                color: probColor.withOpacity(0.04),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        'Final Verdict',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 20),

                      // ── Chart (gauge + bars) ─────────────────────
                      ProbabilityChart(
                        probability: prob,
                        geminiProbability:
                            item.geminiProbability.clamp(0, 100).toDouble(),
                        groqProbability:
                            item.groqProbability.clamp(0, 100).toDouble(),
                        bothSuccess: bothSuccess,
                      ),

                      const SizedBox(height: 20),

                      // Verdict badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: probColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: probColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          item.verdict,
                          style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700, color: probColor),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('Confidence: ${item.confidence}',
                          style: theme.textTheme.labelMedium
                              ?.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Individual results
              Text('Individual API Results',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('Results from each AI model independently',
                  style:
                      theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
              const SizedBox(height: 16),

              if (item.geminiSuccess)
                _buildModelResult(
                  context,
                  name: 'Gemini',
                  probability: item.geminiProbability,
                  explanation: item.geminiExplanation,
                  color: Colors.blue,
                  isDark: isDark,
                ),

              if (item.geminiSuccess && item.groqSuccess)
                const SizedBox(height: 12),

              if (item.groqSuccess)
                _buildModelResult(
                  context,
                  name: 'Groq',
                  probability: item.groqProbability,
                  explanation: item.groqExplanation,
                  color: Colors.purple,
                  isDark: isDark,
                ),
              const SizedBox(height: 24),

              // Code section
              Text('Analysed Code',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.dividerColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SelectableText(
                    item.codeSnippet,
                    style: const TextStyle(
                        fontFamily: 'Courier New', fontSize: 12, height: 1.6),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModelResult(
    BuildContext context, {
    required String name,
    required double probability,
    required String? explanation,
    required Color color,
    required bool isDark,
  }) {
    final safe = probability.clamp(0, 100).toDouble();
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.3)),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: color, width: 4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(name == 'Gemini' ? Icons.auto_awesome : Icons.speed,
                    color: color),
                const SizedBox(width: 8),
                Text(name,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: color, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AI Probability',
                          style: Theme.of(context).textTheme.labelSmall),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: safe / 100,
                          minHeight: 10,
                          color: _probabilityColor(safe),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Text('${safe.toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: _probabilityColor(safe))),
              ],
            ),
            if (explanation != null && explanation.trim().isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(explanation,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(height: 1.5)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
