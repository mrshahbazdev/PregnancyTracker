/// Strip characters that aren't valid in a `tel:` URI, keeping digits, a
/// leading `+`, and the common separators dialers accept.
String sanitizePhone(String raw) {
  final trimmed = raw.trim();
  final buffer = StringBuffer();
  for (var i = 0; i < trimmed.length; i++) {
    final c = trimmed[i];
    final isDigit = c.codeUnitAt(0) >= 0x30 && c.codeUnitAt(0) <= 0x39;
    if (isDigit) {
      buffer.write(c);
    } else if (c == '+' && i == 0) {
      buffer.write(c);
    }
  }
  return buffer.toString();
}

/// Build a `tel:` [Uri] for dialing, or null if no digits are present.
Uri? telUri(String raw) {
  final clean = sanitizePhone(raw);
  if (clean.replaceAll('+', '').isEmpty) return null;
  return Uri(scheme: 'tel', path: clean);
}
