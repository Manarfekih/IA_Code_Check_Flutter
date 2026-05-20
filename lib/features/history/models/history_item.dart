import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

part 'history_item.g.dart';

@HiveType(typeId: 0)
class HistoryItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime timestamp;

  @HiveField(2)
  final String codeSnippet;

  @HiveField(3)
  final double geminiProbability;

  @HiveField(4)
  final double groqProbability;

  @HiveField(5)
  final double ensembleProbability;

  @HiveField(6)
  final String verdict;

  @HiveField(7)
  final String confidence;

  @HiveField(8)
  final String? geminiExplanation;

  @HiveField(9)
  final String? groqExplanation;

  @HiveField(10)
  final bool geminiSuccess;

  @HiveField(11)
  final bool groqSuccess;

  HistoryItem({
    required this.id,
    required this.timestamp,
    required this.codeSnippet,
    required this.geminiProbability,
    required this.groqProbability,
    required this.ensembleProbability,
    required this.verdict,
    required this.confidence,
    this.geminiExplanation,
    this.groqExplanation,
    required this.geminiSuccess,
    required this.groqSuccess,
  });

  /// formatted date for UI
  String get formattedDate =>
      DateFormat('MMM dd, yyyy - hh:mm a').format(timestamp);

  /// preview only
  String get codePreview =>
      codeSnippet.length <= 100
          ? codeSnippet
          : '${codeSnippet.substring(0, 100)}...';

  /// Returns an icon based on the verdict
  IconData getVerdictIcon() {
    switch (verdict.toLowerCase()) {
      case 'pass':
        return Icons.check_circle;
      case 'fail':
        return Icons.cancel;
      case 'warning':
        return Icons.warning;
      default:
        return Icons.help_outline;
    }
  }
}