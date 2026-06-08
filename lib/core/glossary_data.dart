import 'package:flutter/foundation.dart';

/// Broad grouping so the glossary can be filtered.
enum GlossaryCategory { medical, tests, labor, baby }

extension GlossaryCategoryLabel on GlossaryCategory {
  String get label => switch (this) {
        GlossaryCategory.medical => 'Medical',
        GlossaryCategory.tests => 'Tests & scans',
        GlossaryCategory.labor => 'Labor & birth',
        GlossaryCategory.baby => 'Baby',
      };
}

/// A single pregnancy/labor term explained in plain language.
@immutable
class GlossaryTerm {
  const GlossaryTerm({
    required this.term,
    required this.category,
    required this.definition,
  });

  final String term;
  final GlossaryCategory category;
  final String definition;

  /// Lower-cased term, handy for case-insensitive search/sort.
  String get key => term.toLowerCase();
}

/// Curated, educational glossary. Plain-language explanations only — not
/// medical advice.
const List<GlossaryTerm> kGlossaryTerms = [
  // ---- Medical / body ----
  GlossaryTerm(
    term: 'Braxton Hicks',
    category: GlossaryCategory.medical,
    definition:
        'Practice contractions — irregular, usually painless tightening of the '
        'womb. Unlike real labor they don\u2019t get stronger or closer together.',
  ),
  GlossaryTerm(
    term: 'Fundal height',
    category: GlossaryCategory.medical,
    definition:
        'The distance (in cm) from the top of the womb to the pubic bone. After '
        '~20 weeks it roughly matches the number of weeks pregnant.',
  ),
  GlossaryTerm(
    term: 'Trimester',
    category: GlossaryCategory.medical,
    definition:
        'One of the three stages of pregnancy: first (weeks 1\u201313), second '
        '(14\u201327), and third (28\u2013birth).',
  ),
  GlossaryTerm(
    term: 'Placenta',
    category: GlossaryCategory.medical,
    definition:
        'The organ that grows in the womb to supply the baby with oxygen and '
        'nutrients through the umbilical cord, and remove waste.',
  ),
  GlossaryTerm(
    term: 'Amniotic fluid',
    category: GlossaryCategory.medical,
    definition:
        'The fluid surrounding the baby in the womb that cushions and protects '
        'it. Its release ("water breaking") can be a sign labor is starting.',
  ),
  GlossaryTerm(
    term: 'Preeclampsia',
    category: GlossaryCategory.medical,
    definition:
        'A pregnancy condition with high blood pressure and protein in the '
        'urine. Warning signs include bad headaches, vision changes and sudden '
        'swelling — contact your provider if these appear.',
  ),
  GlossaryTerm(
    term: 'Gestational diabetes',
    category: GlossaryCategory.medical,
    definition:
        'High blood sugar that develops during pregnancy. Often managed with '
        'diet and monitoring; usually resolves after birth.',
  ),
  GlossaryTerm(
    term: 'Linea nigra',
    category: GlossaryCategory.medical,
    definition:
        'A dark vertical line that can appear down the belly during pregnancy '
        'due to hormonal changes. It usually fades after birth.',
  ),
  GlossaryTerm(
    term: 'Colostrum',
    category: GlossaryCategory.baby,
    definition:
        'The first thick, yellowish milk the breasts make in late pregnancy and '
        'the first days after birth. It\u2019s rich in antibodies for the baby.',
  ),
  GlossaryTerm(
    term: 'Quickening',
    category: GlossaryCategory.baby,
    definition:
        'The first fluttery baby movements a mother feels, often around weeks '
        '16\u201325.',
  ),
  GlossaryTerm(
    term: 'Vernix',
    category: GlossaryCategory.baby,
    definition:
        'The white, waxy coating that protects the baby\u2019s skin in the womb. '
        'Some may still be present at birth.',
  ),
  GlossaryTerm(
    term: 'Meconium',
    category: GlossaryCategory.baby,
    definition:
        'A baby\u2019s first stool — dark and sticky. If passed before birth it '
        'can be a sign the baby needs closer monitoring.',
  ),
  // ---- Tests & scans ----
  GlossaryTerm(
    term: 'Dating scan',
    category: GlossaryCategory.tests,
    definition:
        'An early ultrasound (around weeks 8\u201314) that confirms the due date '
        'and checks the baby\u2019s heartbeat.',
  ),
  GlossaryTerm(
    term: 'Anomaly scan',
    category: GlossaryCategory.tests,
    definition:
        'A detailed ultrasound around weeks 18\u201322 that checks the baby\u2019s '
        'growth and organ development.',
  ),
  GlossaryTerm(
    term: 'NIPT',
    category: GlossaryCategory.tests,
    definition:
        'Non-Invasive Prenatal Test — a blood test that screens for certain '
        'chromosomal conditions using the baby\u2019s DNA in the mother\u2019s blood.',
  ),
  GlossaryTerm(
    term: 'Glucose test (GTT)',
    category: GlossaryCategory.tests,
    definition:
        'A test (often weeks 24\u201328) that checks how your body handles sugar '
        'to screen for gestational diabetes.',
  ),
  GlossaryTerm(
    term: 'GBS test',
    category: GlossaryCategory.tests,
    definition:
        'A swab (around weeks 36\u201337) for Group B Strep bacteria. If positive, '
        'antibiotics may be given during labor to protect the baby.',
  ),
  GlossaryTerm(
    term: 'Amniocentesis',
    category: GlossaryCategory.tests,
    definition:
        'A test that takes a small sample of amniotic fluid to check for genetic '
        'conditions. Usually offered when screening suggests higher risk.',
  ),
  // ---- Labor & birth ----
  GlossaryTerm(
    term: 'Dilation',
    category: GlossaryCategory.labor,
    definition:
        'How open the cervix is, measured 0\u201310 cm. Full dilation (10 cm) means '
        'it\u2019s time to push.',
  ),
  GlossaryTerm(
    term: 'Effacement',
    category: GlossaryCategory.labor,
    definition:
        'The thinning and shortening of the cervix before birth, measured as a '
        'percentage (0\u2013100%).',
  ),
  GlossaryTerm(
    term: 'Epidural',
    category: GlossaryCategory.labor,
    definition:
        'A pain-relief injection in the lower back that numbs the lower body '
        'during labor while you stay awake.',
  ),
  GlossaryTerm(
    term: 'Mucus plug',
    category: GlossaryCategory.labor,
    definition:
        'A protective plug of mucus that seals the cervix. Losing it (sometimes '
        'a "show") can be an early sign labor is approaching.',
  ),
  GlossaryTerm(
    term: 'Show (bloody show)',
    category: GlossaryCategory.labor,
    definition:
        'Blood-tinged mucus passed as the cervix starts to open near labor. '
        'Small amounts are normal; heavy bleeding is not — call your provider.',
  ),
  GlossaryTerm(
    term: '5-1-1 rule',
    category: GlossaryCategory.labor,
    definition:
        'A common guide for when to go to hospital: contractions about 5 minutes '
        'apart, each lasting ~1 minute, continuing for 1 hour.',
  ),
  GlossaryTerm(
    term: 'Induction',
    category: GlossaryCategory.labor,
    definition:
        'Starting labor with medical help (e.g. medication) rather than waiting '
        'for it to begin on its own.',
  ),
  GlossaryTerm(
    term: 'C-section',
    category: GlossaryCategory.labor,
    definition:
        'Cesarean birth — delivering the baby through a surgical cut in the '
        'belly and womb, planned or as an emergency.',
  ),
  GlossaryTerm(
    term: 'Episiotomy',
    category: GlossaryCategory.labor,
    definition:
        'A small surgical cut sometimes made to widen the vaginal opening during '
        'birth. Repaired with stitches afterwards.',
  ),
  GlossaryTerm(
    term: 'Apgar score',
    category: GlossaryCategory.baby,
    definition:
        'A quick check of a newborn\u2019s color, heart rate, reflexes, muscle '
        'tone and breathing at 1 and 5 minutes after birth, scored 0\u201310.',
  ),
  GlossaryTerm(
    term: 'Skin-to-skin',
    category: GlossaryCategory.baby,
    definition:
        'Placing the naked baby on the mother\u2019s bare chest right after birth '
        'to help bonding, warmth, and feeding.',
  ),
];
