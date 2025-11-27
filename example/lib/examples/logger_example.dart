import 'package:flutter/material.dart';
import 'package:swift_flutter/swift_flutter.dart';

/// Logger Example
class LoggerExample extends StatefulWidget {
  const LoggerExample({super.key});

  @override
  State<LoggerExample> createState() => _LoggerExampleState();
}

class _LoggerExampleState extends State<LoggerExample> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                Logger.debug('Debug message');
                _showLogs(context);
              },
              child: const Text('Debug'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                Logger.info('Info message');
                _showLogs(context);
              },
              child: const Text('Info'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                Logger.warning('Warning message');
                _showLogs(context);
              },
              child: const Text('Warning'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                Logger.error('Error message');
                _showLogs(context);
              },
              child: const Text('Error'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            Logger.clear();
            _showLogs(context);
          },
          child: const Text('Clear Logs'),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          height: 150,
          child: SingleChildScrollView(
            child: Text(
              Logger.history.map((e) => e.toString()).join('\n'),
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
          ),
        ),
      ],
    );
  }

  void _showLogs(BuildContext context) {
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Log history: ${Logger.history.length} entries'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

