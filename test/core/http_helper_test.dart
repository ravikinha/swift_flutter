import 'package:flutter_test/flutter_test.dart';
import 'package:swift_flutter/core/http_helper.dart';
import 'package:swift_flutter/core/network_interceptor.dart';
import 'package:http/http.dart' as http;

void main() {
  group('SwiftHttpHelper', () {
    setUp(() {
      NetworkInterceptor.enable();
    });

    tearDown(() {
      NetworkInterceptor.disable();
      NetworkInterceptor.clear();
    });

    test('should intercept GET request', () async {
      try {
        final response = await SwiftHttpHelper.interceptGet(
          () => http.get(Uri.parse('https://jsonplaceholder.typicode.com/todos/1')),
          'https://jsonplaceholder.typicode.com/todos/1',
        );
        // Status code can vary, but request should be intercepted
      } catch (e) {
        // Network errors are acceptable
      }
      
      final requests = NetworkInterceptor.getRequests();
      expect(requests.length, 1);
      expect(requests.first.method, 'GET');
      expect(requests.first.url, 'https://jsonplaceholder.typicode.com/todos/1');
    });

    test('should intercept POST request', () async {
      try {
        await SwiftHttpHelper.interceptPost(
          () => http.post(
            Uri.parse('https://jsonplaceholder.typicode.com/posts'),
            headers: {'Content-Type': 'application/json'},
            body: '{"title":"Test"}',
          ),
          'https://jsonplaceholder.typicode.com/posts',
          {'title': 'Test'},
          {'Content-Type': 'application/json'},
        );
      } catch (e) {
        // Network errors are acceptable
      }
      
      final requests = NetworkInterceptor.getRequests();
      expect(requests.length, 1);
      expect(requests.first.method, 'POST');
    });

    test('should intercept PUT request', () async {
      try {
        await SwiftHttpHelper.interceptPut(
          () => http.put(
            Uri.parse('https://jsonplaceholder.typicode.com/posts/1'),
            headers: {'Content-Type': 'application/json'},
            body: '{"title":"Updated"}',
          ),
          'https://jsonplaceholder.typicode.com/posts/1',
          {'title': 'Updated'},
          {'Content-Type': 'application/json'},
        );
      } catch (e) {
        // Network errors are acceptable
      }
      
      final requests = NetworkInterceptor.getRequests();
      expect(requests.length, 1);
      expect(requests.first.method, 'PUT');
    });

    test('should intercept DELETE request', () async {
      try {
        await SwiftHttpHelper.interceptDelete(
          () => http.delete(Uri.parse('https://jsonplaceholder.typicode.com/posts/1')),
          'https://jsonplaceholder.typicode.com/posts/1',
        );
      } catch (e) {
        // Network errors are acceptable
      }
      
      final requests = NetworkInterceptor.getRequests();
      expect(requests.length, 1);
      expect(requests.first.method, 'DELETE');
    });

    test('should intercept PATCH request', () async {
      try {
        await SwiftHttpHelper.interceptPatch(
          () => http.patch(
            Uri.parse('https://jsonplaceholder.typicode.com/posts/1'),
            headers: {'Content-Type': 'application/json'},
            body: '{"title":"Patched"}',
          ),
          'https://jsonplaceholder.typicode.com/posts/1',
          {'title': 'Patched'},
          {'Content-Type': 'application/json'},
        );
      } catch (e) {
        // Network errors are acceptable
      }
      
      final requests = NetworkInterceptor.getRequests();
      expect(requests.length, 1);
      expect(requests.first.method, 'PATCH');
    });

    test('should not intercept when disabled', () async {
      NetworkInterceptor.disable();
      NetworkInterceptor.clear();
      
      try {
        await SwiftHttpHelper.interceptGet(
          () => http.get(Uri.parse('https://jsonplaceholder.typicode.com/todos/1')),
          'https://jsonplaceholder.typicode.com/todos/1',
        );
      } catch (e) {
        // Network errors are acceptable in tests
      }

      // The key assertion: requests should not be captured when disabled
      expect(NetworkInterceptor.getRequests().length, 0);
    });

    test('should capture error responses', () async {
      try {
        await SwiftHttpHelper.interceptGet(
          () => http.get(Uri.parse('https://invalid-url-that-does-not-exist.com')),
          'https://invalid-url-that-does-not-exist.com',
        );
      } catch (e) {
        // Expected to fail
      }

      final requests = NetworkInterceptor.getRequests();
      expect(requests.length, 1);
      expect(requests.first.response, isNotNull);
    });
  });
}

