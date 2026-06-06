import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme.dart';
import 'features/home/home_shell.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'state/app_state.dart';

class PregnancyTrackerApp extends ConsumerWidget {
  const PregnancyTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    return MaterialApp(
      title: 'Pregnancy Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: profile == null ? const OnboardingScreen() : const HomeShell(),
    );
  }
}
