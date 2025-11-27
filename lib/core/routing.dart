import 'package:flutter/material.dart';
import 'rx.dart';
import 'logger.dart';

/// Routing state management for navigation
/// Provides reactive navigation state that can be used with any routing solution
class RoutingState {
  final String currentRoute;
  final Map<String, dynamic>? params;
  final Map<String, dynamic>? queryParams;
  final Object? arguments;
  final List<String> routeHistory;

  const RoutingState({
    required this.currentRoute,
    this.params,
    this.queryParams,
    this.arguments,
    this.routeHistory = const [],
  });

  RoutingState copyWith({
    String? currentRoute,
    Map<String, dynamic>? params,
    Map<String, dynamic>? queryParams,
    Object? arguments,
    List<String>? routeHistory,
  }) {
    return RoutingState(
      currentRoute: currentRoute ?? this.currentRoute,
      params: params ?? this.params,
      queryParams: queryParams ?? this.queryParams,
      arguments: arguments ?? this.arguments,
      routeHistory: routeHistory ?? this.routeHistory,
    );
  }

  bool get canGoBack => routeHistory.isNotEmpty;
  String? get previousRoute => routeHistory.isNotEmpty ? routeHistory.last : null;
}

/// Reactive routing state manager
/// Works with any routing solution (go_router, Navigator, etc.)
class RxRouting extends Rx<RoutingState> {
  RxRouting({
    String initialRoute = '/',
    Map<String, dynamic>? initialParams,
    Map<String, dynamic>? initialQueryParams,
  }) : super(RoutingState(
          currentRoute: initialRoute,
          params: initialParams,
          queryParams: initialQueryParams,
          routeHistory: [],
        ));

  /// Navigate to a route
  void navigateTo(
    String route, {
    Map<String, dynamic>? params,
    Map<String, dynamic>? queryParams,
    Object? arguments,
  }) {
    final newHistory = List<String>.from(value.routeHistory);
    newHistory.add(value.currentRoute);

    value = value.copyWith(
      currentRoute: route,
      params: params,
      queryParams: queryParams,
      arguments: arguments,
      routeHistory: newHistory,
    );

    Logger.debug('Navigated to: $route', {'params': params, 'queryParams': queryParams});
  }

  /// Go back
  void goBack() {
    if (!value.canGoBack) {
      Logger.warning('Cannot go back - no route history');
      return;
    }

    final newHistory = List<String>.from(value.routeHistory);
    final previousRoute = newHistory.removeLast();

    value = value.copyWith(
      currentRoute: previousRoute,
      routeHistory: newHistory,
    );

    Logger.debug('Navigated back to: $previousRoute');
  }

  /// Replace current route
  void replace(
    String route, {
    Map<String, dynamic>? params,
    Map<String, dynamic>? queryParams,
    Object? arguments,
  }) {
    value = value.copyWith(
      currentRoute: route,
      params: params,
      queryParams: queryParams,
      arguments: arguments,
      // Don't add to history for replace
    );

    Logger.debug('Replaced route with: $route');
  }

  /// Clear route history
  void clearHistory() {
    value = value.copyWith(routeHistory: []);
  }

  /// Get current route
  String get currentRoute => value.currentRoute;

  /// Get route params
  Map<String, dynamic>? get params => value.params;

  /// Get query params
  Map<String, dynamic>? get queryParams => value.queryParams;

  /// Can go back
  bool get canGoBack => value.canGoBack;

  /// Previous route
  String? get previousRoute => value.previousRoute;
}

/// Helper for integrating with Navigator
class NavigatorHelper {
  /// Navigate using Navigator and update routing state
  static Future<T?> navigateWithState<T>(
    BuildContext context,
    RxRouting routing,
    String route, {
    Map<String, dynamic>? params,
    Map<String, dynamic>? queryParams,
    Object? arguments,
  }) async {
    routing.navigateTo(route, params: params, queryParams: queryParams, arguments: arguments);
    return Navigator.of(context).pushNamed<T>(route, arguments: arguments);
  }

  /// Go back using Navigator and update routing state
  static void goBackWithState(BuildContext context, RxRouting routing) {
    routing.goBack();
    Navigator.of(context).pop();
  }
}

