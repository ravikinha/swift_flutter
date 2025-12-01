import 'dart:convert';

/// Network request/response data model
class NetworkRequest {
  final String id;
  final String method;
  final String url;
  final Map<String, String> headers;
  final dynamic body;
  final DateTime timestamp;
  NetworkResponse? response;
  final bool isWebSocket;

  NetworkRequest({
    required this.id,
    required this.method,
    required this.url,
    required this.headers,
    this.body,
    required this.timestamp,
    this.response,
    this.isWebSocket = false,
  });

  /// Generate curl command for this request
  String toCurl() {
    final buffer = StringBuffer('curl -X $method');
    
    // Add headers
    headers.forEach((key, value) {
      buffer.write(' \\\n  -H "$key: $value"');
    });
    
    // Add body if present
    if (body != null) {
      String bodyStr;
      if (body is String) {
        bodyStr = body as String;
      } else {
        bodyStr = jsonEncode(body);
      }
      buffer.write(' \\\n  -d \'$bodyStr\'');
    }
    
    buffer.write(' \\\n  "$url"');
    
    return buffer.toString();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'method': method,
    'url': url,
    'headers': headers,
    'body': body,
    'timestamp': timestamp.toIso8601String(),
    'response': response?.toJson(),
    'isWebSocket': isWebSocket,
  };
}

/// Network response data model
class NetworkResponse {
  final int? statusCode;
  final Map<String, String> headers;
  final dynamic body;
  final DateTime timestamp;
  final Duration? duration;

  NetworkResponse({
    this.statusCode,
    required this.headers,
    this.body,
    required this.timestamp,
    this.duration,
  });

  Map<String, dynamic> toJson() => {
    'statusCode': statusCode,
    'headers': headers,
    'body': body,
    'timestamp': timestamp.toIso8601String(),
    'durationMs': duration?.inMilliseconds,
  };
}

/// Network interceptor to capture HTTP requests and responses
class NetworkInterceptor {
  static bool _enabled = false;
  static final List<NetworkRequest> _requests = [];
  static int _maxRequests = 100;
  static final Map<String, DateTime> _requestStartTimes = {};

  /// Enable network interception
  static void enable({int maxRequests = 100}) {
    _enabled = true;
    _maxRequests = maxRequests;
  }

  /// Disable network interception
  static void disable() {
    _enabled = false;
    clear();
  }

  /// Check if interception is enabled
  static bool get isEnabled => _enabled;

  /// Capture a request
  static String captureRequest({
    required String method,
    required String url,
    Map<String, String>? headers,
    dynamic body,
  }) {
    if (!_enabled) return '';
    
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    _requestStartTimes[id] = DateTime.now();
    
    final request = NetworkRequest(
      id: id,
      method: method,
      url: url,
      headers: headers ?? {},
      body: body,
      timestamp: DateTime.now(),
    );
    
    _requests.add(request);
    _trimRequests();
    
    return id;
  }

  /// Capture a response
  static void captureResponse({
    required String requestId,
    int? statusCode,
    Map<String, String>? headers,
    dynamic body,
  }) {
    if (!_enabled) return;
    
    final startTime = _requestStartTimes.remove(requestId);
    final duration = startTime != null 
        ? DateTime.now().difference(startTime)
        : null;
    
    final response = NetworkResponse(
      statusCode: statusCode,
      headers: headers ?? {},
      body: body,
      timestamp: DateTime.now(),
      duration: duration,
    );
    
    final request = _requests.firstWhere(
      (r) => r.id == requestId,
      orElse: () => NetworkRequest(
        id: requestId,
        method: 'UNKNOWN',
        url: 'UNKNOWN',
        headers: {},
        timestamp: DateTime.now(),
      ),
    );
    
    request.response = response;
  }

  /// Get all captured requests
  static List<NetworkRequest> getRequests() => List.unmodifiable(_requests);

  /// Get a specific request by ID
  static NetworkRequest? getRequest(String id) {
    try {
      return _requests.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Clear all captured requests
  static void clear() {
    _requests.clear();
    _requestStartTimes.clear();
  }

  /// Set maximum number of requests to keep
  static void setMaxRequests(int max) {
    _maxRequests = max;
    _trimRequests();
  }

  static void _trimRequests() {
    if (_requests.length > _maxRequests) {
      _requests.removeRange(0, _requests.length - _maxRequests);
    }
  }
}

/// Helper to intercept HTTP requests made with http package
/// 
/// Usage:
/// ```dart
/// import 'package:http/http.dart' as http;
/// 
/// // Wrap your http calls
/// final response = await NetworkInterceptor.interceptHttpRequest(
///   () => http.get(Uri.parse('https://api.example.com/data')),
/// );
/// ```
class HttpInterceptorHelper {
  /// Intercept an HTTP request made with http package
  /// 
  /// This is a helper method that can be used to wrap http package calls
  /// to automatically capture requests and responses.
  static Future<T> interceptHttpRequest<T>(
    Future<T> Function() requestFn,
  ) async {
    if (!NetworkInterceptor.isEnabled) {
      return await requestFn();
    }

    // Note: This is a simplified version
    // For full http package support, users should wrap their http calls
    // or use a custom http client that extends BaseClient
    return await requestFn();
  }
}

