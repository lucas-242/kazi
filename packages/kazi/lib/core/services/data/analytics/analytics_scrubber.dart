/// Strips personal data from event properties on the way out.
///
/// The taxonomy already promises no event carries an amount, a name, an e-mail
/// or free text. This enforces it, because an amount leaked to an analytics
/// vendor cannot be recalled.
abstract final class AnalyticsScrubber {
  /// Firebase's own limits, matched so both sinks see the same value.
  static const int maxValueLength = 100;
  static const int maxParameters = 25;

  /// Written in place of a removed value: an absent key looks like a bug, this
  /// looks like a decision.
  static const String redacted = '[redacted]';

  /// Applied to **string** values only — `has_client` is a boolean and cannot
  /// leak a client; `client_name` is a string and certainly can.
  static const Set<String> _textDenied = {
    'name',
    'email',
    'mail',
    'client',
    'customer',
    'phone',
    'tel',
    'document',
    'cpf',
    'cnpj',
    'note',
    'description',
    'address',
    'title',
    'label',
    'query',
    'search',
    'token',
    'uid',
    'user_id',
  };

  /// Applied to **numeric** values. Counts are spelled `*_count` / `*_bucket`
  /// and pass untouched.
  static const Set<String> _numericDenied = {
    'value',
    'amount',
    'price',
    'total',
    'revenue',
    'earning',
    'salary',
    'commission_value',
    'withheld',
    'balance',
  };

  static Map<String, Object> scrub(Map<String, Object> properties) {
    if (properties.isEmpty) return const {};

    final safe = <String, Object>{};

    for (final entry in properties.entries) {
      if (safe.length >= maxParameters) break;
      safe[entry.key] = _scrubValue(entry.key, entry.value);
    }

    return safe;
  }

  static Object _scrubValue(String key, Object value) {
    final normalizedKey = key.toLowerCase();

    if (value is String) {
      // Before the denylist: an address is an address whatever the key is.
      if (_looksLikeEmail(value)) return redacted;
      if (_matches(normalizedKey, _textDenied)) return redacted;
      return value.length > maxValueLength
          ? value.substring(0, maxValueLength)
          : value;
    }

    if (value is num) {
      return _matches(normalizedKey, _numericDenied) ? redacted : value;
    }

    if (value is bool) return value;

    // Collections are the easiest place for a whole entity to hide, and their
    // size is the only part worth measuring.
    if (value is Iterable) return value.length;

    // The type name, never `toString()` — that is where models leak.
    return value.runtimeType.toString();
  }

  static bool _matches(String key, Set<String> fragments) =>
      fragments.any(key.contains);

  static bool _looksLikeEmail(String value) {
    final at = value.indexOf('@');
    return at > 0 && value.indexOf('.', at) > at + 1;
  }
}
