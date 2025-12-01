import 'dart:async';
import 'dart:io';
import 'network_interceptor.dart';

/// Wrapper for HttpClient that intercepts requests
/// 
/// This can be used to automatically capture all HTTP requests made through
/// the standard Dart HttpClient.
class InterceptedHttpClient extends HttpClient {
  final HttpClient _client;
  
  InterceptedHttpClient(this._client);

  @override
  bool get autoUncompress => _client.autoUncompress;

  @override
  Duration? get idleTimeout => _client.idleTimeout;

  @override
  set idleTimeout(Duration? timeout) => _client.idleTimeout = timeout;

  @override
  int? get maxConnectionsPerHost => _client.maxConnectionsPerHost;

  @override
  set maxConnectionsPerHost(int? max) => _client.maxConnectionsPerHost = max;

  @override
  String? get userAgent => _client.userAgent;

  @override
  set userAgent(String? agent) => _client.userAgent = agent;

  @override
  void addCredentials(
    Uri url,
    String realm,
    HttpClientCredentials credentials,
  ) => _client.addCredentials(url, realm, credentials);

  @override
  void addProxyCredentials(
    String host,
    int port,
    String realm,
    HttpClientCredentials credentials,
  ) => _client.addProxyCredentials(host, port, realm, credentials);

  @override
  set authenticate(
    Future<bool> Function(Uri url, String scheme, String? realm)? f,
  ) => _client.authenticate = f;

  @override
  set authenticateProxy(
    Future<bool> Function(String host, int port, String scheme, String? realm)? f,
  ) => _client.authenticateProxy = f;

  @override
  void close({bool force = false}) => _client.close(force: force);

  @override
  Future<HttpClientRequest> delete(String host, int port, String path) =>
      _interceptRequest(() => _client.delete(host, port, path));

  @override
  Future<HttpClientRequest> deleteUrl(Uri url) =>
      _interceptRequest(() => _client.deleteUrl(url));

  @override
  Future<HttpClientRequest> get(String host, int port, String path) =>
      _interceptRequest(() => _client.get(host, port, path));

  @override
  Future<HttpClientRequest> getUrl(Uri url) =>
      _interceptRequest(() => _client.getUrl(url));

  @override
  Future<HttpClientRequest> head(String host, int port, String path) =>
      _interceptRequest(() => _client.head(host, port, path));

  @override
  Future<HttpClientRequest> headUrl(Uri url) =>
      _interceptRequest(() => _client.headUrl(url));

  @override
  Future<HttpClientRequest> open(String method, String host, int port, String path) =>
      _interceptRequest(() => _client.open(method, host, port, path));

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) =>
      _interceptRequest(() => _client.openUrl(method, url));

  @override
  Future<HttpClientRequest> patch(String host, int port, String path) =>
      _interceptRequest(() => _client.patch(host, port, path));

  @override
  Future<HttpClientRequest> patchUrl(Uri url) =>
      _interceptRequest(() => _client.patchUrl(url));

  @override
  Future<HttpClientRequest> post(String host, int port, String path) =>
      _interceptRequest(() => _client.post(host, port, path));

  @override
  Future<HttpClientRequest> postUrl(Uri url) =>
      _interceptRequest(() => _client.postUrl(url));

  @override
  Future<HttpClientRequest> put(String host, int port, String path) =>
      _interceptRequest(() => _client.put(host, port, path));

  @override
  Future<HttpClientRequest> putUrl(Uri url) =>
      _interceptRequest(() => _client.putUrl(url));

  Future<HttpClientRequest> _interceptRequest(
    Future<HttpClientRequest> Function() requestFn,
  ) async {
    final request = await requestFn();
    
    if (NetworkInterceptor.isEnabled) {
      final headers = <String, String>{};
      request.headers.forEach((key, values) {
        headers[key] = values.join(', ');
      });
      
      String? body;
      if (request.contentLength > 0) {
        // Note: Reading the body here consumes it, so we need to handle this carefully
        // For now, we'll just capture the request metadata
      }
      
      final requestId = NetworkInterceptor.captureRequest(
        method: request.method,
        url: request.uri.toString(),
        headers: headers,
        body: body,
      );
      
      // Store request ID in a custom header for later retrieval
      request.headers.add('x-swift-debug-id', requestId);
    }
    
    return request;
  }
}

