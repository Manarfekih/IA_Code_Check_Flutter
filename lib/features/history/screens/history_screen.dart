import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_center.dart';
import '../providers/history_provider.dart';
import '../widgets/history_card.dart';
import 'history_detail_screen.dart';
import '../models/history_item.dart';
import '../../../shared/widgets/empty_state.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    Future.microtask(
        () => ref.read(historyProvider.notifier).loadHistory());
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() =>
      ref.read(historyProvider.notifier).search(_searchController.text.trim());

  Future<void> _deleteItem(String id) async {
    try {
      await ref.read(historyProvider.notifier).deleteItem(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.delete_outline, color: Colors.white),
          const SizedBox(width: 12),
          const Text('Analysis deleted'),
        ]),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Delete failed'),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ));
    }
  }

  Future<void> _confirmDeleteAll() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete All'),
        content: const Text('Are you sure you want to delete all saved analyses?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
                foregroundColor: AppTheme.errorColor),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
    if (shouldDelete == true) {
      try {
        await ref.read(historyProvider.notifier).deleteAllItems();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            const Text('All history deleted'),
          ]),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Delete all failed'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(historyProvider);
    final items = historyState.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis History'),
        elevation: 0,
        actions: [
          if (items.isNotEmpty)
            Tooltip(
              message: 'Delete All',
              child: IconButton(
                icon: const Icon(Icons.delete_sweep),
                onPressed: _confirmDeleteAll,
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          ResponsiveCenter(
            maxWidth: 900,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              enabled: !historyState.isLoading,
              decoration: InputDecoration(
                hintText: 'Search analyses…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: historyState.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Expanded(
            child: historyState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : items.isEmpty
                    ? EmptyState(
                        icon: historyState.searchQuery.isNotEmpty
                            ? Icons.search_off
                            : Icons.history,
                        title: historyState.searchQuery.isNotEmpty
                            ? 'No results found'
                            : 'No analyses yet',
                        subtitle: historyState.searchQuery.isNotEmpty
                            ? 'Try a different search term'
                            : 'No analyses yet',
                        buttonText: historyState.searchQuery.isEmpty
                            ? 'Go Back'
                            : null,
                        onButtonPressed:
                            historyState.searchQuery.isEmpty
                                ? () => Navigator.pop(context)
                                : null,
                      )
                    : RefreshIndicator(
                        onRefresh: () async => ref
                            .read(historyProvider.notifier)
                            .loadHistory(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: items.length,
                          itemBuilder: (context, index) => ResponsiveCenter(
                            maxWidth: 900,
                            padding: const EdgeInsets.only(bottom: 12),
                            child: HistoryCard(
                              item: items[index],
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => HistoryDetailScreen(
                                    item: items[index],
                                  ),
                                ),
                              ),
                              onDelete: () => _deleteItem(items[index].id),
                            ),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
