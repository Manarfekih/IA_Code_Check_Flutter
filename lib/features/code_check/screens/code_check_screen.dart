import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ia_code_check/core/constants/app_constants.dart';
import 'package:ia_code_check/features/code_check/models/analysis_result.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_center.dart';
import '../providers/analysis_provider.dart';
import '../../history/providers/history_provider.dart';
import '../../history/models/history_item.dart';
import '../../history/screens/history_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/code_input_widget.dart';
import '../widgets/ensemble_result_card.dart';
import '../widgets/result_card.dart';

class CodeCheckScreen extends ConsumerStatefulWidget {
  const CodeCheckScreen({super.key});

  @override
  ConsumerState<CodeCheckScreen> createState() => _CodeCheckScreenState();
}

class _CodeCheckScreenState extends ConsumerState<CodeCheckScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _historySavedForResult = false;
  String? _lastShownError;
  ProviderSubscription<AnalysisState>? _analysisSub;

  @override
  void initState() {
    super.initState();

    _analysisSub = ref.listenManual<AnalysisState>(analysisProvider,
        (previous, next) {
      final nextResult = next.result;
      if (nextResult != null && !_historySavedForResult) {
        _historySavedForResult = true;
        _saveToHistory(nextResult);
      }

      final err = next.error;
      if (err != null && err.trim().isNotEmpty && err != _lastShownError) {
        _lastShownError = err;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(err),
              backgroundColor: AppTheme.errorColor,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _analysisSub?.close();
    _codeController.dispose();
    super.dispose();
  }

  void _analyzeCode() {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Please enter some code to analyse'),
        backgroundColor: AppTheme.warningColor,
      ));
      return;
    }
    _historySavedForResult = false;
    ref.read(analysisProvider.notifier).analyzeWithBoth(code);
  }

  void _clearResults() {
    ref.read(analysisProvider.notifier).clearResult();
    _codeController.clear();
    _historySavedForResult = false;
    _lastShownError = null;
  }

  void _logout() async {
    await ref.read(authProvider.notifier).logout();
  }

  Future<void> _saveToHistory(EnsembleResult result) async {
    final item = HistoryItem(
      id: const Uuid().v4(),
      timestamp: DateTime.now(),
      codeSnippet: _codeController.text.trim(),
      geminiProbability:
          result.geminiResult?.probability ?? 0,
      groqProbability: result.groqResult?.probability ?? 0,
      ensembleProbability: result.averageProbability,
      verdict: result.verdict,
      confidence: result.confidence,
      geminiExplanation: result.geminiResult?.explanation,
      groqExplanation: result.groqResult?.explanation,
      geminiSuccess: result.geminiResult?.success ?? false,
      groqSuccess: result.groqResult?.success ?? false,
    );
    try {
      await ref.read(historyProvider.notifier).addAnalysis(item);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not save to history'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(analysisProvider);
    final result = state.result;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: 'Reset Analysis',
            onPressed: _clearResults,
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'History',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const HistoryScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const SettingsScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ResponsiveCenter(
            maxWidth: 900,
            padding: AppTheme.getResponsivePadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              CodeInputWidget(
                controller: _codeController,
                onAnalyze: _analyzeCode,
                isLoading: state.isLoading,
              ),
              const SizedBox(height: 24),

              // Loading
              if (state.isLoading)
                Center(
                  child: Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 12),
                      Text('Analysing...',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),

              // Error
              if (state.error != null && !state.isLoading)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppTheme.errorColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline,
                          color: AppTheme.errorColor, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(state.error!,
                            style: TextStyle(
                                color: AppTheme.errorColor,
                                fontSize: 13)),
                      ),
                    ],
                  ),
                ),

              // Results with animation
              if (result != null && !state.isLoading) ...[
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Analysis Results',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Reset Analysis',
                      onPressed: _clearResults,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                EnsembleResultCard(result: result),
                const SizedBox(height: 24),
                if (result.geminiResult != null)
                  ResultCard(
                      result: result.geminiResult!,
                      color: Colors.blue),
                const SizedBox(height: 10),
                if (result.groqResult != null)
                  ResultCard(
                      result: result.groqResult!,
                      color: Colors.purple),
                const SizedBox(height: 20),
              ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
