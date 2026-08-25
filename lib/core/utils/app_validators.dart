class AppValidators {
  static String? Function(String?) required(String message) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return message;
      }
      return null;
    };
  }

  static String? price(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a price';
    }
    final parsed = double.tryParse(value);
    if (parsed == null) {
      return 'Please enter a valid number';
    }
    // Reject NaN / Infinity — double.parse accepts them
    if (!parsed.isFinite) {
      return 'Please enter a valid number';
    }
    if (parsed < 0) {
      return 'Price cannot be negative';
    }
    return null;
  }
}
