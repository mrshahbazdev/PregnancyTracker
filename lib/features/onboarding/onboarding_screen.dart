import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _pageController = PageController();
  DueDateMethod _method = DueDateMethod.lastPeriod;
  DateTime? _selectedDate;
  int _currentPage = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _pageController.dispose();
    super.dispose();
  }

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
    HapticFeedback.mediumImpact();
    final profile = PregnancyProfile(
      name: _nameController.text.trim(),
      dueDate: _computeDueDate(date),
      method: _method,
    );
    await ref.read(profileProvider.notifier).setProfile(profile);
  }

  void _nextPage() {
    HapticFeedback.lightImpact();
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.textMutedDark : AppColors.textMuted;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Page dots indicator
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: List.generate(3, (i) {
                  return Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: i <= _currentPage
                            ? AppColors.primary
                            : AppColors.primary.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _WelcomePage(
                    nameController: _nameController,
                    onNext: _nextPage,
                    mutedColor: mutedColor,
                  ),
                  _MethodPage(
                    method: _method,
                    onMethodChanged: (m) => setState(() {
                      _method = m;
                      _selectedDate = null;
                    }),
                    onNext: _nextPage,
                    onBack: _previousPage,
                    mutedColor: mutedColor,
                  ),
                  _DatePage(
                    method: _method,
                    datePrompt: _datePrompt,
                    selectedDate: _selectedDate,
                    computeDueDate: _computeDueDate,
                    onPickDate: _pickDate,
                    onFinish: _finish,
                    onBack: _previousPage,
                    mutedColor: mutedColor,
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

// ---- Page 1: Welcome + Name ----
class _WelcomePage extends StatelessWidget {
  const _WelcomePage({
    required this.nameController,
    required this.onNext,
    required this.mutedColor,
  });

  final TextEditingController nameController;
  final VoidCallback onNext;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surface;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.20),
                  AppColors.accent.withValues(alpha: 0.20),
                ],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Center(
              child: Text('🤰', style: TextStyle(fontSize: 36)),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Welcome',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Let\'s set up your pregnancy journey.\nEverything stays private on your device.',
            style: TextStyle(color: mutedColor, fontSize: 15, height: 1.4),
          ),
          const SizedBox(height: 36),
          const Text('Your name (optional)',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextField(
            controller: nameController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: 'e.g. Munazza',
              filled: true,
              fillColor: surfaceColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onNext,
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}

// ---- Page 2: Due date method ----
class _MethodPage extends StatelessWidget {
  const _MethodPage({
    required this.method,
    required this.onMethodChanged,
    required this.onNext,
    required this.onBack,
    required this.mutedColor,
  });

  final DueDateMethod method;
  final ValueChanged<DueDateMethod> onMethodChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(height: 16),
          Text(
            'How do you want\nto calculate?',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose how you know your pregnancy timing.',
            style: TextStyle(color: mutedColor, fontSize: 15),
          ),
          const SizedBox(height: 24),
          ...DueDateMethod.values.map((m) {
            final selected = m == method;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => onMethodChanged(m),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary.withValues(alpha: isDark ? 0.22 : 0.10)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: selected
                          ? AppColors.primary
                          : AppColors.textMuted.withValues(alpha: 0.2),
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        selected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        color: selected ? AppColors.primary : mutedColor,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(m.label,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  selected ? FontWeight.w800 : FontWeight.w600,
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onNext,
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}

// ---- Page 3: Date picker + Result ----
class _DatePage extends StatelessWidget {
  const _DatePage({
    required this.method,
    required this.datePrompt,
    required this.selectedDate,
    required this.computeDueDate,
    required this.onPickDate,
    required this.onFinish,
    required this.onBack,
    required this.mutedColor,
  });

  final DueDateMethod method;
  final String datePrompt;
  final DateTime? selectedDate;
  final DateTime Function(DateTime) computeDueDate;
  final VoidCallback onPickDate;
  final VoidCallback onFinish;
  final VoidCallback onBack;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    final canFinish = selectedDate != null;
    final dueDatePreview =
        selectedDate == null ? null : computeDueDate(selectedDate!);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surface;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(height: 16),
          Text(
            datePrompt,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap to select the date from your calendar.',
            style: TextStyle(color: mutedColor, fontSize: 15),
          ),
          const SizedBox(height: 28),
          InkWell(
            onTap: onPickDate,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded,
                      color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text(
                    selectedDate == null
                        ? 'Select a date'
                        : DateFormat.yMMMMd().format(selectedDate!),
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          if (dueDatePreview != null) ...[
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.12),
                    AppColors.accent.withValues(alpha: isDark ? 0.20 : 0.10),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Estimated due date',
                      style: TextStyle(color: mutedColor)),
                  const SizedBox(height: 6),
                  Text(
                    DateFormat.yMMMMd().format(dueDatePreview),
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${dueDatePreview.difference(DateTime.now()).inDays} days to go',
                    style: TextStyle(color: mutedColor, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 36),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: canFinish ? onFinish : null,
              child: const Text('Start my journey'),
            ),
          ),
        ],
      ),
    );
  }
}
