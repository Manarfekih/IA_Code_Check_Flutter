import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_center.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(settingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), elevation: 0),
      body: SingleChildScrollView(
        child: ResponsiveCenter(
          maxWidth: 900,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          _sectionTitle('Appearance', context),
          const SizedBox(height: 12),
          _card(
            context,
            children: [
              _themeTile(
                context,
                title: 'Light Mode',
                icon: Icons.light_mode,
                selected: themeMode == ThemeMode.light,
                onTap: () => ref
                    .read(settingsProvider.notifier)
                    .setThemeMode(ThemeMode.light),
              ),
              _divider(context),
              _themeTile(
                context,
                title: 'Dark Mode',
                icon: Icons.dark_mode,
                selected: themeMode == ThemeMode.dark,
                onTap: () => ref
                    .read(settingsProvider.notifier)
                    .setThemeMode(ThemeMode.dark),
              ),
              _divider(context),
              _themeTile(
                context,
                title: 'System Default',
                icon: Icons.settings_suggest,
                selected: themeMode == ThemeMode.system,
                onTap: () => ref
                    .read(settingsProvider.notifier)
                    .setThemeMode(ThemeMode.system),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _sectionTitle('About', context),
          const SizedBox(height: 12),
          _card(
            context,
            children: [
              _infoTile(context, 'App', AppConstants.appName, Icons.info_outline),
              _divider(context),
              _infoTile(context, 'Version', '1.0.0', Icons.numbers),
              _divider(context),
              _infoTile(
                context,
                'Theme',
                themeMode == ThemeMode.system
                    ? 'System'
                    : themeMode == ThemeMode.dark
                        ? 'Dark'
                        : 'Light',
                Icons.palette_outlined,
              ),
            ],
          ),

          const SizedBox(height: 18),
          Text(
            'Tip: You can change theme anytime.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
          ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      title,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.grey[300] : Colors.grey[700],
          ),
    );
  }

  Widget _card(BuildContext context, {required List<Widget> children}) => Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Theme.of(context).dividerColor),
        ),
        child: Column(children: children),
      );

  Widget _divider(BuildContext context) => Divider(
        height: 1,
        color: Theme.of(context).dividerColor.withOpacity(0.5),
      );

  Widget _themeTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            if (selected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check,
                    size: 18, color: AppTheme.primaryColor),
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
