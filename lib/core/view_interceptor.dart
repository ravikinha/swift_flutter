import 'package:flutter/material.dart';
import '../ui/debug_page.dart';

/// View interceptor to show debug page
class SwiftViewInterceptor {
  static bool _enabled = false;
  static BuildContext? _context;

  /// Enable view interception
  static void enable() {
    _enabled = true;
  }

  /// Disable view interception
  static void disable() {
    _enabled = false;
  }

  /// Check if interception is enabled
  static bool get isEnabled => _enabled;

  /// Set the context for navigation
  static void setContext(BuildContext? context) {
    _context = context;
  }

  /// Show debug page
  static void showDebugPage() {
    if (!_enabled || _context == null) return;
    
    Navigator.of(_context!).push(
      MaterialPageRoute(
        builder: (context) => const SwiftDebugPage(),
      ),
    );
  }

  /// Check if debug page can be shown
  static bool canShowDebugPage() => _enabled && _context != null;
}

