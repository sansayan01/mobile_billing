// Phone normalization: strips formatting (spaces, dashes, parentheses) and
// Indian country prefixes (+91, 0091, 91) so any input collapses to the
// canonical 10-digit national number (no leading 0) for consistent compare/insert.

String normalizePhone(String phone) {
  // 1. Trim surrounding whitespace.
  var cleaned = phone.trim();

  // 2. Remove spaces, dashes, and parentheses.
  cleaned = cleaned.replaceAll(RegExp(r"[\s\-()]"), '');

  // 3-5. Strip known Indian country prefixes.
  if (cleaned.startsWith('+91')) {
    cleaned = cleaned.substring(3);
  } else if (cleaned.startsWith('0091')) {
    cleaned = cleaned.substring(4);
  } else if (cleaned.startsWith('91') && cleaned.length == 12) {
    cleaned = cleaned.substring(2);
  }

  // 6. Strip a single leading '0' to always return the 10-digit national number.
  if (cleaned.startsWith('0')) {
    cleaned = cleaned.substring(1);
  }

  // 7. Best-effort: return whatever remains even if not exactly 10 digits.
  return cleaned;
}

bool isValidPhone(String phone) {
  final normalized = normalizePhone(phone);
  return normalized.length == 10 && RegExp(r'^\d+$').hasMatch(normalized);
}
