import 'package:flutter/material.dart';
import 'package:swift_flutter/swift_flutter.dart';
import 'package:swift_flutter/core/extensions.dart';

/// Swift-like Extensions Example
class ExtensionsExample extends StatefulWidget {
  const ExtensionsExample({super.key});

  @override
  State<ExtensionsExample> createState() => _ExtensionsExampleState();
}

class _ExtensionsExampleState extends State<ExtensionsExample> {
  // Regular values for non-reactive examples
  int valueCount = 10;
  double priceValue = 99.99;
  String username = 'hello';
  String textInput = 'Hello World';
  List<int> numbers = [1, 2, 3, 4, 5];
  bool isVisible = true;
  
  // Reactive values to demonstrate Rx extensions
  final reactiveCounter = swift(10);
  final reactivePrice = swift(99.99);
  final reactiveName = swift('hello');
  final reactiveNumbers = swift<List<int>>([1, 2, 3, 4, 5]);
  final reactiveFlag = swift(true);

  @override
  void dispose() {
    reactiveCounter.dispose();
    reactivePrice.dispose();
    reactiveName.dispose();
    reactiveNumbers.dispose();
    reactiveFlag.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bool toggle example
          _buildSection(
            'Bool.toggle() - Toggle boolean values',
            [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'isVisible: $isVisible',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isVisible = isVisible.toggle();
                      });
                    },
                    child: const Text('Toggle'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Swift(
                builder: (context) => Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Reactive Flag: ${reactiveFlag.value}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        reactiveFlag.toggle();
                      },
                      child: const Text('Toggle Reactive'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const Divider(height: 32),
          
          // Number operations
          _buildSection(
            'Number Operations - add(), sub(), clamped()',
            [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Value Count: $valueCount',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        valueCount = valueCount.add(30);
                      });
                    },
                    child: const Text('Add 30'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        valueCount = valueCount.sub(10);
                      });
                    },
                    child: const Text('Sub 10'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Clamped (0-100): ${valueCount.clamped(min: 0, max: 100)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        valueCount = valueCount.clamped(min: 0, max: 100);
                      });
                    },
                    child: const Text('Clamp to 0-100'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Price: \$${priceValue.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        priceValue = priceValue.add(10.0);
                      });
                    },
                    child: const Text('Add \$10'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        priceValue = priceValue.sub(5.0);
                      });
                    },
                    child: const Text('Sub \$5'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Swift(
                builder: (context) => Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Reactive Counter: ${reactiveCounter.value}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        reactiveCounter.add(5);
                      },
                      child: const Text('Add 5'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        reactiveCounter.sub(3);
                      },
                      child: const Text('Sub 3'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const Divider(height: 32),
          
          // String operations
          _buildSection(
            'String Operations - capitalized, add(), dropFirst(), dropLast()',
            [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Original: "$username"',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Capitalized: "${username.capitalized}"',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        username = username.capitalized;
                      });
                    },
                    child: const Text('Capitalize'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Text: "$textInput"',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        textInput = textInput.add('!');
                      });
                    },
                    child: const Text('Add "!"'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        textInput = textInput.dropFirst();
                      });
                    },
                    child: const Text('Drop First'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        textInput = textInput.dropLast();
                      });
                    },
                    child: const Text('Drop Last'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Real Example - String Cleanup:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Before: username = username.substring(1);',
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: Colors.red.shade700,
                      ),
                    ),
                    Text(
                      'After:  username = username.dropFirst();',
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Swift(
                builder: (context) => Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Reactive Name: "${reactiveName.value}"',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        reactiveName.add(' world');
                      },
                      child: const Text('Add " world"'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        reactiveName.value = reactiveName.value.dropFirst();
                      },
                      child: const Text('Drop First'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const Divider(height: 32),
          
          // List operations
          _buildSection(
            'List Operations - dropFirst(), dropLast(), containsWhere()',
            [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Numbers: $numbers',
                      style: const TextStyle(fontSize: 16, fontFamily: 'monospace'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        numbers = numbers.dropFirst();
                      });
                    },
                    child: const Text('Drop First'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        numbers = numbers.dropLast();
                      });
                    },
                    child: const Text('Drop Last'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        numbers = [...numbers, numbers.isEmpty ? 0 : numbers.last + 1];
                      });
                    },
                    child: const Text('Add Number'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        numbers = [1, 2, 3, 4, 5];
                      });
                    },
                    child: const Text('Reset'),
                  ),
                ],
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
                    Text(
                      'Contains number > 3: ${numbers.containsWhere((n) => n > 3)}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Contains even number: ${numbers.containsWhere((n) => n % 2 == 0)}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Swift(
                builder: (context) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Reactive Numbers: ${reactiveNumbers.value}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            reactiveNumbers.value = reactiveNumbers.value.dropFirst();
                          },
                          child: const Text('Drop First'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            reactiveNumbers.value = reactiveNumbers.value.dropLast();
                          },
                          child: const Text('Drop Last'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            final current = List<int>.from(reactiveNumbers.value);
                            current.add(current.isEmpty ? 0 : current.last + 1);
                            reactiveNumbers.value = current;
                          },
                          child: const Text('Add Number'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const Divider(height: 32),
          
          // Summary
          _buildSection(
            'Summary - All Features',
            [
              _buildFeatureRow('✅ Bool.toggle()', 'Toggle boolean values'),
              _buildFeatureRow('✅ Number.add()', 'Add values to numbers'),
              _buildFeatureRow('✅ Number.sub()', 'Subtract values from numbers'),
              _buildFeatureRow('✅ Number.clamped()', 'Clamp values to safe ranges'),
              _buildFeatureRow('✅ String.capitalized', 'Capitalize first letter only'),
              _buildFeatureRow('✅ String.add()', 'Concatenate strings'),
              _buildFeatureRow('✅ String.dropFirst()', 'Remove first character'),
              _buildFeatureRow('✅ String.dropLast()', 'Remove last character'),
              _buildFeatureRow('✅ List.dropFirst()', 'Remove first element'),
              _buildFeatureRow('✅ List.dropLast()', 'Remove last element'),
              _buildFeatureRow('✅ List.containsWhere()', 'Swift-like list searching'),
              _buildFeatureRow('✅ Rx<int>.add()/.sub()', 'Reactive number operations'),
              _buildFeatureRow('✅ Rx<String>.add()', 'Reactive string concatenation'),
              _buildFeatureRow('✅ Rx<bool>.toggle()', 'Reactive boolean toggle'),
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

  Widget _buildFeatureRow(String feature, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 200,
            child: Text(
              feature,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'monospace',
              ),
            ),
          ),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

