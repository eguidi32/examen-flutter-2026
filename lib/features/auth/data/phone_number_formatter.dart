class PhoneNumberFormatter {
  const PhoneNumberFormatter._();

  static const String validationMessage =
      'Entrez un numero mobile senegalais valide.';

  static final RegExp _senegalMobileRegex = RegExp(
    r'^\+221(70|75|76|77|78)\d{7}$',
  );

  static String normalize(String input) {
    final cleaned = input.trim().replaceAll(RegExp(r'[\s\-().]'), '');

    if (cleaned.startsWith('00')) {
      return '+${cleaned.substring(2)}';
    }

    if (cleaned.startsWith('221')) {
      return '+$cleaned';
    }

    if (RegExp(r'^(70|75|76|77|78)\d{7}$').hasMatch(cleaned)) {
      return '+221$cleaned';
    }

    return cleaned;
  }

  static bool isValid(String input) {
    return _senegalMobileRegex.hasMatch(normalize(input));
  }
}
