class CameraMathCleaner {
  const CameraMathCleaner();

  String clean(String rawText) {
    if (rawText.trim().isEmpty) {
      return '';
    }

    final List<String> candidates = rawText
        .split(RegExp(r'[\r\n]+'))
        .map((String line) => line.trim())
        .where((String line) => line.isNotEmpty)
        .toList();

    String source;

    if (candidates.length <= 1) {
      source = rawText.trim();
    } else {
      candidates.sort(
        (String a, String b) =>
            _mathScore(b).compareTo(_mathScore(a)),
      );
      source = candidates.first;
    }

    String value = source
        .replaceAll('−', '-')
        .replaceAll('–', '-')
        .replaceAll('—', '-')
        .replaceAll('×', '*')
        .replaceAll('∙', '*')
        .replaceAll('·', '*')
        .replaceAll('÷', '/')
        .replaceAll('∕', '/')
        .replaceAll('＝', '=')
        .replaceAll('²', '^2')
        .replaceAll('³', '^3')
        .replaceAll('⁴', '^4')
        .replaceAll('π', 'pi')
        .replaceAll(RegExp(r'\s+'), '');

    value = value
        .replaceAll(
          RegExp(
            r'^(solve|calculate|evaluate|findx|find)',
            caseSensitive: false,
          ),
          '',
        )
        .replaceAll(RegExp(r'[;,]+$'), '');

    // OCR often reads a multiplication sign as X between two digits.
    value = value.replaceAllMapped(
      RegExp(r'(\d)[xX](\d)'),
      (Match match) =>
          '${match.group(1)}*${match.group(2)}',
    );

    // Remaining X is treated as the algebraic variable x.
    value = value.replaceAll('X', 'x');

    // Handle common OCR forms such as √9 and √(9).
    value = value.replaceAllMapped(
      RegExp(r'√\(([^()]+)\)'),
      (Match match) =>
          'sqrt(${match.group(1)})',
    );

    value = value.replaceAllMapped(
      RegExp(r'√(-?\d+(?:\.\d+)?)'),
      (Match match) =>
          'sqrt(${match.group(1)})',
    );

    // Keep only characters our local math parser/equation recognizer can use.
    value = value.replaceAll(
      RegExp(r'[^0-9A-Za-z+\-*/^().%=]'),
      '',
    );

    return value;
  }

  int _mathScore(String value) {
    int score = 0;

    for (final int rune in value.runes) {
      final String character =
          String.fromCharCode(rune);

      if (RegExp(r'[0-9]').hasMatch(character)) {
        score += 2;
      }

      if ('+-×÷*/^=√()'.contains(character)) {
        score += 3;
      }

      if (character == 'x' || character == 'X') {
        score += 2;
      }
    }

    return score;
  }
}
