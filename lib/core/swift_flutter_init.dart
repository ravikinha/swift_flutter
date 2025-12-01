import 'package:flutter/material.dart';
import 'logger.dart';
import 'devtools.dart';
import 'network_interceptor.dart';
import 'log_interceptor.dart';
import 'websocket_interceptor.dart';
import 'auto_injector.dart';
import '../store/store.dart';
import '../store/middleware.dart';
import '../core/view_interceptor.dart';

/// Main initialization class for Swift Flutter
/// 
/// Provides a single entry point to configure all Swift Flutter features.
class SwiftFlutter {
  static bool _debugToolEnabled = false;

  /// Check if debug tool is enabled
  static bool get isDebugToolEnabled => _debugToolEnabled;

  /// Initialize Swift Flutter with default development settings
  /// 
  /// This method:
  /// - Enables the logger and sets it to debug level
  /// - Enables DevTools with dependency tracking, state history, and performance tracking
  /// - Registers the LoggingMiddleware for action logging
  /// - Optionally enables debug tool (network and logs tracking with floating button)
  /// 
  /// [debugtool] - If true, enables network request/response tracking and log capture
  ///               with a floating action button to access the debug panel
  /// [navigatorKey] - Optional global navigator key for navigation (required for GetMaterialApp)
  ///                  If not provided, will try to find Navigator from context
  /// 
  /// Example with MaterialApp:
  /// ```dart
  /// void main() {
  ///   SwiftFlutter.init(debugtool: true);
  ///   runApp(MyApp());
  /// }
  /// ```
  /// 
  /// Example with GetMaterialApp (requires navigatorKey):
  /// ```dart
  /// final navigatorKey = GlobalKey<NavigatorState>();
  /// 
  /// void main() {
  ///   SwiftFlutter.init(debugtool: true, navigatorKey: navigatorKey);
  ///   runApp(GetMaterialApp(
  ///     navigatorKey: navigatorKey,
  ///     home: MyHomePage(),
  ///   ));
  /// }
  /// ```
  static void init({
    bool debugtool = false,
    GlobalKey<NavigatorState>? navigatorKey,
  }) {
    // Debug: Log navigator key status
    if (debugtool && navigatorKey != null) {
      debugPrint('SwiftFlutter.init: NavigatorKey provided for debug tool');
    }
    // Enable logger for debugging
    Logger.setEnabled(true);
    Logger.setLevel(LogLevel.debug);

    // Enable DevTools for visual debugging
    SwiftDevTools.enable(
      trackDependencies: true,
      trackStateHistory: true,
      trackPerformance: true,
    );

    // Register middleware
    store.addMiddleware(LoggingMiddleware());

    // Enable debug tool if requested
    if (debugtool) {
      NetworkInterceptor.enable();
      LogInterceptor.enable();
      WebSocketInterceptor.enable();
      SwiftViewInterceptor.enable();
      
      // Enable automatic HTTP interception for all HTTP traffic (Dio and http package)
      // This works automatically without requiring any app code changes
      AutoInjector.enable();
      
      // Set navigator key if provided (for GetMaterialApp support)
      if (navigatorKey != null) {
        SwiftViewInterceptor.setNavigatorKey(navigatorKey);
      }
      
      _debugToolEnabled = true;
    }
  }
}

