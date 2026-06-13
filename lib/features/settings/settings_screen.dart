import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme.dart';
import '../../models/pregnancy_profile.dart';
import '../../state/app_state.dart';
import '../ai/ai_service.dart';
import '../backup/backup_screen.dart';
import '../notifications/notification_settings_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _keyController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _saveKey() async {
    final key = _keyController.text.trim();
    if (key.isEmpty) return;
    await ref.read(aiConfigProvider.notifier).setApiKey(key);
    _keyController.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('API key saved securely on device')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(aiConfigProvider);
    final profile = ref.watch(profileProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.textMutedDark : AppColors.textMuted;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surface;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ---- Appearance ----
          const Text('Appearance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Theme',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _ThemeChip(
                        label: 'System',
                        icon: Icons.brightness_auto_rounded,
                        selected: themeMode == AppThemeMode.system,
                        onTap: () => ref
                            .read(themeModeProvider.notifier)
                            .setMode(AppThemeMode.system),
                      ),
                      const SizedBox(width: 8),
                      _ThemeChip(
                        label: 'Light',
                        icon: Icons.light_mode_rounded,
                        selected: themeMode == AppThemeMode.light,
                        onTap: () => ref
                            .read(themeModeProvider.notifier)
                            .setMode(AppThemeMode.light),
                      ),
                      const SizedBox(width: 8),
                      _ThemeChip(
                        label: 'Dark',
                        icon: Icons.dark_mode_rounded,
                        selected: themeMode == AppThemeMode.dark,
                        onTap: () => ref
                            .read(themeModeProvider.notifier)
                            .setMode(AppThemeMode.dark),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 36),

          // ---- AI Assistant ----
          const Text('AI Assistant (Bring Your Own Key)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(
            'Use your own API key for unlimited, fast and private AI. '
            'Your key is stored only on this device and never sent to our servers.',
            style: TextStyle(color: mutedColor),
          ),
          const SizedBox(height: 16),
          const Text('Provider',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: AiProvider.values.map((p) {
              return ChoiceChip(
                label: Text(p.label),
                selected: config.provider == p,
                onSelected: (_) =>
                    ref.read(aiConfigProvider.notifier).setProvider(p),
                selectedColor: AppColors.primary.withValues(alpha: 0.18),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('API key',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              if (config.hasKey)
                const Row(
                  children: [
                    Icon(Icons.check_circle,
                        color: Colors.green, size: 18),
                    SizedBox(width: 4),
                    Text('Key set', style: TextStyle(color: Colors.green)),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _keyController,
            obscureText: _obscure,
            decoration: InputDecoration(
              hintText: config.provider.keyHint,
              filled: true,
              fillColor: surfaceColor,
              suffixIcon: IconButton(
                icon: Icon(
                    _obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: _saveKey,
                  child: const Text('Save key'),
                ),
              ),
              if (config.hasKey) ...[
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () =>
                      ref.read(aiConfigProvider.notifier).clearApiKey(),
                  child: const Text('Remove'),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () {
              final url = config.provider == AiProvider.openai
                  ? 'https://platform.openai.com/api-keys'
                  : 'https://aistudio.google.com/app/apikey';
              launchUrl(Uri.parse(url),
                  mode: LaunchMode.externalApplication);
            },
            icon: const Icon(Icons.open_in_new, size: 16),
            label: const Text('Get an API key'),
          ),
          const Divider(height: 40),

          // ---- Notifications & Backup ----
          const Text('Notifications & Data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications_rounded),
                  title: const Text('Notification settings'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const NotificationSettingsScreen()),
                  ),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.cloud_download_rounded),
                  title: const Text('Backup & restore'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const BackupScreen()),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 40),

          // ---- Pregnancy ----
          const Text('Pregnancy',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          if (profile != null)
            Card(
              child: ListTile(
                title: Text(profile.name.isEmpty
                    ? 'Due date set'
                    : profile.name),
                subtitle: Text('Method: ${profile.method.label}'),
              ),
            ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _confirmReset(context),
            icon: const Icon(Icons.restart_alt),
            label: const Text('Reset pregnancy data'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset pregnancy?'),
        content: const Text(
            'This will clear your profile and return to onboarding.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Reset')),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(profileProvider.notifier).reset();
      if (context.mounted) Navigator.of(context).pop();
    }
  }
}

class _ThemeChip extends StatelessWidget {
  const _ThemeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.16)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : AppColors.textMuted.withValues(alpha: 0.2),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: selected ? AppColors.primary : AppColors.textMuted,
                  size: 22),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: selected ? AppColors.primary : null,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
