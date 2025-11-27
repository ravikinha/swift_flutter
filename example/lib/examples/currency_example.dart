import 'package:flutter/material.dart';
import 'package:swift_flutter/swift_flutter.dart';
import 'package:swift_flutter/core/currency.dart';
import 'package:swift_flutter/core/extensions.dart';

/// Currency Extensions Example
class CurrencyExample extends StatefulWidget {
  const CurrencyExample({super.key});

  @override
  State<CurrencyExample> createState() => _CurrencyExampleState();
}

class _CurrencyExampleState extends State<CurrencyExample> {
  double amount = 10000.50;
  final amountController = TextEditingController(text: '10000.50');

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  void _updateAmount(String value) {
    // Automatically remove commas and parse the cleaned value
    final cleaned = value.numbersWithDecimal;
    final parsed = cleaned.toDoubleSafe();
    
    if (parsed != null) {
      setState(() {
        amount = parsed;
      });
    } else if (cleaned.isEmpty || cleaned == '.') {
      // Allow empty or just decimal point while typing
      setState(() {
        amount = 0.0;
      });
    }
    
    // Update the controller to show cleaned value (but keep user input for better UX)
    // We'll use a formatter instead to clean on input
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Amount Input
          _buildSection(
            'Enter Amount',
            [
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Amount (commas auto-removed)',
                  hintText: 'Try: 11,111.50',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.attach_money),
                  helperText: 'Commas are automatically removed internally',
                ),
                onChanged: (value) {
                  // Automatically clean the input while typing
                  final cleaned = value.numbersWithDecimal;
                  final parsed = cleaned.toDoubleSafe();
                  
                  if (parsed != null) {
                    setState(() {
                      amount = parsed;
                    });
                  } else if (cleaned.isEmpty || cleaned == '.' || cleaned == '-') {
                    // Allow empty or just decimal point/negative while typing
                    setState(() {
                      amount = 0.0;
                    });
                  }
                },
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 20, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Internal value: ${amount.toStringAsFixed(2)} (cleaned from input)',
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Divider(height: 32),

          // Major Currencies
          _buildSection(
            'Major Currencies',
            [
              _buildCurrencyRow('Indian Rupee (INR)', amount.toINR(), Colors.orange, Icons.currency_rupee),
              _buildCurrencyRow('US Dollar (USD)', amount.toCurrencyType(Currency.usd), Colors.green, Icons.attach_money),
              _buildCurrencyRow('Euro (EUR)', amount.toCurrencyType(Currency.eur), Colors.blue, Icons.euro),
              _buildCurrencyRow('British Pound (GBP)', amount.toCurrencyType(Currency.gbp), Colors.red, Icons.currency_pound),
              _buildCurrencyRow('Japanese Yen (JPY)', amount.toCurrencyType(Currency.jpy), Colors.pink, Icons.currency_yen),
            ],
          ),

          const Divider(height: 32),

          // More Currencies
          _buildSection(
            'More Currencies',
            [
              _buildCurrencyRow(
                'Australian Dollar',
                amount.toCurrencyType(Currency.aud),
                Colors.purple,
                Icons.currency_exchange,
              ),
              _buildCurrencyRow(
                'Canadian Dollar',
                amount.toCurrencyType(Currency.cad),
                Colors.teal,
                Icons.currency_exchange,
              ),
              _buildCurrencyRow(
                'Swiss Franc',
                amount.toCurrencyType(Currency.chf),
                Colors.indigo,
                Icons.currency_exchange,
              ),
              _buildCurrencyRow(
                'Singapore Dollar',
                amount.toCurrencyType(Currency.sgd),
                Colors.deepOrange,
                Icons.currency_exchange,
              ),
              _buildCurrencyRow(
                'UAE Dirham',
                amount.toCurrencyType(Currency.aed),
                Colors.amber,
                Icons.currency_exchange,
              ),
              _buildCurrencyRow(
                'Saudi Riyal',
                amount.toCurrencyType(Currency.sar),
                Colors.green.shade700,
                Icons.currency_exchange,
              ),
            ],
          ),

          const Divider(height: 32),

          // Cryptocurrencies
          _buildSection(
            'Cryptocurrencies',
            [
              _buildCurrencyRow(
                'Bitcoin',
                amount.toCurrencyType(Currency.btc),
                Colors.orange,
                Icons.currency_bitcoin,
              ),
              _buildCurrencyRow(
                'Ethereum',
                amount.toCurrencyType(Currency.eth),
                Colors.blue.shade300,
                Icons.circle,
              ),
            ],
          ),

          const Divider(height: 32),

          // Examples with different values
          _buildSection(
            'Examples - Different Values',
            [
              _buildExampleRow('₹1,000', 1000.0.toINR()),
              _buildExampleRow('₹10,000', 10000.0.toINR()),
              _buildExampleRow('₹1,00,000', 100000.0.toINR()),
              _buildExampleRow('₹10,00,000', 1000000.0.toINR()),
              const SizedBox(height: 8),
              _buildExampleRow('\$1,234.56', 1234.56.toCurrencyType(Currency.usd)),
              _buildExampleRow('\$10,000.00', 10000.0.toCurrencyType(Currency.usd)),
              _buildExampleRow('€999.99', 999.99.toCurrencyType(Currency.eur)),
              _buildExampleRow('£5,000.50', 5000.50.toCurrencyType(Currency.gbp)),
              _buildExampleRow('¥10,000', 10000.0.toCurrencyType(Currency.jpy)),
            ],
          ),

          const Divider(height: 32),

          // Readable Format Examples
          _buildSection(
            'Readable Format - K, M, B, T (Automatic)',
            [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildReadableExample('1,500', 1500.toReadable(), '1.5K'),
                    const SizedBox(height: 8),
                    _buildReadableExample('150,000', 150000.toReadable(), '150.0K'),
                    const SizedBox(height: 8),
                    _buildReadableExample('1,500,000', 1500000.toReadable(), '1.5M'),
                    const SizedBox(height: 8),
                    _buildReadableExample('1,500,000,000', 1500000000.toReadable(), '1.5B'),
                    const SizedBox(height: 8),
                    _buildReadableExample('1,500,000,000,000', 1500000000000.toReadable(), '1.5T'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '💡 Parse Readable Format Back to Numbers:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildParseExample('"1.5K".fromReadable()', '1.5K'.fromReadable()?.toString() ?? 'null', '1500.0'),
                    const SizedBox(height: 8),
                    _buildParseExample('"1.5M".fromReadable()', '1.5M'.fromReadable()?.toString() ?? 'null', '1500000.0'),
                    const SizedBox(height: 8),
                    _buildParseExample('"1.5B".fromReadable()', '1.5B'.fromReadable()?.toString() ?? 'null', '1500000000.0'),
                    const SizedBox(height: 8),
                    _buildParseExample('"1.5T".fromReadable()', '1.5T'.fromReadable()?.toString() ?? 'null', '1500000000000.0'),
                  ],
                ),
              ),
            ],
          ),

          const Divider(height: 32),

          // String Cleaning Extensions
          _buildSection(
            'String Cleaning Extensions',
            [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStringCleanExample(
                      'Input with commas',
                      '"11,111.50".numbersWithDecimal',
                      '11,111.50'.numbersWithDecimal,
                    ),
                    const SizedBox(height: 8),
                    _buildStringCleanExample(
                      'Remove commas',
                      '"11,111".removeCommas',
                      '11,111'.removeCommas,
                    ),
                    const SizedBox(height: 8),
                    _buildStringCleanExample(
                      'Numbers only',
                      '"abc123def456".numbersOnly',
                      'abc123def456'.numbersOnly,
                    ),
                    const SizedBox(height: 8),
                    _buildStringCleanExample(
                      'Letters only',
                      '"abc123def456".lettersOnly',
                      'abc123def456'.lettersOnly,
                    ),
                    const SizedBox(height: 8),
                    _buildStringCleanExample(
                      'Safe parsing',
                      '"11,111.50".toDoubleSafe()',
                      '11,111.50'.toDoubleSafe()?.toString() ?? 'null',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '💡 Tip: Use .numbersWithDecimal to automatically clean user input',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Example: "11,111".numbersWithDecimal → "11111"',
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Divider(height: 32),

          // Code Examples
          _buildSection(
            'Code Examples',
            [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCodeExample(
                      'INR Formatting',
                      '10000.50.toINR()',
                      '₹10,000.50',
                    ),
                    const SizedBox(height: 8),
                    _buildCodeExample(
                      'USD Formatting',
                      '1234.56.toCurrencyType(Currency.usd)',
                      '\$1,234.56',
                    ),
                    const SizedBox(height: 8),
                    _buildCodeExample(
                      'Custom Currency',
                      '1000.toCurrencyType(Currency.eur)',
                      '€1,000.00',
                    ),
                    const SizedBox(height: 8),
                    _buildCodeExample(
                      'Clean Input',
                      '"11,111.50".numbersWithDecimal',
                      '"11111.50"',
                    ),
                    const SizedBox(height: 8),
                    _buildCodeExample(
                      'Safe Parse',
                      '"11,111".toDoubleSafe()',
                      '11111.0',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildCurrencyRow(String label, String formatted, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatted,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleRow(String label, String formatted) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'monospace',
            ),
          ),
          Text(
            formatted,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeExample(String title, String code, String result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          code,
          style: TextStyle(
            fontSize: 11,
            fontFamily: 'monospace',
            color: Colors.blue.shade700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '→ $result',
          style: TextStyle(
            fontSize: 11,
            fontFamily: 'monospace',
            color: Colors.green.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStringCleanExample(String label, String code, String result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          code,
          style: TextStyle(
            fontSize: 11,
            fontFamily: 'monospace',
            color: Colors.blue.shade700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '→ "$result"',
          style: TextStyle(
            fontSize: 11,
            fontFamily: 'monospace',
            color: Colors.green.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildReadableExample(String original, String readable, String expected) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            original,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'monospace',
            ),
          ),
          Text(
            '→ $readable',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParseExample(String code, String result, String expected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          code,
          style: TextStyle(
            fontSize: 11,
            fontFamily: 'monospace',
            color: Colors.blue.shade700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '→ $result',
          style: TextStyle(
            fontSize: 11,
            fontFamily: 'monospace',
            color: Colors.green.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

