import 'package:flutter/foundation.dart';

/// How safe an item is during pregnancy. Educational only — not medical advice.
enum SafetyRating { safe, caution, avoid }

/// Broad category so the list can be filtered.
enum SafetyCategory { food, drink, medicine }

@immutable
class SafetyItem {
  const SafetyItem({
    required this.name,
    required this.category,
    required this.rating,
    required this.note,
  });

  final String name;
  final SafetyCategory category;
  final SafetyRating rating;
  final String note;

  /// Lower-cased name, handy for case-insensitive search/sort.
  String get key => name.toLowerCase();
}

/// Curated, general-guidance list. Values reflect common public-health advice
/// (e.g. CDC/NHS/ACOG style guidance) and are intentionally conservative.
const List<SafetyItem> kSafetyItems = [
  // ---- Food ----
  SafetyItem(
    name: 'Cooked salmon',
    category: SafetyCategory.food,
    rating: SafetyRating.safe,
    note: 'Low-mercury fish; great source of omega-3. Aim for 2 servings/week.',
  ),
  SafetyItem(
    name: 'Shrimp (cooked)',
    category: SafetyCategory.food,
    rating: SafetyRating.safe,
    note: 'Low-mercury seafood; safe when fully cooked.',
  ),
  SafetyItem(
    name: 'Eggs (fully cooked)',
    category: SafetyCategory.food,
    rating: SafetyRating.safe,
    note: 'Cook until firm whites and yolks to avoid salmonella.',
  ),
  SafetyItem(
    name: 'Pasteurised hard cheese',
    category: SafetyCategory.food,
    rating: SafetyRating.safe,
    note: 'Hard cheeses (cheddar, parmesan) are fine.',
  ),
  SafetyItem(
    name: 'Yogurt (pasteurised)',
    category: SafetyCategory.food,
    rating: SafetyRating.safe,
    note: 'Good source of calcium and probiotics.',
  ),
  SafetyItem(
    name: 'Deli / luncheon meat',
    category: SafetyCategory.food,
    rating: SafetyRating.caution,
    note: 'Listeria risk — heat until steaming hot before eating.',
  ),
  SafetyItem(
    name: 'Soft cheese (unpasteurised)',
    category: SafetyCategory.food,
    rating: SafetyRating.caution,
    note: 'Brie, feta, blue — only if made from pasteurised milk.',
  ),
  SafetyItem(
    name: 'Tuna (albacore/steak)',
    category: SafetyCategory.food,
    rating: SafetyRating.caution,
    note: 'Higher mercury — limit to about 1 serving per week.',
  ),
  SafetyItem(
    name: 'Raw sprouts',
    category: SafetyCategory.food,
    rating: SafetyRating.caution,
    note: 'Cook thoroughly; raw sprouts can carry bacteria.',
  ),
  SafetyItem(
    name: 'Liver / pâté',
    category: SafetyCategory.food,
    rating: SafetyRating.caution,
    note: 'Very high vitamin A — eat only occasionally and in small amounts.',
  ),
  SafetyItem(
    name: 'Raw / undercooked meat',
    category: SafetyCategory.food,
    rating: SafetyRating.avoid,
    note: 'Toxoplasmosis & bacteria risk — cook meat thoroughly.',
  ),
  SafetyItem(
    name: 'Sushi (raw fish)',
    category: SafetyCategory.food,
    rating: SafetyRating.avoid,
    note: 'Avoid raw fish; cooked rolls are okay.',
  ),
  SafetyItem(
    name: 'High-mercury fish',
    category: SafetyCategory.food,
    rating: SafetyRating.avoid,
    note: 'Avoid shark, swordfish, king mackerel, marlin.',
  ),
  SafetyItem(
    name: 'Raw shellfish (oysters)',
    category: SafetyCategory.food,
    rating: SafetyRating.avoid,
    note: 'Raw oysters/clams can cause food poisoning — eat cooked.',
  ),
  // ---- Drink ----
  SafetyItem(
    name: 'Water',
    category: SafetyCategory.drink,
    rating: SafetyRating.safe,
    note: 'Stay well hydrated — aim for plenty throughout the day.',
  ),
  SafetyItem(
    name: 'Milk (pasteurised)',
    category: SafetyCategory.drink,
    rating: SafetyRating.safe,
    note: 'Good source of calcium; choose pasteurised.',
  ),
  SafetyItem(
    name: 'Coffee / caffeine',
    category: SafetyCategory.drink,
    rating: SafetyRating.caution,
    note: 'Keep caffeine under ~200 mg/day (about one mug of coffee).',
  ),
  SafetyItem(
    name: 'Herbal tea',
    category: SafetyCategory.drink,
    rating: SafetyRating.caution,
    note: 'Some herbs aren\'t recommended — limit and check the type.',
  ),
  SafetyItem(
    name: 'Unpasteurised juice / milk',
    category: SafetyCategory.drink,
    rating: SafetyRating.avoid,
    note: 'Can carry harmful bacteria — choose pasteurised.',
  ),
  SafetyItem(
    name: 'Alcohol',
    category: SafetyCategory.drink,
    rating: SafetyRating.avoid,
    note: 'No known safe amount — best avoided entirely in pregnancy.',
  ),
  SafetyItem(
    name: 'Energy drinks',
    category: SafetyCategory.drink,
    rating: SafetyRating.avoid,
    note: 'High caffeine + other stimulants — avoid.',
  ),
  // ---- Medicine ----
  SafetyItem(
    name: 'Paracetamol (acetaminophen)',
    category: SafetyCategory.medicine,
    rating: SafetyRating.safe,
    note: 'Usually first choice for pain/fever — use the lowest effective dose.',
  ),
  SafetyItem(
    name: 'Prenatal vitamins',
    category: SafetyCategory.medicine,
    rating: SafetyRating.safe,
    note: 'Recommended — especially folic acid and iron.',
  ),
  SafetyItem(
    name: 'Folic acid',
    category: SafetyCategory.medicine,
    rating: SafetyRating.safe,
    note: 'Important early on to help prevent neural-tube defects.',
  ),
  SafetyItem(
    name: 'Antacids',
    category: SafetyCategory.medicine,
    rating: SafetyRating.caution,
    note: 'Many are okay for heartburn — confirm the type with your provider.',
  ),
  SafetyItem(
    name: 'Antihistamines',
    category: SafetyCategory.medicine,
    rating: SafetyRating.caution,
    note: 'Some are considered okay — check with your provider/pharmacist first.',
  ),
  SafetyItem(
    name: 'Ibuprofen / NSAIDs',
    category: SafetyCategory.medicine,
    rating: SafetyRating.avoid,
    note: 'Generally avoided, especially in the third trimester — ask first.',
  ),
  SafetyItem(
    name: 'Aspirin (unprescribed)',
    category: SafetyCategory.medicine,
    rating: SafetyRating.avoid,
    note: 'Avoid unless specifically prescribed by your doctor.',
  ),
  SafetyItem(
    name: 'Isotretinoin (acne)',
    category: SafetyCategory.medicine,
    rating: SafetyRating.avoid,
    note: 'Causes serious birth defects — must not be used in pregnancy.',
  ),
];
