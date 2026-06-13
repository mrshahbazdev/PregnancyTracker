import 'package:flutter/material.dart';

@immutable
class NutrientInfo {
  const NutrientInfo({
    required this.name,
    required this.icon,
    required this.dailyAmount,
    required this.unit,
    required this.sources,
    required this.color,
  });

  final String name;
  final IconData icon;
  final String dailyAmount;
  final String unit;
  final List<String> sources;
  final Color color;
}

const kPregnancyNutrients = [
  NutrientInfo(
    name: 'Folic Acid',
    icon: Icons.eco_rounded,
    dailyAmount: '600',
    unit: 'mcg',
    sources: ['Spinach', 'Lentils', 'Avocado', 'Fortified cereals'],
    color: Color(0xFF66BB6A),
  ),
  NutrientInfo(
    name: 'Iron',
    icon: Icons.fitness_center_rounded,
    dailyAmount: '27',
    unit: 'mg',
    sources: ['Red meat', 'Beans', 'Tofu', 'Dark leafy greens'],
    color: Color(0xFFEF5350),
  ),
  NutrientInfo(
    name: 'Calcium',
    icon: Icons.energy_savings_leaf_rounded,
    dailyAmount: '1000',
    unit: 'mg',
    sources: ['Milk', 'Yogurt', 'Cheese', 'Almonds', 'Broccoli'],
    color: Color(0xFF42A5F5),
  ),
  NutrientInfo(
    name: 'Protein',
    icon: Icons.restaurant_rounded,
    dailyAmount: '71',
    unit: 'g',
    sources: ['Chicken', 'Fish', 'Eggs', 'Greek yogurt', 'Nuts'],
    color: Color(0xFFFF7043),
  ),
  NutrientInfo(
    name: 'DHA/Omega-3',
    icon: Icons.water_drop_rounded,
    dailyAmount: '200-300',
    unit: 'mg',
    sources: ['Salmon', 'Sardines', 'Walnuts', 'Chia seeds'],
    color: Color(0xFF26C6DA),
  ),
  NutrientInfo(
    name: 'Vitamin D',
    icon: Icons.wb_sunny_rounded,
    dailyAmount: '600',
    unit: 'IU',
    sources: ['Sunlight', 'Fortified milk', 'Eggs', 'Fatty fish'],
    color: Color(0xFFFFCA28),
  ),
];

@immutable
class TrimesterTip {
  const TrimesterTip({
    required this.title,
    required this.foods,
    required this.avoid,
  });

  final String title;
  final List<String> foods;
  final List<String> avoid;
}

const kTrimesterTips = {
  1: TrimesterTip(
    title: '1st Trimester (Weeks 1–12)',
    foods: [
      'Ginger tea for nausea',
      'Small, frequent meals',
      'Crackers before getting up',
      'Folate-rich foods (spinach, lentils)',
      'Vitamin B6 foods (bananas, chickpeas)',
    ],
    avoid: [
      'Raw or undercooked meat/eggs',
      'Unpasteurized dairy',
      'High-mercury fish (swordfish, tilefish)',
      'Excess caffeine (>200mg/day)',
      'Alcohol',
    ],
  ),
  2: TrimesterTip(
    title: '2nd Trimester (Weeks 13–26)',
    foods: [
      'Iron-rich foods (lean meats, beans)',
      'Calcium (dairy, leafy greens)',
      'Omega-3 fatty acids (salmon, walnuts)',
      'Fiber (whole grains, fruits)',
      'Protein-rich snacks',
    ],
    avoid: [
      'Raw seafood / sushi',
      'Deli meats (unless heated)',
      'Excess sugar and processed foods',
      'Soft cheeses (unless pasteurized)',
      'Energy drinks',
    ],
  ),
  3: TrimesterTip(
    title: '3rd Trimester (Weeks 27–40)',
    foods: [
      'Smaller, more frequent meals',
      'High-fiber foods to prevent constipation',
      'Vitamin K foods (kale, broccoli)',
      'Dates (may help with labor prep)',
      'Hydration (10+ glasses water daily)',
    ],
    avoid: [
      'Large heavy meals (heartburn)',
      'Excess salt (swelling)',
      'Raw sprouts',
      'Licorice root',
      'Alcohol',
    ],
  ),
};

int trimesterFromWeek(int week) {
  if (week < 13) return 1;
  if (week < 27) return 2;
  return 3;
}
