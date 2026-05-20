import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/history_item.dart';
import '../../../core/constants/app_constants.dart';

class HistoryService {
  Box<HistoryItem> get _box =>
      Hive.box<HistoryItem>(AppConstants.storageHistoryKey);

  Future<void> saveAnalysis(HistoryItem item) async {
    try {
      await _box.put(item.id, item);
      debugPrint('Saved analysis: ${item.id}');
    } catch (e) {
      debugPrint('Save error: $e');
    }
  }

  List<HistoryItem> getAllAnalyses() {
    final items = _box.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return items;
  }

  HistoryItem? getAnalysis(String id) {
    return _box.get(id);
  }

  Future<void> deleteAnalysis(String id) async {
    try {
      await _box.delete(id);
      debugPrint('Deleted analysis: $id');
    } catch (e) {
      debugPrint('Delete error: $e');
    }
  }

  Future<void> deleteAllAnalyses() async {
    await _box.clear();
  }

  int getCount() => _box.length;

  List<HistoryItem> searchAnalyses(String query) {
    if (query.isEmpty) return getAllAnalyses();

    final lowerQuery = query.toLowerCase();

    return _box.values.where((item) {
      return item.codeSnippet.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  bool hasHistory() => _box.isNotEmpty;
}