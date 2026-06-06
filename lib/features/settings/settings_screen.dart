import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme.dart';
import '../../models/pregnancy_profile.dart';
import '../../state/app_state.dart';
import '../ai/ai_service.dart';

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

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('AI Assistant (Bring Your Own Key)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text(
            'Use your own API key for unlimited, fast and private AI. '
            'Your key is stored only on this device and never sent to our servers.',
            style: TextStyle(color: AppColors.textMuted),
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
              fillColor: AppColors.surface,
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
