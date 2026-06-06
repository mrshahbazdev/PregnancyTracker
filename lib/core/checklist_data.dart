import '../models/log_entry.dart';

/// Identifiers for the built-in checklists.
class ChecklistKind {
  static const hospitalBag = 'hospital_bag';
  static const todo = 'todo';
}

ChecklistItem _item(String id, String label, String category) =>
    ChecklistItem(id: id, label: label, category: category);

/// Preset hospital-bag items, grouped by who they're for.
const List<ChecklistItem> _hospitalBag = [
  ChecklistItem(id: 'hb_mom_gown', label: 'Comfortable nightgown / robe', category: 'Mom'),
  ChecklistItem(id: 'hb_mom_slippers', label: 'Non-slip slippers & warm socks', category: 'Mom'),
  ChecklistItem(id: 'hb_mom_toiletries', label: 'Toiletries & lip balm', category: 'Mom'),
  ChecklistItem(id: 'hb_mom_pads', label: 'Maternity pads', category: 'Mom'),
  ChecklistItem(id: 'hb_mom_nursing_bra', label: 'Nursing bras & breast pads', category: 'Mom'),
  ChecklistItem(id: 'hb_mom_going_home', label: 'Loose going-home outfit', category: 'Mom'),
  ChecklistItem(id: 'hb_mom_charger', label: 'Phone & charger', category: 'Mom'),
  ChecklistItem(id: 'hb_baby_onesies', label: 'Onesies / bodysuits (2–3)', category: 'Baby'),
  ChecklistItem(id: 'hb_baby_swaddle', label: 'Swaddle blankets', category: 'Baby'),
  ChecklistItem(id: 'hb_baby_hat_mittens', label: 'Hat & mittens', category: 'Baby'),
  ChecklistItem(id: 'hb_baby_diapers', label: 'Newborn diapers & wipes', category: 'Baby'),
  ChecklistItem(id: 'hb_baby_carseat', label: 'Installed car seat', category: 'Baby'),
  ChecklistItem(id: 'hb_doc_id', label: 'ID & insurance card', category: 'Documents'),
  ChecklistItem(id: 'hb_doc_notes', label: 'Maternity notes / records', category: 'Documents'),
  ChecklistItem(id: 'hb_doc_birthplan', label: 'Birth plan copy', category: 'Documents'),
  ChecklistItem(id: 'hb_partner_snacks', label: 'Snacks & water', category: 'Partner'),
  ChecklistItem(id: 'hb_partner_change', label: 'Change of clothes for partner', category: 'Partner'),
];

/// Preset pregnancy to-do items, loosely ordered by trimester.
const List<ChecklistItem> _todo = [
  ChecklistItem(id: 'td_vitamins', label: 'Start prenatal vitamins (folic acid)', category: '1st trimester'),
  ChecklistItem(id: 'td_book_provider', label: 'Choose & book a care provider', category: '1st trimester'),
  ChecklistItem(id: 'td_first_scan', label: 'Schedule first ultrasound', category: '1st trimester'),
  ChecklistItem(id: 'td_avoid', label: 'Review foods & meds to avoid', category: '1st trimester'),
  ChecklistItem(id: 'td_anomaly', label: 'Book 20-week anomaly scan', category: '2nd trimester'),
  ChecklistItem(id: 'td_glucose', label: 'Plan glucose screening test', category: '2nd trimester'),
  ChecklistItem(id: 'td_classes', label: 'Sign up for antenatal classes', category: '2nd trimester'),
  ChecklistItem(id: 'td_babygear', label: 'Start essential baby shopping', category: '2nd trimester'),
  ChecklistItem(id: 'td_birthplan', label: 'Write a birth plan', category: '3rd trimester'),
  ChecklistItem(id: 'td_bag', label: 'Pack the hospital bag', category: '3rd trimester'),
  ChecklistItem(id: 'td_carseat', label: 'Install the car seat', category: '3rd trimester'),
  ChecklistItem(id: 'td_pediatrician', label: 'Choose a pediatrician', category: '3rd trimester'),
  ChecklistItem(id: 'td_signs', label: 'Learn signs of labor & when to call', category: '3rd trimester'),
];

/// Returns the preset items for a given checklist [kind].
List<ChecklistItem> defaultChecklist(String kind) {
  switch (kind) {
    case ChecklistKind.hospitalBag:
      return _hospitalBag.map((e) => _item(e.id, e.label, e.category)).toList();
    case ChecklistKind.todo:
      return _todo.map((e) => _item(e.id, e.label, e.category)).toList();
    default:
      return const [];
  }
}
