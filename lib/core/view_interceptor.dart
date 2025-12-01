import 'package:flutter/material.dart';
import '../ui/debug_page.dart';

/// View interceptor to show debug page
class SwiftViewInterceptor {
  static bool _enabled = false;
  static BuildContext? _context;
  static GlobalKey<NavigatorState>? _navigatorKey;

  /// Enable view interception
  static void enable() {
    _enabled = true;
  }

  /// Disable view interception
  static void disable() {
    _enabled = false;
    _context = null;
    _navigatorKey = null;
  }

  /// Check if interception is enabled
  static bool get isEnabled => _enabled;

  /// Set the context for navigation
  static void setContext(BuildContext? context) {
    _context = context;
    // Try to find navigator from context
    if (context != null) {
      final navigator = Navigator.maybeOf(context);
      if (navigator != null) {
        // Context has navigator, we can use it
      }
    }
  }

  /// Set global navigator key (useful for GetMaterialApp or custom navigation)
  static void setNavigatorKey(GlobalKey<NavigatorState>? key) {
    _navigatorKey = key;
  }

  /// Show debug page
  static void showDebugPage() {
    if (!_enabled) {
      debugPrint('SwiftViewInterceptor: Debug tool is not enabled.');
      return;
    }
    
    // Priority 1: Try to get navigator from global key first (works with GetMaterialApp)
    if (_navigatorKey != null) {
      final navigatorState = _navigatorKey!.currentState;
      if (navigatorState != null) {
        navigatorState.push(
          MaterialPageRoute(
            builder: (context) => const SwiftDebugPage(),
          ),
        );
        debugPrint('SwiftViewInterceptor: Navigated using global navigatorKey.');
        return;
      } else {
        debugPrint('SwiftViewInterceptor: navigatorKey is set but currentState is null. Navigator may not be built yet.');
      }
    }
    
    // Priority 2: Fallback to context-based navigation
    if (_context != null) {
      // Try to find navigator from context (root navigator)
      final navigatorState = Navigator.maybeOf(_context!, rootNavigator: true);
      if (navigatorState != null) {
        navigatorState.push(
          MaterialPageRoute(
            builder: (context) => const SwiftDebugPage(),
          ),
        );
        debugPrint('SwiftViewInterceptor: Navigated using context with rootNavigator.');
        return;
      }
      
      // Try regular navigator (non-root)
      final navigator = Navigator.maybeOf(_context!);
      if (navigator != null) {
        navigator.push(
          MaterialPageRoute(
            builder: (context) => const SwiftDebugPage(),
          ),
        );
        debugPrint('SwiftViewInterceptor: Navigated using context navigator.');
        return;
      }
      
      // Last resort: try to find any navigator in the widget tree
      final ancestorNavigator = _context!.findAncestorStateOfType<NavigatorState>();
      if (ancestorNavigator != null) {
        ancestorNavigator.push(
          MaterialPageRoute(
            builder: (context) => const SwiftDebugPage(),
          ),
        );
        debugPrint('SwiftViewInterceptor: Navigated using ancestor NavigatorState.');
        return;
      }
    }
    
    // If all else fails, print a detailed warning
    debugPrint('SwiftViewInterceptor: Could not find Navigator.');
    debugPrint('  - navigatorKey: ${_navigatorKey != null ? "set" : "null"}');
    debugPrint('  - navigatorKey.currentState: ${_navigatorKey?.currentState != null ? "available" : "null"}');
    debugPrint('  - context: ${_context != null ? "set" : "null"}');
    debugPrint('  - Make sure to:');
    debugPrint('    1. Pass navigatorKey to SwiftFlutter.init(navigatorKey: yourKey)');
    debugPrint('    2. Use the same key in GetMaterialApp/MaterialApp: navigatorKey: yourKey');
  }

  /// Check if debug page can be shown
  static bool canShowDebugPage() {
    if (!_enabled) return false;
    
    // Check if we have navigator key with valid state
    if (_navigatorKey != null && _navigatorKey!.currentState != null) {
      return true;
    }
    
    // Check if we have valid context with navigator
    if (_context != null) {
      // Try root navigator first
      final rootNavigator = Navigator.maybeOf(_context!, rootNavigator: true);
      if (rootNavigator != null) return true;
      
      // Try regular navigator
      final navigator = Navigator.maybeOf(_context!);
      if (navigator != null) return true;
      
      // Try to find ancestor navigator
      final navigatorState = _context!.findAncestorStateOfType<NavigatorState>();
      if (navigatorState != null) return true;
    }
    
    return false;
  }
}

