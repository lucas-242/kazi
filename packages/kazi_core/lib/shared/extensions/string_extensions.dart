/// Latin accents the three supported languages use.
const Map<String, String> _accents = {
  'á': 'a', 'à': 'a', 'ã': 'a', 'â': 'a', 'ä': 'a',
  'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
  'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
  'ó': 'o', 'ò': 'o', 'õ': 'o', 'ô': 'o', 'ö': 'o',
  'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
  'ç': 'c', 'ñ': 'n',
};

final RegExp _whitespaceRun = RegExp(r'\s+');

extension StringExtensions on String {
  /// A form of this string fit for comparing names: lowercased, trimmed,
  /// internal whitespace collapsed to single spaces, and Latin accents
  /// stripped — so `'  Depilação  Facial '` and `'DEPILACAO FACIAL'` are the
  /// same name.
  ///
  /// A detection key only. It is never stored, and never identifies a record —
  /// the document id does.
  String get normalizedName {
    final buffer = StringBuffer();
    for (final char in toLowerCase().trim().split('')) {
      buffer.write(_accents[char] ?? char);
    }
    return buffer.toString().replaceAll(_whitespaceRun, ' ');
  }

  /// Return normalized date.
  String normalizeDate() {
    final splitedDate = _splitDate(this);
    final normalizedDate = _createNewDate(splitedDate);
    return normalizedDate;
  }

  List<String> _splitDate(String date) {
    var splitedDate = date.split('/');
    if (splitedDate.length == 1) {
      splitedDate = date.split('-');
    }

    return splitedDate;
  }

  String _createNewDate(List<String> splitedDate) {
    String normalizedDate = '';
    int count = 1;

    for (var part in splitedDate) {
      normalizedDate += _addZeroToNumber(part);
      normalizedDate += _addSlash(splitedDate, count);
      count++;
    }

    return normalizedDate;
  }

  String _addZeroToNumber(String part) {
    if (part.length == 1) {
      return '0$part';
    }

    return part;
  }

  String _addSlash(List<String> splitedDate, int count) {
    if (splitedDate.length != count) {
      return '/';
    }

    return '';
  }

  String capitalize() {
    if (length <= 1) {
      return toUpperCase();
    }

    final List<String> words = split(' ');
    final capitalizedWords = _capitalizeWords(words);
    return capitalizedWords.join(' ');
  }

  Iterable<String> _capitalizeWords(List<String> words) {
    return words.map((word) {
      if (word.trim().isNotEmpty) {
        final String firstLetter = word.trim().substring(0, 1).toUpperCase();
        final String remainingLetters = word.trim().substring(1);

        return '$firstLetter$remainingLetters';
      }
      return '';
    });
  }
}
