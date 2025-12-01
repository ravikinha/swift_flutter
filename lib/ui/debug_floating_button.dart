import 'package:flutter/material.dart';
import '../core/view_interceptor.dart';

/// Floating action button to access debug page
/// 
/// This widget automatically finds the correct Navigator context and works with
/// both MaterialApp and GetMaterialApp.
/// 
/// Usage:
/// ```dart
/// MaterialApp(
///   navigatorKey: NavigatorService.navigatorKey, // Optional but recommended
///   builder: (context, child) {
///     return Stack(
///       children: [
///         child!,
///         SwiftDebugFloatingButton(), // Works anywhere in the widget tree
///       ],
///     );
///   },
/// )
/// ```
class SwiftDebugFloatingButton extends StatelessWidget {
  /// Optional navigator key to use for navigation
  /// If provided, this will be used instead of finding Navigator from context
  final GlobalKey<NavigatorState>? navigatorKey;
  
  const SwiftDebugFloatingButton({
    super.key,
    this.navigatorKey,
  });

  @override
  Widget build(BuildContext context) {
    if (!SwiftViewInterceptor.isEnabled) {
      return const SizedBox.shrink();
    }

    // Set navigator key if provided
    if (navigatorKey != null) {
      SwiftViewInterceptor.setNavigatorKey(navigatorKey);
    }

    // Set context for navigation (as fallback)
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

