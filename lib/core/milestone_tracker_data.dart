import 'package:flutter/foundation.dart';

/// Category of a baby developmental milestone.
enum MilestoneCategory { motor, social, cognitive, language, feeding }

extension MilestoneCategoryLabel on MilestoneCategory {
  String get label => switch (this) {
        MilestoneCategory.motor => 'Motor',
        MilestoneCategory.social => 'Social',
        MilestoneCategory.cognitive => 'Cognitive',
        MilestoneCategory.language => 'Language',
        MilestoneCategory.feeding => 'Feeding',
      };

  String get icon => switch (this) {
        MilestoneCategory.motor => '🏃',
        MilestoneCategory.social => '😊',
        MilestoneCategory.cognitive => '🧠',
        MilestoneCategory.language => '🗣️',
        MilestoneCategory.feeding => '🍼',
      };
}

/// A single baby milestone definition.
@immutable
class BabyMilestone {
  const BabyMilestone({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.typicalAgeMonths,
  });

  final String id;
  final String title;
  final String description;
  final MilestoneCategory category;

  /// Typical age in months when this milestone occurs.
  final int typicalAgeMonths;
}

/// Curated list of baby developmental milestones (0–12 months).
const babyMilestones = <BabyMilestone>[
  // 0-1 month
  BabyMilestone(
    id: 'first_eye_contact',
    title: 'First Eye Contact',
    description: 'Baby focuses on your face and makes eye contact.',
    category: MilestoneCategory.social,
    typicalAgeMonths: 0,
  ),
  BabyMilestone(
    id: 'first_grasp',
    title: 'First Grasp Reflex',
    description: 'Baby grips your finger tightly when you place it in their palm.',
    category: MilestoneCategory.motor,
    typicalAgeMonths: 0,
  ),
  BabyMilestone(
    id: 'first_cry',
    title: 'First Cry',
    description: 'Baby\'s very first cry at birth — their hello to the world.',
    category: MilestoneCategory.language,
    typicalAgeMonths: 0,
  ),

  // 1-2 months
  BabyMilestone(
    id: 'first_smile',
    title: 'First Social Smile',
    description: 'Baby smiles in response to your voice or face.',
    category: MilestoneCategory.social,
    typicalAgeMonths: 1,
  ),
  BabyMilestone(
    id: 'head_lift',
    title: 'Lifts Head (Tummy Time)',
    description: 'Baby briefly lifts head during tummy time.',
    category: MilestoneCategory.motor,
    typicalAgeMonths: 1,
  ),
  BabyMilestone(
    id: 'first_coo',
    title: 'First Coo',
    description: 'Baby makes soft vowel sounds like "ooh" or "aah".',
    category: MilestoneCategory.language,
    typicalAgeMonths: 2,
  ),
  BabyMilestone(
    id: 'follows_object',
    title: 'Follows Moving Object',
    description: 'Baby tracks a toy or face moving side to side.',
    category: MilestoneCategory.cognitive,
    typicalAgeMonths: 2,
  ),

  // 3-4 months
  BabyMilestone(
    id: 'first_laugh',
    title: 'First Laugh',
    description: 'Baby laughs out loud for the first time.',
    category: MilestoneCategory.social,
    typicalAgeMonths: 3,
  ),
  BabyMilestone(
    id: 'holds_head_steady',
    title: 'Holds Head Steady',
    description: 'Baby holds head steady without support when upright.',
    category: MilestoneCategory.motor,
    typicalAgeMonths: 3,
  ),
  BabyMilestone(
    id: 'reaches_toys',
    title: 'Reaches for Toys',
    description: 'Baby reaches out and swipes at dangling toys.',
    category: MilestoneCategory.motor,
    typicalAgeMonths: 3,
  ),
  BabyMilestone(
    id: 'recognises_parent',
    title: 'Recognises Parent\'s Voice',
    description: 'Baby turns toward your voice and calms when hearing you.',
    category: MilestoneCategory.cognitive,
    typicalAgeMonths: 3,
  ),
  BabyMilestone(
    id: 'first_rollover',
    title: 'First Rollover',
    description: 'Baby rolls from tummy to back (or back to tummy).',
    category: MilestoneCategory.motor,
    typicalAgeMonths: 4,
  ),
  BabyMilestone(
    id: 'grabs_objects',
    title: 'Grabs & Holds Objects',
    description: 'Baby can grab a rattle or toy and hold onto it.',
    category: MilestoneCategory.motor,
    typicalAgeMonths: 4,
  ),

  // 5-6 months
  BabyMilestone(
    id: 'first_babble',
    title: 'First Babble',
    description: 'Baby starts babbling consonant sounds like "ba-ba" or "da-da".',
    category: MilestoneCategory.language,
    typicalAgeMonths: 5,
  ),
  BabyMilestone(
    id: 'sits_with_support',
    title: 'Sits with Support',
    description: 'Baby can sit up when propped or with your hands for balance.',
    category: MilestoneCategory.motor,
    typicalAgeMonths: 5,
  ),
  BabyMilestone(
    id: 'first_solids',
    title: 'First Solid Food',
    description: 'Baby tries their first puree or baby cereal.',
    category: MilestoneCategory.feeding,
    typicalAgeMonths: 6,
  ),
  BabyMilestone(
    id: 'sits_alone',
    title: 'Sits Without Support',
    description: 'Baby can sit independently for short periods.',
    category: MilestoneCategory.motor,
    typicalAgeMonths: 6,
  ),
  BabyMilestone(
    id: 'responds_to_name',
    title: 'Responds to Name',
    description: 'Baby turns when you call their name.',
    category: MilestoneCategory.cognitive,
    typicalAgeMonths: 6,
  ),

  // 7-9 months
  BabyMilestone(
    id: 'first_crawl',
    title: 'First Crawl',
    description: 'Baby starts crawling on hands and knees.',
    category: MilestoneCategory.motor,
    typicalAgeMonths: 7,
  ),
  BabyMilestone(
    id: 'stranger_anxiety',
    title: 'Stranger Anxiety',
    description: 'Baby shows unease or cries around unfamiliar people.',
    category: MilestoneCategory.social,
    typicalAgeMonths: 7,
  ),
  BabyMilestone(
    id: 'pincer_grasp',
    title: 'Pincer Grasp',
    description: 'Baby picks up small objects with thumb and forefinger.',
    category: MilestoneCategory.motor,
    typicalAgeMonths: 8,
  ),
  BabyMilestone(
    id: 'waves_bye',
    title: 'Waves Bye-Bye',
    description: 'Baby waves hand when someone says goodbye.',
    category: MilestoneCategory.social,
    typicalAgeMonths: 9,
  ),
  BabyMilestone(
    id: 'claps_hands',
    title: 'Claps Hands',
    description: 'Baby claps hands together, often when happy.',
    category: MilestoneCategory.motor,
    typicalAgeMonths: 9,
  ),
  BabyMilestone(
    id: 'pulls_to_stand',
    title: 'Pulls to Stand',
    description: 'Baby pulls themselves up to standing using furniture.',
    category: MilestoneCategory.motor,
    typicalAgeMonths: 9,
  ),

  // 10-12 months
  BabyMilestone(
    id: 'first_word',
    title: 'First Word',
    description: 'Baby says their first meaningful word (e.g. "mama", "dada").',
    category: MilestoneCategory.language,
    typicalAgeMonths: 10,
  ),
  BabyMilestone(
    id: 'cruising',
    title: 'Cruising (Walking Along Furniture)',
    description: 'Baby walks sideways holding onto furniture for support.',
    category: MilestoneCategory.motor,
    typicalAgeMonths: 10,
  ),
  BabyMilestone(
    id: 'first_steps',
    title: 'First Steps',
    description: 'Baby takes their first independent steps — a huge moment!',
    category: MilestoneCategory.motor,
    typicalAgeMonths: 11,
  ),
  BabyMilestone(
    id: 'drinks_from_cup',
    title: 'Drinks from Cup',
    description: 'Baby can drink from a sippy cup or open cup with help.',
    category: MilestoneCategory.feeding,
    typicalAgeMonths: 12,
  ),
  BabyMilestone(
    id: 'follows_simple_instructions',
    title: 'Follows Simple Instructions',
    description: 'Baby understands and responds to "give me" or "come here".',
    category: MilestoneCategory.cognitive,
    typicalAgeMonths: 12,
  ),
  BabyMilestone(
    id: 'plays_peekaboo',
    title: 'Plays Peek-a-Boo',
    description: 'Baby initiates or responds to peek-a-boo games.',
    category: MilestoneCategory.social,
    typicalAgeMonths: 9,
  ),
];

/// Unique age brackets (sorted) from the milestones.
List<String> get milestoneAgeBrackets {
  final months = babyMilestones.map((m) => m.typicalAgeMonths).toSet().toList()
    ..sort();
  return months.map((m) => m == 0 ? 'Newborn' : '$m month${m > 1 ? 's' : ''}').toList();
}

/// Age label for a given month value.
String ageLabel(int months) =>
    months == 0 ? 'Newborn' : '$months month${months > 1 ? 's' : ''}';

/// Lookup a [BabyMilestone] by its [id]. Returns null if not found.
BabyMilestone? milestoneById(String id) {
  for (final m in babyMilestones) {
    if (m.id == id) return m;
  }
  return null;
}
