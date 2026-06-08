import 'package:flutter/foundation.dart';

/// Theme of an affirmation so the list can be filtered.
enum AffirmationCategory { calm, strength, birth, bonding }

extension AffirmationCategoryLabel on AffirmationCategory {
  String get label => switch (this) {
        AffirmationCategory.calm => 'Calm',
        AffirmationCategory.strength => 'Strength',
        AffirmationCategory.birth => 'Birth',
        AffirmationCategory.bonding => 'Bonding',
      };
}

/// A single positive affirmation for pregnancy.
@immutable
class Affirmation {
  const Affirmation({
    required this.id,
    required this.text,
    required this.category,
  });

  final String id;
  final String text;
  final AffirmationCategory category;
}

/// Curated, calming affirmations. Educational/well-being content only.
const List<Affirmation> kAffirmations = [
  // ---- Calm ----
  Affirmation(
      id: 'c1',
      text: 'I breathe in calm and breathe out tension.',
      category: AffirmationCategory.calm),
  Affirmation(
      id: 'c2',
      text: 'My body knows how to nurture my baby.',
      category: AffirmationCategory.calm),
  Affirmation(
      id: 'c3',
      text: 'It is safe for me to rest and slow down today.',
      category: AffirmationCategory.calm),
  Affirmation(
      id: 'c4',
      text: 'Each day I let go of worry and welcome peace.',
      category: AffirmationCategory.calm),
  Affirmation(
      id: 'c5',
      text: 'I trust the timing of my pregnancy.',
      category: AffirmationCategory.calm),
  // ---- Strength ----
  Affirmation(
      id: 's1',
      text: 'My body is strong, capable, and made for this.',
      category: AffirmationCategory.strength),
  Affirmation(
      id: 's2',
      text: 'I am doing an amazing job growing my baby.',
      category: AffirmationCategory.strength),
  Affirmation(
      id: 's3',
      text: 'I am resilient, and I grow stronger every day.',
      category: AffirmationCategory.strength),
  Affirmation(
      id: 's4',
      text: 'I honour my body for all that it is doing.',
      category: AffirmationCategory.strength),
  Affirmation(
      id: 's5',
      text: 'Every change in my body has a purpose.',
      category: AffirmationCategory.strength),
  // ---- Birth ----
  Affirmation(
      id: 'b1',
      text: 'I trust my body to birth my baby in its own way.',
      category: AffirmationCategory.birth),
  Affirmation(
      id: 'b2',
      text: 'Each surge brings me closer to meeting my baby.',
      category: AffirmationCategory.birth),
  Affirmation(
      id: 'b3',
      text: 'I am surrounded by support and care.',
      category: AffirmationCategory.birth),
  Affirmation(
      id: 'b4',
      text: 'I welcome my birth with courage and openness.',
      category: AffirmationCategory.birth),
  Affirmation(
      id: 'b5',
      text: 'I can do hard things, one breath at a time.',
      category: AffirmationCategory.birth),
  // ---- Bonding ----
  Affirmation(
      id: 'o1',
      text: 'My baby feels my love every single day.',
      category: AffirmationCategory.bonding),
  Affirmation(
      id: 'o2',
      text: 'I am already a wonderful parent to my baby.',
      category: AffirmationCategory.bonding),
  Affirmation(
      id: 'o3',
      text: 'My baby and I are growing together.',
      category: AffirmationCategory.bonding),
  Affirmation(
      id: 'o4',
      text: 'I cherish this special time with my baby.',
      category: AffirmationCategory.bonding),
  Affirmation(
      id: 'o5',
      text: 'The bond between my baby and me grows stronger each day.',
      category: AffirmationCategory.bonding),
];
