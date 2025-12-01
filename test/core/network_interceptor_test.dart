import 'package:flutter_test/flutter_test.dart';
import 'package:swift_flutter/core/network_interceptor.dart';

void main() {
  group('NetworkInterceptor', () {
    tearDown(() {
      NetworkInterceptor.disable();
      NetworkInterceptor.clear();
    });

    test('should be disabled by default', () {
      expect(NetworkInterceptor.isEnabled, false);
    });

    test('should enable network interception', () {
      NetworkInterceptor.enable();
      expect(NetworkInterceptor.isEnabled, true);
    });

    test('should disable network interception', () {
      NetworkInterceptor.enable();
      NetworkInterceptor.disable();
      expect(NetworkInterceptor.isEnabled, false);
    });

    test('should capture request', () async {
      NetworkInterceptor.enable();
      
      final requestId = NetworkInterceptor.captureRequest(
        method: 'GET',
        url: 'https://api.example.com/data',
        headers: {'Content-Type': 'application/json'},
        body: null,
      );

      expect(requestId, isNotEmpty);
      // Wait for microtask to complete
      await Future.microtask(() {});
      final requests = NetworkInterceptor.getRequests();
      expect(requests.length, 1);
      expect(requests.first.method, 'GET');
      expect(requests.first.url, 'https://api.example.com/data');
      expect(requests.first.headers['Content-Type'], 'application/json');
    });

    test('should capture request with body', () async {
      NetworkInterceptor.enable();
      
      NetworkInterceptor.captureRequest(
        method: 'POST',
        url: 'https://api.example.com/posts',
        headers: {'Content-Type': 'application/json'},
        body: {'title': 'Test', 'body': 'Content'},
      );

      // Wait for microtask to complete
      await Future.microtask(() {});
      final requests = NetworkInterceptor.getRequests();
      expect(requests.length, 1);
      expect(requests.first.body, {'title': 'Test', 'body': 'Content'});
    });

    test('should capture response', () async {
      NetworkInterceptor.enable();
      
      final requestId = NetworkInterceptor.captureRequest(
        method: 'GET',
        url: 'https://api.example.com/data',
        headers: {},
      );

      // Wait for request microtask to complete
      await Future.microtask(() {});
      
      NetworkInterceptor.captureResponse(
        requestId: requestId,
        statusCode: 200,
        headers: {'Content-Type': 'application/json'},
        body: {'data': 'test'},
      );

      // Wait for response microtask to complete
      await Future.microtask(() {});
      
      final request = NetworkInterceptor.getRequest(requestId);
      expect(request, isNotNull);
      expect(request!.response, isNotNull);
      expect(request.response!.statusCode, 200);
      expect(request.response!.body, {'data': 'test'});
    });

    test('should generate curl command', () {
      NetworkInterceptor.enable();
      
      final request = NetworkRequest(
        id: '1',
        method: 'POST',
        url: 'https://api.example.com/posts',
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer token123'},
        body: {'title': 'Test'},
        timestamp: DateTime.now(),
      );

      final curl = request.toCurl();
      expect(curl, contains('curl -X POST'));
      expect(curl, contains('https://api.example.com/posts'));
      expect(curl, contains('Content-Type: application/json'));
      expect(curl, contains('Authorization: Bearer token123'));
      expect(curl, contains('title')); // Body is JSON encoded
    });

    test('should limit maximum requests', () async {
      NetworkInterceptor.enable(maxRequests: 5);
      
      // Capture requests one at a time, waiting for each to complete
      for (int i = 0; i < 10; i++) {
        NetworkInterceptor.captureRequest(
          method: 'GET',
          url: 'https://api.example.com/data$i',
          headers: {},
        );
        // Wait for this microtask to complete before next call
        await Future.microtask(() {});
      }
      
      final requests = NetworkInterceptor.getRequests();
      expect(requests.length, 5); // Should only keep last 5
    });

    test('should clear all requests', () async {
      NetworkInterceptor.enable();
      
      NetworkInterceptor.captureRequest(
        method: 'GET',
        url: 'https://api.example.com/data',
        headers: {},
      );

      // Wait for capture microtask to complete
      await Future.microtask(() {});
      expect(NetworkInterceptor.getRequests().length, 1);
      
      NetworkInterceptor.clear();
      // Wait for clear microtask to complete
      await Future.microtask(() {});
      expect(NetworkInterceptor.getRequests().length, 0);
    });

    test('should get request by ID', () async {
      NetworkInterceptor.enable();
      
      final requestId = NetworkInterceptor.captureRequest(
        method: 'GET',
        url: 'https://api.example.com/data',
        headers: {},
      );

      // Wait for microtask to complete
      await Future.microtask(() {});
      final request = NetworkInterceptor.getRequest(requestId);
      expect(request, isNotNull);
      expect(request!.id, requestId);
    });

    test('should return null for non-existent request', () {
      NetworkInterceptor.enable();
      
      final request = NetworkInterceptor.getRequest('non-existent');
      expect(request, isNull);
    });
  });

  group('NetworkRequest', () {
    test('should serialize to JSON', () {
      final request = NetworkRequest(
        id: '1',
        method: 'GET',
        url: 'https://api.example.com/data',
        headers: {'Content-Type': 'application/json'},
        body: {'test': 'data'},
        timestamp: DateTime(2024, 1, 1),
      );

      final json = request.toJson();
      expect(json['id'], '1');
      expect(json['method'], 'GET');
      expect(json['url'], 'https://api.example.com/data');
      expect(json['headers'], {'Content-Type': 'application/json'});
      expect(json['body'], {'test': 'data'});
    });
  });

  group('NetworkResponse', () {
    test('should serialize to JSON', () {
      final response = NetworkResponse(
        statusCode: 200,
        headers: {'Content-Type': 'application/json'},
        body: {'data': 'test'},
        timestamp: DateTime(2024, 1, 1),
        duration: const Duration(milliseconds: 150),
      );

      final json = response.toJson();
      expect(json['statusCode'], 200);
      expect(json['headers'], {'Content-Type': 'application/json'});
      expect(json['body'], {'data': 'test'});
      expect(json['durationMs'], 150);
    });
  });
}

