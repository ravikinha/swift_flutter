import 'dart:async';
import 'dart:convert';
import 'network_interceptor.dart';

/// Helper class to intercept HTTP requests made with the http package
/// 
/// This provides a simple way to wrap http package calls to automatically
/// capture requests and responses for debugging.
/// 
/// Example usage:
/// ```dart
/// import 'package:http/http.dart' as http;
/// 
/// // Instead of: final response = await http.get(Uri.parse('https://api.example.com/data'));
/// // Use:
/// final response = await SwiftHttpHelper.intercept(
///   () => http.get(Uri.parse('https://api.example.com/data')),
///   method: 'GET',
///   url: 'https://api.example.com/data',
/// );
/// ```
class SwiftHttpHelper {
  /// Intercept any HTTP request
  /// 
  /// [requestFn] - The function that makes the HTTP request
  /// [method] - HTTP method (GET, POST, PUT, DELETE, etc.)
  /// [url] - The URL being requested
  /// [body] - Optional request body
  /// [headers] - Optional request headers
  static Future<T> intercept<T>(
    Future<T> Function() requestFn, {
    required String method,
    required String url,
    dynamic body,
    Map<String, String>? headers,
  }) async {
    return _interceptRequest(method, url, body, headers, requestFn);
  }

  /// Intercept an HTTP GET request
  static Future<T> interceptGet<T>(
    Future<T> Function() requestFn,
    String url,
  ) async {
    return _interceptRequest('GET', url, null, null, requestFn);
  }

  /// Intercept an HTTP POST request
  static Future<T> interceptPost<T>(
    Future<T> Function() requestFn,
    String url,
    dynamic body,
    Map<String, String>? headers,
  ) async {
    return _interceptRequest('POST', url, body, headers, requestFn);
  }

  /// Intercept an HTTP PUT request
  static Future<T> interceptPut<T>(
    Future<T> Function() requestFn,
    String url,
    dynamic body,
    Map<String, String>? headers,
  ) async {
    return _interceptRequest('PUT', url, body, headers, requestFn);
  }

  /// Intercept an HTTP DELETE request
  static Future<T> interceptDelete<T>(
    Future<T> Function() requestFn,
    String url,
  ) async {
    return _interceptRequest('DELETE', url, null, null, requestFn);
  }

  /// Intercept an HTTP PATCH request
  static Future<T> interceptPatch<T>(
    Future<T> Function() requestFn,
    String url,
    dynamic body,
    Map<String, String>? headers,
  ) async {
    return _interceptRequest('PATCH', url, body, headers, requestFn);
  }

  static Future<T> _interceptRequest<T>(
    String method,
    String url,
    dynamic body,
    Map<String, String>? headers,
    Future<T> Function() requestFn,
  ) async {
    if (!NetworkInterceptor.isEnabled) {
      return await requestFn();
    }

    // Capture request
    final requestId = NetworkInterceptor.captureRequest(
      method: method,
      url: url,
      headers: headers ?? {},
      body: body,
    );

    try {
      // Execute request
      final response = await requestFn();

      // Try to extract response data using dynamic access
      dynamic responseBody;
      Map<String, String> responseHeaders = {};
      int? statusCode;

      // Use dynamic to check if response has statusCode, headers, body
      try {
        final dynamic resp = response;
        if (resp != null) {
          // Try to access common http.Response properties
          try {
            statusCode = resp.statusCode as int?;
          } catch (_) {}
          
          try {
            responseBody = resp.body;
            // Try to parse JSON if it's a string
            if (responseBody is String) {
              try {
                responseBody = jsonDecode(responseBody);
              } catch (_) {
                // Keep as string if not JSON
              }
            }
          } catch (_) {}
          
          try {
            final headers = resp.headers;
            if (headers is Map) {
              responseHeaders = headers.map((key, value) => 
                MapEntry(key.toString(), value.toString()));
            }
          } catch (_) {}
        }
      } catch (_) {
        // If we can't extract, just use the response as string
        responseBody = response.toString();
      }

      // Capture response
      NetworkInterceptor.captureResponse(
        requestId: requestId,
        statusCode: statusCode,
        headers: responseHeaders,
        body: responseBody,
      );

      return response;
    } catch (e, stackTrace) {
      // Capture error response
      NetworkInterceptor.captureResponse(
        requestId: requestId,
        statusCode: null,
        headers: {},
        body: {'error': e.toString(), 'stackTrace': stackTrace.toString()},
      );
      rethrow;
    }
  }
}

/// Extension to make it easier to intercept http.Response
extension HttpResponseInterceptor on Future {
  /// Intercept an HTTP response
  Future<T> interceptResponse<T>({
    required String method,
    required String url,
    dynamic body,
    Map<String, String>? headers,
  }) async {
    if (!NetworkInterceptor.isEnabled) {
      return await this as Future<T>;
    }

    final requestId = NetworkInterceptor.captureRequest(
      method: method,
      url: url,
      headers: headers ?? {},
      body: body,
    );

    try {
      final response = await this;

      // Try to extract response data if it's an http.Response
      dynamic responseBody;
      Map<String, String> responseHeaders = {};
      int? statusCode;

      // Use dynamic to check if response has statusCode, headers, body
      try {
        final dynamic resp = response;
        if (resp != null) {
          // Try to access common http.Response properties
          try {
            statusCode = resp.statusCode as int?;
          } catch (_) {}
          
          try {
            responseBody = resp.body;
          } catch (_) {}
          
          try {
            final headers = resp.headers;
            if (headers is Map) {
              responseHeaders = headers.map((key, value) => 
                MapEntry(key.toString(), value.toString()));
            }
          } catch (_) {}
        }
      } catch (_) {
        // If we can't extract, just use the response as string
        responseBody = response.toString();
      }

      NetworkInterceptor.captureResponse(
        requestId: requestId,
        statusCode: statusCode,
        headers: responseHeaders,
        body: responseBody,
      );

      return response as T;
    } catch (e, stackTrace) {
      NetworkInterceptor.captureResponse(
        requestId: requestId,
        statusCode: null,
        headers: {},
        body: {'error': e.toString(), 'stackTrace': stackTrace.toString()},
      );
      rethrow;
    }
  }
}

