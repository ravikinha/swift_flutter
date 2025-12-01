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
    if (!_enabled) return;
    
    // Try to get navigator from global key first (works with GetMaterialApp)
    if (_navigatorKey?.currentState != null) {
      _navigatorKey!.currentState!.push(
        MaterialPageRoute(
          builder: (context) => const SwiftDebugPage(),
        ),
      );
      return;
    }
    
    // Fallback to context-based navigation
    if (_context != null) {
      // Try to find navigator from context
      final navigator = Navigator.maybeOf(_context!);
      if (navigator != null) {
        navigator.push(
          MaterialPageRoute(
            builder: (context) => const SwiftDebugPage(),
          ),
        );
        return;
      }
      
      // If Navigator.maybeOf fails, try to find ancestor navigator
      final navigatorState = Navigator.maybeOf(_context!, rootNavigator: true);
      if (navigatorState != null) {
        navigatorState.push(
          MaterialPageRoute(
            builder: (context) => const SwiftDebugPage(),
          ),
        );
        return;
      }
    }
    
    // Last resort: try to find any navigator in the widget tree
    if (_context != null) {
      final navigatorState = _context!.findAncestorStateOfType<NavigatorState>();
      if (navigatorState != null) {
        navigatorState.push(
          MaterialPageRoute(
            builder: (context) => const SwiftDebugPage(),
          ),
        );
        return;
      }
    }
    
    // If all else fails, print a warning
    debugPrint('SwiftDebugFloatingButton: Could not find Navigator. Make sure to set navigatorKey or use SwiftDebugFloatingButton in a context with Navigator.');
  }

  /// Check if debug page can be shown
  static bool canShowDebugPage() {
    if (!_enabled) return false;
    
    // Check if we have navigator key
    if (_navigatorKey?.currentState != null) return true;
    
    // Check if we have valid context with navigator
    if (_context != null) {
      final navigator = Navigator.maybeOf(_context!);
      if (navigator != null) return true;
      
      final navigatorState = _context!.findAncestorStateOfType<NavigatorState>();
      if (navigatorState != null) return true;
    }
    
    return false;
  }
}

