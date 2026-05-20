import 'package:flutter/material.dart';
import '../models/history_item.dart';
import '../../../core/theme/app_theme.dart';

class HistoryCard extends StatelessWidget {
  final HistoryItem item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const HistoryCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final double probability =
        item.ensembleProbability.clamp(0, 100).toDouble();
    final color = _getProbabilityColor(probability);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============= HEADER WITH DATE & DELETE =============
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              item.getVerdictIcon(),
                              size: 18,
                              color: color,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.formattedDate,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium?.copyWith(
                                  color: isDarkMode
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.verdict,
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        onTap: onDelete,
                        child: const Row(
                          children: [
                            Icon(Icons.delete_outline,
                                color: AppTheme.errorColor, size: 18),
                            SizedBox(width: 10),
                            Text('Delete', style: TextStyle(
                              color: AppTheme.errorColor,
                            )),
                          ],
                        ),
                      ),
                    ],
                    child: Icon(
                      Icons.more_vert,
                      size: 20,
                      color: isDarkMode
                          ? Colors.grey[400]
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ============= CODE PREVIEW =============
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? const Color(0xFF3A3A3C)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Theme.of(context)
                        .dividerColor
                        .withOpacity(0.3),
                  ),
                ),
                child: Text(
                  item.codePreview,
                  style: const TextStyle(
                    fontFamily: 'Courier New',
                    fontSize: 11,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 12),

              // ============= PROBABILITY PROGRESS =============
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'AI Probability',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isDarkMode
                          ? Colors.grey[400]
                          : Colors.grey[700],
                    ),
                  ),
                  Text(
                    '${probability.toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: probability / 100,
                  minHeight: 6,
                  backgroundColor: Theme.of(context)
                      .dividerColor
                      .withOpacity(0.3),
                  color: color,
                ),
              ),
              const SizedBox(height: 10),

              // ============= BADGES =============
              Row(
                children: [
                  _buildBadge(
                    item.verdict,
                    color,
                    context,
                  ),
                  const SizedBox(width: 8),
                  _buildBadge(
                    'Confidence: ${item.confidence}',
                    AppTheme.infoColor,
                    context,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============= HELPER FUNCTIONS =============

  Color _getProbabilityColor(double probability) {
    if (probability >= 70) return AppTheme.errorColor;
    if (probability >= 40) return AppTheme.warningColor;
    return AppTheme.successColor;
  }

  Widget _buildBadge(String text, Color color, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}