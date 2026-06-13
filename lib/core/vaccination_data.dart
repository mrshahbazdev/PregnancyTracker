import 'package:flutter/foundation.dart';

/// A single recommended vaccine in the immunization schedule.
@immutable
class VaccineInfo {
  const VaccineInfo({
    required this.id,
    required this.name,
    required this.ageLabel,
    required this.ageMonths,
    required this.description,
  });

  final String id;
  final String name;

  /// Human-readable age label (e.g. "Birth", "2 months").
  final String ageLabel;

  /// Approximate age in months for sorting (0 = birth).
  final int ageMonths;

  final String description;
}

/// WHO/CDC-recommended immunization schedule for newborns (0–12 months).
const vaccineSchedule = <VaccineInfo>[
  // Birth
  VaccineInfo(
    id: 'hepb_birth',
    name: 'Hepatitis B (1st dose)',
    ageLabel: 'Birth',
    ageMonths: 0,
    description: 'Protects against hepatitis B virus infection.',
  ),
  VaccineInfo(
    id: 'bcg',
    name: 'BCG',
    ageLabel: 'Birth',
    ageMonths: 0,
    description: 'Protects against tuberculosis (TB).',
  ),
  VaccineInfo(
    id: 'opv0',
    name: 'OPV (0th dose)',
    ageLabel: 'Birth',
    ageMonths: 0,
    description: 'Oral polio vaccine — birth dose.',
  ),

  // 6 weeks / ~2 months
  VaccineInfo(
    id: 'dtap1',
    name: 'DTaP (1st dose)',
    ageLabel: '2 months',
    ageMonths: 2,
    description:
        'Diphtheria, tetanus & pertussis (whooping cough) combination.',
  ),
  VaccineInfo(
    id: 'ipv1',
    name: 'IPV (1st dose)',
    ageLabel: '2 months',
    ageMonths: 2,
    description: 'Inactivated polio vaccine.',
  ),
  VaccineInfo(
    id: 'hib1',
    name: 'Hib (1st dose)',
    ageLabel: '2 months',
    ageMonths: 2,
    description: 'Haemophilus influenzae type b — meningitis protection.',
  ),
  VaccineInfo(
    id: 'pcv1',
    name: 'PCV (1st dose)',
    ageLabel: '2 months',
    ageMonths: 2,
    description: 'Pneumococcal conjugate vaccine.',
  ),
  VaccineInfo(
    id: 'rv1',
    name: 'Rotavirus (1st dose)',
    ageLabel: '2 months',
    ageMonths: 2,
    description: 'Protects against rotavirus gastroenteritis.',
  ),
  VaccineInfo(
    id: 'hepb2',
    name: 'Hepatitis B (2nd dose)',
    ageLabel: '2 months',
    ageMonths: 2,
    description: 'Second dose of hepatitis B series.',
  ),

  // 4 months
  VaccineInfo(
    id: 'dtap2',
    name: 'DTaP (2nd dose)',
    ageLabel: '4 months',
    ageMonths: 4,
    description: 'Second dose of diphtheria, tetanus & pertussis.',
  ),
  VaccineInfo(
    id: 'ipv2',
    name: 'IPV (2nd dose)',
    ageLabel: '4 months',
    ageMonths: 4,
    description: 'Second dose of inactivated polio.',
  ),
  VaccineInfo(
    id: 'hib2',
    name: 'Hib (2nd dose)',
    ageLabel: '4 months',
    ageMonths: 4,
    description: 'Second dose of Hib.',
  ),
  VaccineInfo(
    id: 'pcv2',
    name: 'PCV (2nd dose)',
    ageLabel: '4 months',
    ageMonths: 4,
    description: 'Second dose of pneumococcal.',
  ),
  VaccineInfo(
    id: 'rv2',
    name: 'Rotavirus (2nd dose)',
    ageLabel: '4 months',
    ageMonths: 4,
    description: 'Second dose of rotavirus.',
  ),

  // 6 months
  VaccineInfo(
    id: 'dtap3',
    name: 'DTaP (3rd dose)',
    ageLabel: '6 months',
    ageMonths: 6,
    description: 'Third dose of diphtheria, tetanus & pertussis.',
  ),
  VaccineInfo(
    id: 'ipv3',
    name: 'IPV (3rd dose)',
    ageLabel: '6 months',
    ageMonths: 6,
    description: 'Third dose of inactivated polio.',
  ),
  VaccineInfo(
    id: 'hib3',
    name: 'Hib (3rd dose)',
    ageLabel: '6 months',
    ageMonths: 6,
    description: 'Third dose of Hib (if needed by brand).',
  ),
  VaccineInfo(
    id: 'pcv3',
    name: 'PCV (3rd dose)',
    ageLabel: '6 months',
    ageMonths: 6,
    description: 'Third dose of pneumococcal.',
  ),
  VaccineInfo(
    id: 'hepb3',
    name: 'Hepatitis B (3rd dose)',
    ageLabel: '6 months',
    ageMonths: 6,
    description: 'Third dose completes the hepatitis B series.',
  ),
  VaccineInfo(
    id: 'flu1',
    name: 'Influenza (1st dose)',
    ageLabel: '6 months',
    ageMonths: 6,
    description: 'First flu vaccine dose (annual, from 6 months).',
  ),

  // 9 months
  VaccineInfo(
    id: 'measles1',
    name: 'Measles / MR (1st dose)',
    ageLabel: '9 months',
    ageMonths: 9,
    description: 'First dose of measles (or measles-rubella) vaccine.',
  ),

  // 12 months
  VaccineInfo(
    id: 'mmr1',
    name: 'MMR (1st dose)',
    ageLabel: '12 months',
    ageMonths: 12,
    description: 'Measles, mumps & rubella combined vaccine.',
  ),
  VaccineInfo(
    id: 'varicella1',
    name: 'Varicella (1st dose)',
    ageLabel: '12 months',
    ageMonths: 12,
    description: 'Chickenpox vaccine.',
  ),
  VaccineInfo(
    id: 'hepa1',
    name: 'Hepatitis A (1st dose)',
    ageLabel: '12 months',
    ageMonths: 12,
    description: 'First dose of hepatitis A series.',
  ),
  VaccineInfo(
    id: 'pcv_booster',
    name: 'PCV (booster)',
    ageLabel: '12 months',
    ageMonths: 12,
    description: 'Pneumococcal booster dose.',
  ),
  VaccineInfo(
    id: 'hib_booster',
    name: 'Hib (booster)',
    ageLabel: '12 months',
    ageMonths: 12,
    description: 'Hib booster dose.',
  ),
];

/// Unique age brackets in schedule order.
List<String> get vaccineAgeBrackets =>
    vaccineSchedule.map((v) => v.ageLabel).toSet().toList();

/// Lookup a [VaccineInfo] by its [id]. Returns null if not found.
VaccineInfo? vaccineById(String id) {
  for (final v in vaccineSchedule) {
    if (v.id == id) return v;
  }
  return null;
}
