import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../models/pregnancy_profile.dart';
import '../../state/app_state.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _nameController = TextEditingController();
  DueDateMethod _method = DueDateMethod.lastPeriod;
  DateTime? _selectedDate;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Converts the date entered for the chosen method into a due date.
  DateTime _computeDueDate(DateTime input) {
    return switch (_method) {
      DueDateMethod.lastPeriod => input.add(const Duration(days: 280)),
      DueDateMethod.conception => input.add(const Duration(days: 266)),
      DueDateMethod.ivf => input.add(const Duration(days: 266)),
      DueDateMethod.dueDate => input,
    };
  }

  String get _datePrompt => switch (_method) {
        DueDateMethod.lastPeriod => 'First day of your last period',
        DueDateMethod.conception => 'Date of conception',
        DueDateMethod.ivf => 'Embryo transfer date',
        DueDateMethod.dueDate => 'Your due date',
      };

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final isFuture = _method == DueDateMethod.dueDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now.subtract(const Duration(days: 300)),
      lastDate: now.add(Duration(days: isFuture ? 300 : 1)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _finish() async {
    final date = _selectedDate;
    if (date == null) return;
    final profile = PregnancyProfile(
      name: _nameController.text.trim(),
      dueDate: _computeDueDate(date),
      method: _method,
    );
    await ref.read(profileProvider.notifier).setProfile(profile);
  }

  @override
  Widget build(BuildContext context) {
    final canFinish = _selectedDate != null;
    final dueDatePreview =
        _selectedDate == null ? null : _computeDueDate(_selectedDate!);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const Text('🤰', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                'Welcome',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                'Let\'s set up your pregnancy journey. This stays private on your device.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 15),
              ),
              const SizedBox(height: 28),
              const Text('Your name (optional)',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'e.g. Munazza',
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text('How do you want to calculate?',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: DueDateMethod.values.map((m) {
                  final selected = m == _method;
                  return ChoiceChip(
                    label: Text(m.label),
                    selected: selected,
                    onSelected: (_) => setState(() {
                      _method = m;
                      _selectedDate = null;
                    }),
                    selectedColor: AppColors.primary.withValues(alpha: 0.18),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Text(_datePrompt,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          color: AppColors.primary),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate == null
                            ? 'Select a date'
                            : DateFormat.yMMMMd().format(_selectedDate!),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              if (dueDatePreview != null) ...[
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Estimated due date',
                          style: TextStyle(color: AppColors.textMuted)),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat.yMMMMd().format(dueDatePreview),
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: canFinish ? _finish : null,
                  child: const Text('Start my journey'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
