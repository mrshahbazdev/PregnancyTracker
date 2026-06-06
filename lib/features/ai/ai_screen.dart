import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../state/app_state.dart';
import '../settings/settings_screen.dart';
import 'ai_service.dart';

class _ChatMessage {
  _ChatMessage(this.text, this.fromUser);
  final String text;
  final bool fromUser;
}

const _suggestions = [
  'Is it safe to eat seafood?',
  'What helps with morning sickness?',
  'How much weight should I gain?',
  'What foods boost iron?',
];

class AiScreen extends ConsumerStatefulWidget {
  const AiScreen({super.key});

  @override
  ConsumerState<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends ConsumerState<AiScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  String? _buildContext() {
    final profile = ref.read(profileProvider);
    if (profile == null) return null;
    final now = DateTime.now();
    return 'Week ${profile.currentWeek(now)}, ${profile.trimester(now)}.';
  }

  Future<void> _send([String? preset]) async {
    final text = (preset ?? _controller.text).trim();
    if (text.isEmpty || _loading) return;
    setState(() {
      _messages.add(_ChatMessage(text, true));
      _loading = true;
      _controller.clear();
    });
    _scrollToEnd();
    try {
      final answer = await ref
          .read(aiServiceProvider)
          .ask(text, context: _buildContext());
      setState(() => _messages.add(_ChatMessage(answer, false)));
    } on AiException catch (e) {
      setState(() => _messages.add(_ChatMessage(e.message, false)));
    } catch (_) {
      setState(() => _messages
          .add(_ChatMessage('Something went wrong. Please try again.', false)));
    } finally {
      setState(() => _loading = false);
      _scrollToEnd();
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(aiConfigProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (!config.hasKey) _NoKeyBanner(),
          Expanded(
            child: _messages.isEmpty
                ? _EmptyState(onTap: _send)
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, i) => _Bubble(_messages[i]),
                  ),
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text('Thinking…',
                  style: TextStyle(color: AppColors.textMuted)),
            ),
          _Composer(controller: _controller, onSend: () => _send()),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'AI guidance is informational, not medical advice. Always consult your provider.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoKeyBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.accent.withValues(alpha: 0.18),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const Icon(Icons.key_rounded, color: AppColors.primaryDark),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Add your own AI key in Settings to start chatting (free & private).',
              style: TextStyle(fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
            child: const Text('Set up'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onTap});
  final void Function(String) onTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 24),
        const Center(child: Text('✨', style: TextStyle(fontSize: 48))),
        const SizedBox(height: 12),
        const Center(
          child: Text('Ask me anything about your pregnancy',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 24),
        ..._suggestions.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: OutlinedButton(
                onPressed: () => onTap(s),
                style: OutlinedButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(s),
              ),
            )),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble(this.message);
  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final fromUser = message.fromUser;
    return Align(
      alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: BoxDecoration(
          color: fromUser ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: fromUser ? Colors.white : AppColors.textDark,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({required this.controller, required this.onSend});
  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: InputDecoration(
                hintText: 'Type your question…',
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: onSend,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.all(14),
            ),
            icon: const Icon(Icons.send_rounded),
          ),
        ],
      ),
    );
  }
}
