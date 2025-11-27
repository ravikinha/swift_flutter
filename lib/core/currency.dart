/// Currency helper class with currency definitions and formatting utilities.
class Currency {
  final String code;
  final String symbol;
  final String name;
  final int decimals;
  final bool symbolBefore;
  final String thousandSeparator;
  final String decimalSeparator;

  const Currency({
    required this.code,
    required this.symbol,
    required this.name,
    this.decimals = 2,
    this.symbolBefore = true,
    this.thousandSeparator = ',',
    this.decimalSeparator = '.',
  });

  /// Format a number as currency string
  String format(double value) {
    final parts = value.abs().toStringAsFixed(decimals).split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '';

    // Add thousand separators
    final formattedInteger = integerPart.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}$thousandSeparator',
    );

    // Build the formatted string
    final formattedNumber = decimalPart.isNotEmpty
        ? '$formattedInteger$decimalSeparator$decimalPart'
        : formattedInteger;

    // Add sign if negative
    final sign = value < 0 ? '-' : '';

    // Place symbol before or after
    if (symbolBefore) {
      return '$sign$symbol$formattedNumber';
    } else {
      return '$sign$formattedNumber $symbol';
    }
  }

  // Common currencies
  static const usd = Currency(
    code: 'USD',
    symbol: '\$',
    name: 'US Dollar',
    decimals: 2,
  );

  static const inr = Currency(
    code: 'INR',
    symbol: '₹',
    name: 'Indian Rupee',
    decimals: 2,
  );

  static const eur = Currency(
    code: 'EUR',
    symbol: '€',
    name: 'Euro',
    decimals: 2,
  );

  static const gbp = Currency(
    code: 'GBP',
    symbol: '£',
    name: 'British Pound',
    decimals: 2,
  );

  static const jpy = Currency(
    code: 'JPY',
    symbol: '¥',
    name: 'Japanese Yen',
    decimals: 0,
  );

  static const cny = Currency(
    code: 'CNY',
    symbol: '¥',
    name: 'Chinese Yuan',
    decimals: 2,
  );

  static const aud = Currency(
    code: 'AUD',
    symbol: 'A\$',
    name: 'Australian Dollar',
    decimals: 2,
  );

  static const cad = Currency(
    code: 'CAD',
    symbol: 'C\$',
    name: 'Canadian Dollar',
    decimals: 2,
  );

  static const chf = Currency(
    code: 'CHF',
    symbol: 'CHF',
    name: 'Swiss Franc',
    decimals: 2,
  );

  static const sgd = Currency(
    code: 'SGD',
    symbol: 'S\$',
    name: 'Singapore Dollar',
    decimals: 2,
  );

  static const aed = Currency(
    code: 'AED',
    symbol: 'د.إ',
    name: 'UAE Dirham',
    decimals: 2,
  );

  static const sar = Currency(
    code: 'SAR',
    symbol: 'ر.س',
    name: 'Saudi Riyal',
    decimals: 2,
  );

  static const btc = Currency(
    code: 'BTC',
    symbol: '₿',
    name: 'Bitcoin',
    decimals: 8,
  );

  static const eth = Currency(
    code: 'ETH',
    symbol: 'Ξ',
    name: 'Ethereum',
    decimals: 6,
  );
}

