import 'package:flutter/material.dart';
import '../core/view_interceptor.dart';

/// Floating action button to access debug page
class SwiftDebugFloatingButton extends StatelessWidget {
  const SwiftDebugFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    if (!SwiftViewInterceptor.isEnabled) {
      return const SizedBox.shrink();
    }

    // Set context for navigation
    SwiftViewInterceptor.setContext(context);

    return FloatingActionButton(
      onPressed: () {
        SwiftViewInterceptor.showDebugPage();
      },
      backgroundColor: Colors.blue,
      tooltip: 'Open Swift Debug Tool',
      child: const Icon(Icons.bug_report),
    );
  }
}

