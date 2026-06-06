import 'package:flutter/foundation.dart';

import '../models/log_entry.dart';

/// A single birth-plan preference with a fixed set of choices.
@immutable
class BirthPlanQuestion {
  const BirthPlanQuestion({
    required this.id,
    required this.section,
    required this.prompt,
    required this.options,
  });

  final String id;
  final String section;
  final String prompt;
  final List<String> options;
}

/// Curated birth-plan questions, grouped by section. These cover the most
/// common preferences parents discuss with their care team. The plan is a
/// communication aid, not a binding contract — labor can change quickly.
const List<BirthPlanQuestion> kBirthPlanQuestions = [
  // Labor environment
  BirthPlanQuestion(
    id: 'env_lighting',
    section: 'Labor environment',
    prompt: 'Lighting',
    options: ['Dimmed', 'Bright', 'No preference'],
  ),
  BirthPlanQuestion(
    id: 'env_music',
    section: 'Labor environment',
    prompt: 'Music / sounds',
    options: ['My playlist', 'Quiet', 'No preference'],
  ),
  BirthPlanQuestion(
    id: 'env_support',
    section: 'Labor environment',
    prompt: 'Support people present',
    options: ['Partner', 'Partner + family', 'Doula', 'Just staff'],
  ),
  // Pain management
  BirthPlanQuestion(
    id: 'pain_approach',
    section: 'Pain management',
    prompt: 'Preferred pain relief',
    options: ['Natural / none', 'Epidural', 'Gas & air', 'Decide during labor'],
  ),
  BirthPlanQuestion(
    id: 'pain_movement',
    section: 'Pain management',
    prompt: 'Freedom to move around',
    options: ['Yes, freely', 'As advised', 'No preference'],
  ),
  BirthPlanQuestion(
    id: 'pain_water',
    section: 'Pain management',
    prompt: 'Water / birthing pool',
    options: ['Interested', 'Not interested', 'No preference'],
  ),
  // Delivery
  BirthPlanQuestion(
    id: 'del_positions',
    section: 'Delivery',
    prompt: 'Birthing position',
    options: ['Whatever feels right', 'Upright / squatting', 'On the bed'],
  ),
  BirthPlanQuestion(
    id: 'del_mirror',
    section: 'Delivery',
    prompt: 'Watch with a mirror',
    options: ['Yes', 'No', 'No preference'],
  ),
  BirthPlanQuestion(
    id: 'del_cord',
    section: 'Delivery',
    prompt: 'Cord clamping',
    options: ['Delayed', 'Immediate', 'No preference'],
  ),
  BirthPlanQuestion(
    id: 'del_cord_cut',
    section: 'Delivery',
    prompt: 'Who cuts the cord',
    options: ['Partner', 'Me', 'Care provider'],
  ),
  // After birth
  BirthPlanQuestion(
    id: 'after_skin',
    section: 'After birth',
    prompt: 'Immediate skin-to-skin',
    options: ['Yes, please', 'After checks', 'No preference'],
  ),
  BirthPlanQuestion(
    id: 'after_feeding',
    section: 'After birth',
    prompt: 'Feeding plan',
    options: ['Breastfeeding', 'Bottle', 'Combination', 'Decide later'],
  ),
  BirthPlanQuestion(
    id: 'after_vitk',
    section: 'After birth',
    prompt: 'Vitamin K for baby',
    options: ['Injection', 'Oral', 'Discuss with provider'],
  ),
];

/// Section order as they first appear in [kBirthPlanQuestions].
List<String> birthPlanSections() {
  final sections = <String>[];
  for (final q in kBirthPlanQuestions) {
    if (!sections.contains(q.section)) sections.add(q.section);
  }
  return sections;
}

/// Number of questions that have an answer selected.
int birthPlanAnsweredCount(BirthPlan plan) =>
    kBirthPlanQuestions.where((q) => plan.answers.containsKey(q.id)).length;

/// Build a plain-text version of the plan suitable for sharing or printing.
/// Only answered questions are included, grouped by section.
String buildBirthPlanText(BirthPlan plan) {
  final buffer = StringBuffer('My Birth Plan\n');
  for (final section in birthPlanSections()) {
    final answered = kBirthPlanQuestions
        .where((q) => q.section == section && plan.answers.containsKey(q.id))
        .toList();
    if (answered.isEmpty) continue;
    buffer.writeln('\n$section');
    for (final q in answered) {
      buffer.writeln('  • ${q.prompt}: ${plan.answers[q.id]}');
    }
  }
  final notes = plan.notes.trim();
  if (notes.isNotEmpty) {
    buffer.writeln('\nAdditional notes');
    buffer.writeln('  $notes');
  }
  return buffer.toString().trim();
}
