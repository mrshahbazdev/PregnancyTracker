import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/birth_plan_data.dart';
import '../../core/theme.dart';
import '../../models/log_entry.dart';
import '../../state/app_state.dart';

class BirthPlanScreen extends ConsumerWidget {
  const BirthPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(birthPlanProvider);
    final answered = birthPlanAnsweredCount(plan);
    final total = kBirthPlanQuestions.length;
    final progress = total == 0 ? 0.0 : answered / total;
    final sections = birthPlanSections();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Birth Plan'),
        actions: [
          IconButton(
            tooltip: 'Preview & copy',
            icon: const Icon(Icons.ios_share_rounded),
            onPressed: () => _showPreview(context, plan),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        children: [
          _ProgressHeader(answered: answered, total: total, progress: progress),
          const SizedBox(height: 12),
          for (final section in sections) ...[
            _SectionCard(section: section, plan: plan, ref: ref),
            const SizedBox(height: 14),
          ],
          _NotesCard(notes: plan.notes, ref: ref),
        ],
      ),
    );
  }

  void _showPreview(BuildContext context, BirthPlan plan) {
    final text = buildBirthPlanText(plan);
    final hasContent = plan.answers.isNotEmpty || plan.notes.trim().isNotEmpty;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 18, 24, 24 + MediaQuery.of(ctx).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Birth plan preview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Container(
              constraints: const BoxConstraints(maxHeight: 320),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SingleChildScrollView(
                child: Text(
                  hasContent
                      ? text
                      : 'Nothing selected yet — pick your preferences to '
                          'build your plan.',
                  style: const TextStyle(fontSize: 14, height: 1.45),
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: hasContent
                  ? () async {
                      await Clipboard.setData(ClipboardData(text: text));
                      if (ctx.mounted) Navigator.of(ctx).pop();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Birth plan copied to clipboard')),
                        );
                      }
                    }
                  : null,
              icon: const Icon(Icons.copy_rounded),
              label: const Text('Copy to clipboard'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader(
      {required this.answered, required this.total, required this.progress});

  final int answered;
  final int total;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: progress),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                    builder: (_, value, child) => CircularProgressIndicator(
                      value: value,
                      strokeWidth: 7,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                      valueColor:
                          const AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  ),
                  Text('${(progress * 100).round()}%',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$answered of $total preferences set',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  const Text(
                    'A flexible guide to share with your care team. Labor can '
                    'change — that\'s okay.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard(
      {required this.section, required this.plan, required this.ref});

  final String section;
  final BirthPlan plan;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final questions =
        kBirthPlanQuestions.where((q) => q.section == section).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(section,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark)),
            const SizedBox(height: 4),
            for (final q in questions) _QuestionRow(question: q, plan: plan, ref: ref),
          ],
        ),
      ),
    );
  }
}

class _QuestionRow extends StatelessWidget {
  const _QuestionRow(
      {required this.question, required this.plan, required this.ref});

  final BirthPlanQuestion question;
  final BirthPlan plan;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final selected = plan.answers[question.id];
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question.prompt,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final option in question.options)
                ChoiceChip(
                  label: Text(option),
                  selected: selected == option,
                  showCheckmark: false,
                  labelStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected == option
                        ? Colors.white
                        : AppColors.textDark,
                  ),
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.background,
                  side: BorderSide(
                    color: selected == option
                        ? AppColors.primary
                        : AppColors.textMuted.withValues(alpha: 0.2),
                  ),
                  onSelected: (_) => ref
                      .read(birthPlanProvider.notifier)
                      .setAnswer(question.id, option),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NotesCard extends StatefulWidget {
  const _NotesCard({required this.notes, required this.ref});

  final String notes;
  final WidgetRef ref;

  @override
  State<_NotesCard> createState() => _NotesCardState();
}

class _NotesCardState extends State<_NotesCard> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.notes);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Additional notes',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark)),
            const SizedBox(height: 10),
            TextField(
              controller: _controller,
              maxLines: 4,
              minLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText:
                    'Anything else for your care team (allergies, special '
                    'requests, fears)…',
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) =>
                  widget.ref.read(birthPlanProvider.notifier).setNotes(value),
            ),
          ],
        ),
      ),
    );
  }
}
