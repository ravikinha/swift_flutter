import 'package:flutter/material.dart';
import '../core/view_interceptor.dart';
import 'debug_page.dart';

/// Floating action button to access debug page
/// 
/// This widget automatically finds the correct Navigator context and works with
/// both MaterialApp and GetMaterialApp. It automatically hides when on the debug page
/// and shows again when navigating back.
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
class SwiftDebugFloatingButton extends StatefulWidget {
  /// Optional navigator key to use for navigation
  /// If provided, this will be used instead of finding Navigator from context
  final GlobalKey<NavigatorState>? navigatorKey;
  
  const SwiftDebugFloatingButton({
    super.key,
    this.navigatorKey,
  });

  @override
  State<SwiftDebugFloatingButton> createState() => _SwiftDebugFloatingButtonState();
}

class _SwiftDebugFloatingButtonState extends State<SwiftDebugFloatingButton> {
  @override
  Widget build(BuildContext context) {
    if (!SwiftViewInterceptor.isEnabled) {
      return const SizedBox.shrink();
    }

    // Set navigator key if provided (overrides any previously set key)
    if (widget.navigatorKey != null) {
      SwiftViewInterceptor.setNavigatorKey(widget.navigatorKey);
    }

    // Check if we're currently on the debug page by looking for SwiftDebugPage widget
    final isOnDebugPage = context.findAncestorWidgetOfExactType<SwiftDebugPage>() != null;

    // Hide button if on debug page
    if (isOnDebugPage) {
      return const SizedBox.shrink();
    }

    // Use IconButton wrapped in a container to avoid tooltip overlay issues
    // This works in Stack without requiring Overlay ancestor
    return Positioned(
      bottom: 16,
      right: 16,
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(28),
        color: Colors.blue,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () {
            // Always try to use context as fallback (in case navigatorKey isn't ready yet)
            // The showDebugPage() method will prioritize navigatorKey if it's available
            SwiftViewInterceptor.setContext(context);
            SwiftViewInterceptor.showDebugPage();
          },
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(
              Icons.bug_report,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}

