import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:swift_flutter/swift_flutter.dart';
import 'package:swift_flutter/core/http_helper.dart';
import 'package:swift_flutter/core/network_interceptor.dart';
import 'package:swift_flutter/core/log_interceptor.dart';

/// Example demonstrating network requests with http and dio packages
/// This shows how the network interceptor captures all API calls
class NetworkExample extends StatefulWidget {
  const NetworkExample({super.key});

  @override
  State<NetworkExample> createState() => _NetworkExampleState();
}

class _NetworkExampleState extends State<NetworkExample> {
  final _searchController = TextEditingController();
  final _results = swift<List<Map<String, dynamic>>>([]);
  final _loading = swift(false);
  final _error = swift<String?>(null);
  late final Dio _dio;

  @override
  void initState() {
    super.initState();
    // Configure Dio with proper settings
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    // Setup Dio interceptor to capture requests
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (NetworkInterceptor.isEnabled) {
          final requestId = NetworkInterceptor.captureRequest(
            method: options.method,
            url: options.uri.toString(),
            headers: options.headers.map((key, value) => 
              MapEntry(key, value.toString())),
            body: options.data,
          );
          // Store request ID for later
          options.extra['swift_debug_id'] = requestId;
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        if (NetworkInterceptor.isEnabled && 
            response.requestOptions.extra.containsKey('swift_debug_id')) {
          final requestId = response.requestOptions.extra['swift_debug_id'] as String;
          NetworkInterceptor.captureResponse(
            requestId: requestId,
            statusCode: response.statusCode,
            headers: response.headers.map.map((key, value) => 
              MapEntry(key, value.join(', '))),
            body: response.data,
          );
        }
        handler.next(response);
      },
      onError: (error, handler) {
        if (NetworkInterceptor.isEnabled && 
            error.requestOptions.extra.containsKey('swift_debug_id')) {
          final requestId = error.requestOptions.extra['swift_debug_id'] as String;
          NetworkInterceptor.captureResponse(
            requestId: requestId,
            statusCode: error.response?.statusCode,
            headers: error.response?.headers.map.map((key, value) => 
              MapEntry(key, value.join(', '))) ?? {},
            body: {'error': error.message, 'type': error.type.toString()},
          );
        }
        handler.next(error);
      },
    ));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _dio.close();
    super.dispose();
  }

  Future<void> _searchWithHttp() async {
    _loading.value = true;
    _error.value = null;
    _results.value = [];

    try {
      // Using http package with SwiftHttpHelper to intercept
      // GET /todos/1 - Single todo item
      final response = await SwiftHttpHelper.intercept(
        () => http.get(
          Uri.parse('https://jsonplaceholder.typicode.com/todos/1'),
        ),
        method: 'GET',
        url: 'https://jsonplaceholder.typicode.com/todos/1',
      );

      if (response.statusCode == 200) {
        // Parse JSON response
        final todo = jsonDecode(response.body) as Map<String, dynamic>;
        _results.value = [{
          'id': todo['id'],
          'title': todo['title'],
          'completed': todo['completed'],
          'userId': todo['userId'],
        }];
        swiftPrint('Fetched todo: ${todo['title']}');
      } else {
        _error.value = 'HTTP Error: ${response.statusCode}';
      }
    } catch (e) {
      _error.value = 'Error: $e';
      swiftPrint('HTTP request error: $e');
    } finally {
      _loading.value = false;
    }
  }

  Future<void> _searchWithDio() async {
    _loading.value = true;
    _error.value = null;
    _results.value = [];

    try {
      // Using Dio package (already intercepted via interceptor)
      // GET /posts - List of posts
      final response = await _dio.get(
        'https://jsonplaceholder.typicode.com/posts',
        queryParameters: _searchController.text.isNotEmpty
            ? {'userId': int.tryParse(_searchController.text) ?? 1}
            : null,
      );

      if (response.statusCode == 200 && response.data is List) {
        final List<dynamic> posts = response.data as List<dynamic>;
        _results.value = posts.take(10).map((post) => {
          'id': post['id'],
          'title': post['title'],
          'body': post['body']?.toString().substring(0, 50) ?? '',
        }).toList();
        swiftPrint('Fetched ${posts.length} posts');
      }
    } catch (e) {
      String errorMessage = 'Error: $e';
      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            errorMessage = 'Connection timeout. Please check your internet connection.';
            break;
          case DioExceptionType.badResponse:
            errorMessage = 'Server error: ${e.response?.statusCode} - ${e.response?.statusMessage}';
            break;
          case DioExceptionType.cancel:
            errorMessage = 'Request was cancelled';
            break;
          case DioExceptionType.connectionError:
            errorMessage = 'Connection failed. Please check:\n1. Internet connection\n2. Network permissions\n3. Firewall settings';
            break;
          case DioExceptionType.badCertificate:
            errorMessage = 'SSL certificate error';
            break;
          case DioExceptionType.unknown:
            errorMessage = 'Network error: ${e.message}';
            break;
        }
      }
      _error.value = errorMessage;
      swiftPrint('Dio request error: $e');
    } finally {
      _loading.value = false;
    }
  }

  Future<void> _fetchUsers() async {
    _loading.value = true;
    _error.value = null;
    _results.value = [];

    try {
      // Using http package - GET /users
      final response = await SwiftHttpHelper.intercept(
        () => http.get(Uri.parse('https://jsonplaceholder.typicode.com/users')),
        method: 'GET',
        url: 'https://jsonplaceholder.typicode.com/users',
      );

      if (response.statusCode == 200) {
        // Parse JSON response
        final List<dynamic> users = jsonDecode(response.body) as List<dynamic>;
        _results.value = users.map((user) => {
          'id': user['id'],
          'name': user['name'],
          'email': user['email'],
          'phone': user['phone'],
        }).toList();
        swiftPrint('Fetched ${users.length} users');
      } else {
        _error.value = 'HTTP Error: ${response.statusCode}';
      }
    } catch (e) {
      _error.value = 'Error: $e';
      swiftPrint('Fetch users error: $e');
    } finally {
      _loading.value = false;
    }
  }

  Future<void> _createPost() async {
    _loading.value = true;
    _error.value = null;
    _results.value = [];

    try {
      // Using Dio to create a post - POST /posts
      final response = await _dio.post(
        'https://jsonplaceholder.typicode.com/posts',
        data: {
          'title': 'Test Post',
          'body': 'This is a test post created via Dio. JSONPlaceholder will return the created post with a new ID.',
          'userId': 1,
        },
      );

      if (response.statusCode == 201) {
        final post = response.data as Map<String, dynamic>;
        _results.value = [{
          'id': post['id'],
          'title': post['title'],
          'body': post['body'],
          'userId': post['userId'],
        }];
        swiftPrint('Post created successfully with ID: ${post['id']}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Post created! ID: ${post['id']} (Check debug tool for details)')),
          );
        }
      }
    } catch (e) {
      String errorMessage = 'Error: $e';
      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            errorMessage = 'Connection timeout. Please check your internet connection.';
            break;
          case DioExceptionType.connectionError:
            errorMessage = 'Connection failed. Please check:\n1. Internet connection\n2. Network permissions\n3. Firewall settings';
            break;
          case DioExceptionType.badResponse:
            errorMessage = 'Server error: ${e.response?.statusCode} - ${e.response?.statusMessage}';
            break;
          case DioExceptionType.cancel:
            errorMessage = 'Request was cancelled';
            break;
          case DioExceptionType.badCertificate:
            errorMessage = 'SSL certificate error';
            break;
          case DioExceptionType.unknown:
            errorMessage = 'Network error: ${e.message}';
            break;
        }
      }
      _error.value = errorMessage;
      swiftPrint('Create post error: $e');
    } finally {
      _loading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Network API Example',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
            const Text(
              'This example demonstrates network requests using JSONPlaceholder API with both http and dio packages. '
              'All requests are automatically captured by the network interceptor. '
              'Open the debug tool (floating button) to see the captured requests, curl commands, and responses.',
              style: TextStyle(fontSize: 14),
            ),
          const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'User ID (optional)',
                hintText: 'Enter user ID for filtering posts (e.g., 1)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          const SizedBox(height: 16),
          Swift(
            builder: (context) => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _loading.value ? null : _searchWithHttp,
                  icon: const Icon(Icons.http),
                  label: const Text('GET /todos/1 (http)'),
                ),
                ElevatedButton.icon(
                  onPressed: _loading.value ? null : _searchWithDio,
                  icon: const Icon(Icons.cloud_download),
                  label: const Text('GET /posts (dio)'),
                ),
                ElevatedButton.icon(
                  onPressed: _loading.value ? null : _fetchUsers,
                  icon: const Icon(Icons.people),
                  label: const Text('GET Users (http)'),
                ),
                ElevatedButton.icon(
                  onPressed: _loading.value ? null : _createPost,
                  icon: const Icon(Icons.add),
                  label: const Text('POST Create (dio)'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Swift(
            builder: (context) {
              if (_loading.value) {
                return const Center(child: CircularProgressIndicator());
              } else if (_error.value != null) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Text(
                    _error.value!,
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }             else if (_results.value.isNotEmpty) {
                return SizedBox(
                  height: 300,
                  child: ListView.builder(
                    itemCount: _results.value.length,
                    itemBuilder: (context, index) {
                      final item = _results.value[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(
                            item['title'] ?? item['name'] ?? 'Item ${item['id']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            item['body'] ?? 
                            item['email'] ?? 
                            item['phone'] ?? 
                            (item['completed'] != null ? 'Completed: ${item['completed']}' : ''),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          leading: CircleAvatar(
                            child: Text('${item['id']}'),
                          ),
                        ),
                      );
                    },
                  ),
                );
              } else {
                return const SizedBox(
                  height: 200,
                  child: Center(
                    child: Text(
                      'Click a button to make API calls.\n'
                      'All requests will be captured in the debug tool.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

