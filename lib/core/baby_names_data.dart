import 'package:flutter/foundation.dart';

/// A baby name suggestion. Curated entries are `const`; user-added ones set
/// [isCustom] true and are persisted via the local store.
@immutable
class BabyName {
  const BabyName({
    required this.name,
    required this.gender,
    this.origin = '',
    this.meaning = '',
    this.isCustom = false,
  });

  final String name;

  /// One of: 'girl', 'boy', 'unisex'.
  final String gender;
  final String origin;
  final String meaning;
  final bool isCustom;

  /// Case-insensitive identity used for favourites + de-duplication.
  String get key => name.trim().toLowerCase();

  Map<String, dynamic> toJson() => {
        'name': name,
        'gender': gender,
        'origin': origin,
        'meaning': meaning,
        'isCustom': isCustom,
      };

  factory BabyName.fromJson(Map<String, dynamic> json) => BabyName(
        name: json['name'] as String,
        gender: json['gender'] as String? ?? 'unisex',
        origin: json['origin'] as String? ?? '',
        meaning: json['meaning'] as String? ?? '',
        isCustom: json['isCustom'] as bool? ?? true,
      );
}

const List<String> kNameGenders = ['girl', 'boy', 'unisex'];

/// Curated, alphabetised starter list spanning several origins.
const List<BabyName> kBabyNames = [
  // Girls
  BabyName(name: 'Aaliyah', gender: 'girl', origin: 'Arabic', meaning: 'Exalted, sublime'),
  BabyName(name: 'Amara', gender: 'girl', origin: 'Igbo/Latin', meaning: 'Grace; eternal'),
  BabyName(name: 'Aria', gender: 'girl', origin: 'Italian', meaning: 'Air; melody'),
  BabyName(name: 'Ayesha', gender: 'girl', origin: 'Arabic', meaning: 'Living, prosperous'),
  BabyName(name: 'Chloe', gender: 'girl', origin: 'Greek', meaning: 'Blooming, fertility'),
  BabyName(name: 'Eliana', gender: 'girl', origin: 'Hebrew', meaning: 'God has answered'),
  BabyName(name: 'Fatima', gender: 'girl', origin: 'Arabic', meaning: 'Captivating'),
  BabyName(name: 'Hana', gender: 'girl', origin: 'Japanese/Arabic', meaning: 'Flower; bliss'),
  BabyName(name: 'Isabella', gender: 'girl', origin: 'Italian', meaning: 'Devoted to God'),
  BabyName(name: 'Layla', gender: 'girl', origin: 'Arabic', meaning: 'Night'),
  BabyName(name: 'Maya', gender: 'girl', origin: 'Sanskrit/Greek', meaning: 'Illusion; dream'),
  BabyName(name: 'Mila', gender: 'girl', origin: 'Slavic', meaning: 'Gracious, dear'),
  BabyName(name: 'Olivia', gender: 'girl', origin: 'Latin', meaning: 'Olive tree'),
  BabyName(name: 'Sofia', gender: 'girl', origin: 'Greek', meaning: 'Wisdom'),
  BabyName(name: 'Zara', gender: 'girl', origin: 'Arabic/Hebrew', meaning: 'Radiance, blooming flower'),
  BabyName(name: 'Zoya', gender: 'girl', origin: 'Persian/Slavic', meaning: 'Alive, caring'),

  // Boys
  BabyName(name: 'Aaron', gender: 'boy', origin: 'Hebrew', meaning: 'High mountain; strong'),
  BabyName(name: 'Ahmad', gender: 'boy', origin: 'Arabic', meaning: 'Most praiseworthy'),
  BabyName(name: 'Aydin', gender: 'boy', origin: 'Turkish', meaning: 'Enlightened, bright'),
  BabyName(name: 'Ethan', gender: 'boy', origin: 'Hebrew', meaning: 'Strong, firm'),
  BabyName(name: 'Hamza', gender: 'boy', origin: 'Arabic', meaning: 'Lion, steadfast'),
  BabyName(name: 'Ibrahim', gender: 'boy', origin: 'Arabic', meaning: 'Father of many'),
  BabyName(name: 'Kai', gender: 'boy', origin: 'Hawaiian', meaning: 'Sea'),
  BabyName(name: 'Liam', gender: 'boy', origin: 'Irish', meaning: 'Strong-willed protector'),
  BabyName(name: 'Lucas', gender: 'boy', origin: 'Latin', meaning: 'Light-giving'),
  BabyName(name: 'Musa', gender: 'boy', origin: 'Arabic', meaning: 'Saved from the water'),
  BabyName(name: 'Noah', gender: 'boy', origin: 'Hebrew', meaning: 'Rest, comfort'),
  BabyName(name: 'Omar', gender: 'boy', origin: 'Arabic', meaning: 'Flourishing, long-lived'),
  BabyName(name: 'Rayan', gender: 'boy', origin: 'Arabic', meaning: 'Gates of heaven; lush'),
  BabyName(name: 'Yusuf', gender: 'boy', origin: 'Arabic', meaning: 'God increases'),
  BabyName(name: 'Zayd', gender: 'boy', origin: 'Arabic', meaning: 'Growth, abundance'),

  // Unisex
  BabyName(name: 'Ari', gender: 'unisex', origin: 'Hebrew/Norse', meaning: 'Lion; eagle'),
  BabyName(name: 'Eden', gender: 'unisex', origin: 'Hebrew', meaning: 'Paradise, delight'),
  BabyName(name: 'Noor', gender: 'unisex', origin: 'Arabic', meaning: 'Light'),
  BabyName(name: 'Rio', gender: 'unisex', origin: 'Spanish', meaning: 'River'),
  BabyName(name: 'Sami', gender: 'unisex', origin: 'Arabic', meaning: 'Elevated, sublime'),
  BabyName(name: 'Sky', gender: 'unisex', origin: 'English', meaning: 'The sky'),
];
