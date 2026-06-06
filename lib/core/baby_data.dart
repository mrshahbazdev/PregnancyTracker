import 'package:flutter/foundation.dart';

/// Week-by-week fetal development data used across the Today and 3D screens.
@immutable
class WeekInfo {
  const WeekInfo({
    required this.week,
    required this.sizeComparison,
    required this.lengthCm,
    required this.weightG,
    required this.headline,
    required this.detail,
  });

  final int week;
  final String sizeComparison;
  final double lengthCm;
  final int weightG;
  final String headline;
  final String detail;
}

/// Curated, medically-reviewed-style summaries. Figures are typical averages.
/// NOTE: This content is educational only and not medical advice.
const Map<int, WeekInfo> kBabyData = {
  4: WeekInfo(
      week: 4,
      sizeComparison: 'Poppy seed',
      lengthCm: 0.1,
      weightG: 0,
      headline: 'Implantation complete',
      detail:
          'The embryo has implanted and the placenta is starting to form. The neural tube, which becomes the brain and spinal cord, is developing.'),
  5: WeekInfo(
      week: 5,
      sizeComparison: 'Sesame seed',
      lengthCm: 0.3,
      weightG: 0,
      headline: 'Heart begins to form',
      detail:
          'The tiny heart tube starts to beat this week. Major organs and the circulatory system are beginning to take shape.'),
  6: WeekInfo(
      week: 6,
      sizeComparison: 'Lentil',
      lengthCm: 0.5,
      weightG: 0,
      headline: 'Heartbeat detectable',
      detail:
          'A heartbeat may be visible on an early ultrasound. Tiny buds that will become arms and legs are appearing.'),
  7: WeekInfo(
      week: 7,
      sizeComparison: 'Blueberry',
      lengthCm: 1.0,
      weightG: 1,
      headline: 'Brain growing fast',
      detail:
          'The brain is forming around 100 new cells per minute. Hands and feet are emerging as small paddles.'),
  8: WeekInfo(
      week: 8,
      sizeComparison: 'Raspberry',
      lengthCm: 1.6,
      weightG: 1,
      headline: 'Now a fetus',
      detail:
          'Webbed fingers and toes are forming. The baby is starting to make small, spontaneous movements.'),
  9: WeekInfo(
      week: 9,
      sizeComparison: 'Cherry',
      lengthCm: 2.3,
      weightG: 2,
      headline: 'Tiny muscles forming',
      detail:
          'Essential organs are in place and basic facial features are more defined. Muscles are beginning to develop.'),
  10: WeekInfo(
      week: 10,
      sizeComparison: 'Strawberry',
      lengthCm: 3.1,
      weightG: 4,
      headline: 'Vital organs working',
      detail:
          'Vital organs such as kidneys and liver are functioning. Tiny nails start to form on fingers and toes.'),
  11: WeekInfo(
      week: 11,
      sizeComparison: 'Lime',
      lengthCm: 4.1,
      weightG: 7,
      headline: 'Stretching and moving',
      detail:
          'The baby can stretch, and tooth buds are appearing. The head is still about half the length of the body.'),
  12: WeekInfo(
      week: 12,
      sizeComparison: 'Plum',
      lengthCm: 5.4,
      weightG: 14,
      headline: 'Reflexes developing',
      detail:
          'Fingers can open and close and the baby may begin to develop reflexes. Most major systems are formed.'),
  13: WeekInfo(
      week: 13,
      sizeComparison: 'Peapod',
      lengthCm: 7.4,
      weightG: 23,
      headline: 'Welcome to 2nd trimester',
      detail:
          'Fingerprints are forming and vocal cords are developing. The risk of complications drops noticeably this week.'),
  14: WeekInfo(
      week: 14,
      sizeComparison: 'Lemon',
      lengthCm: 8.7,
      weightG: 43,
      headline: 'Facial expressions',
      detail:
          'The baby can squint, frown and grimace. The liver and spleen begin to do their jobs.'),
  15: WeekInfo(
      week: 15,
      sizeComparison: 'Apple',
      lengthCm: 10.1,
      weightG: 70,
      headline: 'Sensing light',
      detail:
          'Though eyelids are fused, the baby can sense bright light. Bones are getting stronger.'),
  16: WeekInfo(
      week: 16,
      sizeComparison: 'Avocado',
      lengthCm: 11.6,
      weightG: 100,
      headline: 'Listening in',
      detail:
          'Tiny bones in the ears are in place, so the baby may start to hear your voice. Eyes can move slowly.'),
  17: WeekInfo(
      week: 17,
      sizeComparison: 'Turnip',
      lengthCm: 13.0,
      weightG: 140,
      headline: 'Building fat',
      detail:
          'The baby is starting to add fat stores for energy and warmth. The umbilical cord is growing stronger.'),
  18: WeekInfo(
      week: 18,
      sizeComparison: 'Bell pepper',
      lengthCm: 14.2,
      weightG: 190,
      headline: 'Yawns and hiccups',
      detail:
          'The baby may yawn and hiccup. Nerves are forming protective myelin coatings.'),
  19: WeekInfo(
      week: 19,
      sizeComparison: 'Mango',
      lengthCm: 15.3,
      weightG: 240,
      headline: 'Vernix coating',
      detail:
          'A waxy coating called vernix caseosa protects the skin. You may start to feel first flutters of movement.'),
  20: WeekInfo(
      week: 20,
      sizeComparison: 'Banana',
      lengthCm: 25.6,
      weightG: 300,
      headline: 'Halfway there!',
      detail:
          'You are at the midpoint. The anatomy scan around now checks growth and development in detail.'),
  21: WeekInfo(
      week: 21,
      sizeComparison: 'Carrot',
      lengthCm: 26.7,
      weightG: 360,
      headline: 'Coordinated kicks',
      detail:
          'Movements are becoming more coordinated and noticeable. The baby swallows amniotic fluid daily.'),
  22: WeekInfo(
      week: 22,
      sizeComparison: 'Spaghetti squash',
      lengthCm: 27.8,
      weightG: 430,
      headline: 'Developing senses',
      detail:
          'Lips, eyelids and eyebrows are more distinct. The baby is developing a sense of touch.'),
  23: WeekInfo(
      week: 23,
      sizeComparison: 'Grapefruit',
      lengthCm: 28.9,
      weightG: 501,
      headline: 'Hearing your world',
      detail:
          'The baby can hear sounds from outside, including your voice and heartbeat. Skin is still wrinkled.'),
  24: WeekInfo(
      week: 24,
      sizeComparison: 'Corn cob',
      lengthCm: 30.0,
      weightG: 600,
      headline: 'Viability milestone',
      detail:
          'Lungs are developing branches and cells that produce surfactant. This is an important viability milestone.'),
  25: WeekInfo(
      week: 25,
      sizeComparison: 'Rutabaga',
      lengthCm: 34.6,
      weightG: 660,
      headline: 'Responding to voice',
      detail:
          'The baby may respond to your voice with movement. Hair is gaining color and texture.'),
  26: WeekInfo(
      week: 26,
      sizeComparison: 'Scallion bunch',
      lengthCm: 35.6,
      weightG: 760,
      headline: 'Eyes opening',
      detail:
          'Eyes begin to open and the baby blinks. Brain wave activity for hearing and sight is starting.'),
  27: WeekInfo(
      week: 27,
      sizeComparison: 'Cauliflower',
      lengthCm: 36.6,
      weightG: 875,
      headline: 'Hello 3rd trimester',
      detail:
          'The baby sleeps and wakes on a schedule and may have hiccups you can feel. Lungs continue to mature.'),
  28: WeekInfo(
      week: 28,
      sizeComparison: 'Eggplant',
      lengthCm: 37.6,
      weightG: 1005,
      headline: 'Dreaming brain',
      detail:
          'The baby can dream (REM sleep) and add billions of neurons. Eyelashes are now present.'),
  29: WeekInfo(
      week: 29,
      sizeComparison: 'Butternut squash',
      lengthCm: 38.6,
      weightG: 1153,
      headline: 'Stronger kicks',
      detail:
          'Muscles and lungs keep maturing and kicks feel stronger. Bones need plenty of calcium now.'),
  30: WeekInfo(
      week: 30,
      sizeComparison: 'Cabbage',
      lengthCm: 39.9,
      weightG: 1319,
      headline: 'Brain getting wrinkly',
      detail:
          'The brain is developing grooves and ridges to fit more tissue. Bone marrow now makes red blood cells.'),
  31: WeekInfo(
      week: 31,
      sizeComparison: 'Coconut',
      lengthCm: 41.1,
      weightG: 1502,
      headline: 'Processing information',
      detail:
          'The baby can process information and track light. All five senses are working.'),
  32: WeekInfo(
      week: 32,
      sizeComparison: 'Jicama',
      lengthCm: 42.4,
      weightG: 1702,
      headline: 'Practicing breathing',
      detail:
          'The baby practices breathing movements. Toenails and fingernails are fully formed.'),
  33: WeekInfo(
      week: 33,
      sizeComparison: 'Pineapple',
      lengthCm: 43.7,
      weightG: 1918,
      headline: 'Skull still soft',
      detail:
          'The skull bones stay flexible to ease delivery. The baby can detect light through the womb.'),
  34: WeekInfo(
      week: 34,
      sizeComparison: 'Cantaloupe',
      lengthCm: 45.0,
      weightG: 2146,
      headline: 'Lungs nearly ready',
      detail:
          'Lungs are nearly mature. The central nervous system and immune system keep developing.'),
  35: WeekInfo(
      week: 35,
      sizeComparison: 'Honeydew melon',
      lengthCm: 46.2,
      weightG: 2383,
      headline: 'Filling out',
      detail:
          'The baby is rapidly gaining weight and filling out. Kidneys are fully developed.'),
  36: WeekInfo(
      week: 36,
      sizeComparison: 'Romaine lettuce',
      lengthCm: 47.4,
      weightG: 2622,
      headline: 'Getting into position',
      detail:
          'The baby is likely settling head-down. It is shedding much of the downy hair and vernix.'),
  37: WeekInfo(
      week: 37,
      sizeComparison: 'Swiss chard',
      lengthCm: 48.6,
      weightG: 2859,
      headline: 'Early term',
      detail:
          'The baby is now early term and practicing breathing, sucking and gripping in preparation for birth.'),
  38: WeekInfo(
      week: 38,
      sizeComparison: 'Leek',
      lengthCm: 49.8,
      weightG: 3083,
      headline: 'Firm grasp',
      detail:
          'The baby has a firm grasp and organs are ready for life outside the womb. Brain and lungs keep maturing.'),
  39: WeekInfo(
      week: 39,
      sizeComparison: 'Watermelon (small)',
      lengthCm: 50.7,
      weightG: 3288,
      headline: 'Full term',
      detail:
          'The baby is full term. A layer of fat continues to develop to help control body temperature after birth.'),
  40: WeekInfo(
      week: 40,
      sizeComparison: 'Pumpkin (small)',
      lengthCm: 51.2,
      weightG: 3462,
      headline: 'Due date!',
      detail:
          'Your baby is ready to meet you. Only about 1 in 20 babies arrive exactly on the due date, so be patient.'),
};

WeekInfo weekInfoFor(int week) {
  final clamped = week.clamp(4, 40);
  return kBabyData[clamped] ?? kBabyData[40]!;
}
