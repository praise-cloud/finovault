/// Formatting helpers — mirrors finovault-web/lib/utils/format.ts
/// ("MUR 125,000.00" style, code display) with fr/en locale resolution.
/// Hand-rolled (no locale-data init needed) so output stays deterministic.
class FvFormat {
  FvFormat._();

  static const _monthsEn = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  static const _monthsFr = [
    'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin', 'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'
  ];

  static bool isFrench(String language) => language.startsWith('fr');

  /// Maps a currency code to a display symbol; falls back to the code itself.
  static const _symbols = {
    'MUR': 'Rs',
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'JPY': '¥',
    'ZAR': 'R',
    'INR': '₹',
    'KES': 'KSh',
  };

  static String _currencySymbol(String currency) => _symbols[currency] ?? currency;

  static String _group(String digits, {required bool french}) {
    final sep = french ? ' ' : ',';
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      final remaining = digits.length - i;
      buf.write(digits[i]);
      if (remaining > 1 && (remaining - 1) % 3 == 0) buf.write(sep);
    }
    return buf.toString();
  }

  static String formatMoney(num amount, {String currency = 'MUR', String language = 'en'}) {
    final french = isFrench(language);
    final negative = amount < 0;
    final abs = amount.abs();
    final whole = abs.floor();
    final cents = ((abs - whole) * 100).round();
    final centsStr = cents == 100 ? '00' : cents.toString().padLeft(2, '0');
    final wholeStr = _group(cents == 100 ? (whole + 1).toString() : whole.toString(), french: french);
    final decSep = french ? ',' : '.';
    return '${negative ? '-' : ''}${_currencySymbol(currency)} $wholeStr$decSep$centsStr';
  }

  static String formatMoneySigned(num amount, {String currency = 'MUR', String language = 'en'}) {
    final sign = amount > 0 ? '+' : '';
    return '$sign${formatMoney(amount, currency: currency, language: language)}';
  }

  static String formatCompactCurrency(num amount,
      {String currency = 'MUR', String language = 'en'}) {
    final abs = amount.abs().toDouble();
    final prefix = amount < 0 ? '-' : '';
    final sym = '${_currencySymbol(currency)} ';
    String trim(String s) => s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
    if (abs >= 1000000) return '$prefix$sym${trim((abs / 1000000).toStringAsFixed(1))}M';
    if (abs >= 1000) return '$prefix$sym${trim((abs / 1000).toStringAsFixed(1))}K';
    return '$prefix$sym${abs.toStringAsFixed(0)}';
  }

  static String formatDate(DateTime date, {String language = 'en'}) {
    final months = isFrench(language) ? _monthsFr : _monthsEn;
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  static String formatRelativeTime(DateTime date, {DateTime? now}) {
    final ref = now ?? DateTime.now();
    final diff = ref.difference(date);
    if (diff.inDays > 30) return formatDate(date);
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m ago';
    return 'just now';
  }

  static String formatPercent(double fraction) =>
      '${(fraction * 100).round()}%';

  /// 0–4 password strength score — mirrors utils/validation.ts.
  static int passwordStrength(String value) {
    var score = 0;
    if (value.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(value)) score++;
    if (RegExp(r'[0-9]').hasMatch(value)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(value)) score++;
    return score;
  }
}

/// Transfer fee rule shared by the mock backend and the transfer UI —
/// mirrors computeTransferFee in the Expo app: 1.5%, clamped to [20, 500].
double computeTransferFee(double amount) {
  const rate = 0.015;
  const minFee = 20.0;
  const maxFee = 500.0;
  return (amount * rate).clamp(minFee, maxFee).toDouble();
}
