import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'network_interceptor.dart';
import 'websocket_interceptor.dart';

/// Public API for automatic HTTP interception
/// 
/// This class provides automatic interception of all HTTP traffic
/// (both Dio and http package) without requiring app code changes.
class AutoInjector {
  static bool _enabled = false;

  /// Call once at app startup (main) before any HTTP is done.
  /// 
  /// Example:
  /// ```dart
  /// void main() {
  ///   AutoInjector.enable();
  ///   runApp(MyApp());
  /// }
  /// ```
  static void enable() {
    print('[AutoInjector] enable() called');
    if (_enabled) {
      print('[AutoInjector] Already enabled, returning');
      return;
    }
    _enabled = true;
    print('[AutoInjector] Setting _enabled = true');
    
    final previous = HttpOverrides.current;
    print('[AutoInjector] Previous HttpOverrides: ${previous?.runtimeType}');
    
    // Create our intercepting overrides
    final interceptingOverrides = InterceptingHttpOverrides();
    print('[AutoInjector] Created InterceptingHttpOverrides');
    
    HttpOverrides.global = _ChainedOverrides(
      newOverrides: interceptingOverrides,
      previous: previous is _ChainedOverrides ? previous.previous : previous,
    );
    print('[AutoInjector] HttpOverrides.global set to _ChainedOverrides');
    print('[AutoInjector] Current HttpOverrides.current: ${HttpOverrides.current.runtimeType}');
  }

  /// Disable automatic injection
  static void disable() {
    if (!_enabled) return;
    _enabled = false;
    
    if (HttpOverrides.current is _ChainedOverrides) {
      final current = HttpOverrides.current as _ChainedOverrides;
      HttpOverrides.global = current.previous;
    } else {
      HttpOverrides.global = null;
    }
  }

  /// Check if auto-injection is enabled
  static bool get isEnabled => _enabled;
}

/// A small wrapper to chain existing overrides and our overrides
class _ChainedOverrides extends HttpOverrides {
  final HttpOverrides? previous;
  final InterceptingHttpOverrides newOverrides;

  _ChainedOverrides({required this.newOverrides, this.previous});

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    print('[AutoInjector] _ChainedOverrides.createHttpClient() called');
    // If there is a previous override, let it create the raw client first,
    // then wrap that client with our interceptor.
    if (previous != null) {
      print('[AutoInjector] Previous override exists, creating base client');
      final base = previous!.createHttpClient(context);
      print('[AutoInjector] Base client created: ${base.runtimeType}');
      final wrapped = _InterceptingHttpClient(base);
      print('[AutoInjector] Returning wrapped client: ${wrapped.runtimeType}');
      return wrapped;
    } else {
      print('[AutoInjector] No previous override, using newOverrides');
      final client = newOverrides.createHttpClient(context);
      print('[AutoInjector] Client from newOverrides: ${client.runtimeType}');
      return client;
    }
  }
}

/// InterceptingHttpOverrides: returns an intercepting HttpClient
class InterceptingHttpOverrides extends HttpOverrides {
  InterceptingHttpOverrides() {
    print('[AutoInjector] InterceptingHttpOverrides constructor called');
  }

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    print('[AutoInjector] InterceptingHttpOverrides.createHttpClient() called with context: ${context != null}');
    final client = super.createHttpClient(context);
    print('[AutoInjector] Base client from super: ${client.runtimeType}');
    final wrapped = _InterceptingHttpClient(client);
    print('[AutoInjector] Returning _InterceptingHttpClient: ${wrapped.runtimeType}');
    return wrapped;
  }
}

/// The intercepting HttpClient implementation (delegates to inner client)
class _InterceptingHttpClient implements HttpClient {
  final HttpClient _inner;

  _InterceptingHttpClient(this._inner);

  // Intercept the methods that create requests:
  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    print('[AutoInjector] _InterceptingHttpClient.openUrl() called: $method $url');
    final req = await _inner.openUrl(method, url);
    print('[AutoInjector] Request created: ${req.runtimeType}');
    final wrapped = _InterceptingRequest(req);
    print('[AutoInjector] Returning wrapped request: ${wrapped.runtimeType}');
    return wrapped;
  }

  @override
  Future<HttpClientRequest> open(String method, String host, int port, String path) async {
    final req = await _inner.open(method, host, port, path);
    return _InterceptingRequest(req);
  }

  // other creation methods delegate to _inner and then wrap
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _wrap(await _inner.getUrl(url));

  @override
  Future<HttpClientRequest> postUrl(Uri url) async => _wrap(await _inner.postUrl(url));

  @override
  Future<HttpClientRequest> putUrl(Uri url) async => _wrap(await _inner.putUrl(url));

  @override
  Future<HttpClientRequest> deleteUrl(Uri url) async => _wrap(await _inner.deleteUrl(url));

  @override
  Future<HttpClientRequest> patchUrl(Uri url) async => _wrap(await _inner.patchUrl(url));

  @override
  Future<HttpClientRequest> headUrl(Uri url) async => _wrap(await _inner.headUrl(url));

  @override
  Future<HttpClientRequest> get(String host, int port, String path) async => _wrap(await _inner.get(host, port, path));

  @override
  Future<HttpClientRequest> post(String host, int port, String path) async => _wrap(await _inner.post(host, port, path));

  @override
  Future<HttpClientRequest> put(String host, int port, String path) async => _wrap(await _inner.put(host, port, path));

  @override
  Future<HttpClientRequest> delete(String host, int port, String path) async => _wrap(await _inner.delete(host, port, path));

  @override
  Future<HttpClientRequest> patch(String host, int port, String path) async => _wrap(await _inner.patch(host, port, path));

  @override
  Future<HttpClientRequest> head(String host, int port, String path) async => _wrap(await _inner.head(host, port, path));

  HttpClientRequest _wrap(HttpClientRequest req) {
    print('[AutoInjector] _InterceptingHttpClient._wrap() called for: ${req.method} ${req.uri}');
    final wrapped = _InterceptingRequest(req);
    print('[AutoInjector] Wrapped request: ${wrapped.runtimeType}');
    return wrapped;
  }

  // delegate everything else to _inner
  @override
  void addCredentials(Uri url, String realm, HttpClientCredentials credentials) => _inner.addCredentials(url, realm, credentials);

  @override
  void addProxyCredentials(String host, int port, String realm, HttpClientCredentials credentials) =>
      _inner.addProxyCredentials(host, port, realm, credentials);

  @override
  set authenticate(Future<bool> Function(Uri url, String scheme, String? realm)? f) => _inner.authenticate = f;

  @override
  set authenticateProxy(Future<bool> Function(String host, int port, String scheme, String? realm)? f) =>
      _inner.authenticateProxy = f;

  @override
  Duration? get connectionTimeout => _inner.connectionTimeout;

  @override
  set connectionTimeout(Duration? val) => _inner.connectionTimeout = val;

  @override
  set idleTimeout(Duration? timeout) {
    if (timeout != null) {
      _inner.idleTimeout = timeout;
    }
  }

  @override
  int? get maxConnectionsPerHost => _inner.maxConnectionsPerHost;

  @override
  set maxConnectionsPerHost(int? val) => _inner.maxConnectionsPerHost = val;

  @override
  void close({bool force = false}) => _inner.close(force: force);

  @override
  bool get autoUncompress => _inner.autoUncompress;

  @override
  set autoUncompress(bool val) => _inner.autoUncompress = val;

  @override
  String? get userAgent => _inner.userAgent;

  @override
  set userAgent(String? val) => _inner.userAgent = val;

  // Handle badCertificateCallback which is not a standard HttpClient property
  // but Dio tries to set it
  dynamic noSuchMethod(Invocation invocation) {
    print('[AutoInjector] _InterceptingHttpClient.noSuchMethod() called: ${invocation.memberName}');
    
    // Handle badCertificateCallback setter (Dio uses this for SSL)
    if (invocation.memberName == Symbol('badCertificateCallback=') && 
        invocation.isSetter &&
        invocation.positionalArguments.isNotEmpty) {
      print('[AutoInjector] Handling badCertificateCallback setter via noSuchMethod');
      // badCertificateCallback is set when creating HttpClient, not as a property
      // We can't set it after creation, but we can ignore it since HttpOverrides handles it
      return;
    }
    
    return super.noSuchMethod(invocation);
  }
}

/// Request wrapper to intercept on close()
class _InterceptingRequest implements HttpClientRequest {
  final HttpClientRequest _inner;

  _InterceptingRequest(this._inner) {
    print('[AutoInjector] _InterceptingRequest created for: ${_inner.method} ${_inner.uri}');
    print('[AutoInjector] Request headers: ${_inner.headers}');
    print('[AutoInjector] Request contentLength: ${_inner.contentLength}');
  }

  // Intercept close: capture request/response and forward to NetworkInterceptor
  @override
  Future<HttpClientResponse> close() async {
    print('[AutoInjector] _InterceptingRequest.close() called for: ${_inner.method} ${_inner.uri}');
    if (!NetworkInterceptor.isEnabled) {
      print('[AutoInjector] NetworkInterceptor not enabled, returning original response');
      return await _inner.close();
    }
    print('[AutoInjector] NetworkInterceptor is enabled, proceeding with interception');

    try {
      print('[AutoInjector] Calling _inner.close()...');
      final response = await _inner.close();
      print('[AutoInjector] Response received: statusCode=${response.statusCode}, contentLength=${response.contentLength}');
      
      // Use the shared interception method
      return await _interceptResponse(response);
    } catch (e, stackTrace) {
      print('[AutoInjector] Error in close(): $e');
      print('[AutoInjector] StackTrace: $stackTrace');
      
      // Capture request for error tracking
      final headers = <String, String>{};
      _inner.headers.forEach((key, values) {
        headers[key] = values.join(', ');
      });
      
      final requestId = NetworkInterceptor.captureRequest(
        method: _inner.method,
        url: _inner.uri.toString(),
        headers: headers,
        body: null,
      );
      
      // Capture error response
      NetworkInterceptor.captureResponse(
        requestId: requestId,
        statusCode: null,
        headers: {},
        body: e.toString(),
      );
      print('[AutoInjector] Error response captured, rethrowing');
      rethrow;
    }
  }

  // Delegate all other members to _inner
  @override
  Encoding get encoding => _inner.encoding;

  @override
  set encoding(Encoding value) => _inner.encoding = value;

  @override
  void abort([Object? exception, StackTrace? stackTrace]) => _inner.abort(exception, stackTrace);

  @override
  void add(List<int> data) {
    print('[AutoInjector] _InterceptingRequest.add() called with ${data.length} bytes');
    _inner.add(data);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) => _inner.addError(error, stackTrace);

  @override
  Future<void> addStream(Stream<List<int>> stream) {
    print('[AutoInjector] _InterceptingRequest.addStream() called');
    return _inner.addStream(stream);
  }

  @override
  Future<void> flush() {
    print('[AutoInjector] _InterceptingRequest.flush() called');
    return _inner.flush();
  }

  @override
  HttpConnectionInfo? get connectionInfo => _inner.connectionInfo;

  @override
  List<Cookie> get cookies => _inner.cookies;

  @override
  Future<HttpClientResponse> get done {
    print('[AutoInjector] _InterceptingRequest.done getter accessed');
    return _inner.done.then((response) async {
      print('[AutoInjector] _InterceptingRequest.done future completed with response: statusCode=${response.statusCode}, contentLength=${response.contentLength}');
      
      // Intercept the response from done property as well
      if (NetworkInterceptor.isEnabled) {
        print('[AutoInjector] NetworkInterceptor enabled, intercepting response from done');
        return await _interceptResponse(response);
      }
      
      return response;
    }).catchError((error) {
      print('[AutoInjector] _InterceptingRequest.done future error: $error');
      throw error;
    });
  }
  
  /// Intercept response and capture it for network interceptor
  Future<HttpClientResponse> _interceptResponse(HttpClientResponse response) async {
    print('[AutoInjector] _interceptResponse() called');
    
    // Capture request details (we need to get them from the request)
    final headers = <String, String>{};
    _inner.headers.forEach((key, values) {
      headers[key] = values.join(', ');
    });

    String? body;
    try {
      if (_inner.contentLength > 0) {
        body = '<Body length: ${_inner.contentLength}>';
      }
    } catch (e) {
      // Ignore errors reading body
    }

    // Check if this is a WebSocket upgrade request
    final isWebSocketUpgrade = headers['upgrade']?.toLowerCase() == 'websocket' ||
        headers['connection']?.toLowerCase().contains('upgrade') == true ||
        _inner.uri.scheme == 'ws' || 
        _inner.uri.scheme == 'wss';
    
    if (isWebSocketUpgrade && WebSocketInterceptor.isEnabled) {
      print('[AutoInjector] Detected WebSocket upgrade request: ${_inner.uri}');
      final wsConnectionId = WebSocketInterceptor.captureConnection(
        url: _inner.uri.toString(),
        headers: headers,
      );
      print('[AutoInjector] WebSocket connection captured with ID: $wsConnectionId');
    }

    final requestId = NetworkInterceptor.captureRequest(
      method: _inner.method,
      url: _inner.uri.toString(),
      headers: headers,
      body: body,
    );
    print('[AutoInjector] Request captured with ID: $requestId');

    // Capture response details
    final responseHeaders = <String, String>{};
    response.headers.forEach((key, values) {
      responseHeaders[key] = values.join(', ');
    });

    // Use a stream transformer to capture response body without breaking the stream
    print('[AutoInjector] Setting up stream transformer...');
    final bytes = <int>[];
    final completer = Completer<String?>();
    
    // Transform the stream to capture bytes while allowing downstream to read
    print('[AutoInjector] Creating StreamTransformer...');
    final transformedStream = response.transform<List<int>>(
      StreamTransformer<List<int>, List<int>>.fromHandlers(
        handleData: (data, sink) {
          print('[AutoInjector] StreamTransformer.handleData: received ${data.length} bytes');
          bytes.addAll(data);
          print('[AutoInjector] Total bytes captured so far: ${bytes.length}');
          sink.add(data); // Forward data to downstream
          print('[AutoInjector] Data forwarded to downstream sink');
        },
        handleError: (error, stackTrace, sink) {
          print('[AutoInjector] StreamTransformer.handleError: $error');
          sink.addError(error, stackTrace);
          completer.complete('<Error reading response: $error>');
        },
        handleDone: (sink) {
          print('[AutoInjector] StreamTransformer.handleDone: closing sink, total bytes: ${bytes.length}');
          sink.close();
          // Decode bytes after stream is done
          String? responseBody;
          if (bytes.isNotEmpty) {
            try {
              responseBody = utf8.decode(bytes, allowMalformed: true);
              print('[AutoInjector] Decoded response body length: ${responseBody.length}');
            } catch (e) {
              responseBody = '<Binary data: ${bytes.length} bytes>';
              print('[AutoInjector] Failed to decode as UTF-8: $e');
            }
          } else {
            print('[AutoInjector] No bytes to decode');
          }
          completer.complete(responseBody);
          print('[AutoInjector] Completer completed with responseBody');
        },
      ),
    );
    print('[AutoInjector] StreamTransformer created');
    
    // Create a wrapper response that uses the transformed stream
    print('[AutoInjector] Creating _StreamedHttpClientResponse...');
    final wrappedResponse = _StreamedHttpClientResponse(response, transformedStream);
    print('[AutoInjector] Wrapped response created: ${wrappedResponse.runtimeType}');
    
    // Check if this is a WebSocket upgrade response
    final isWebSocketUpgradeResponse = responseHeaders['upgrade']?.toLowerCase() == 'websocket' ||
        responseHeaders['connection']?.toLowerCase().contains('upgrade') == true ||
        response.statusCode == 101; // 101 Switching Protocols

    // Capture response asynchronously after stream completes
    completer.future.then((responseBody) {
      // Handle WebSocket upgrade response
      if (isWebSocketUpgradeResponse && WebSocketInterceptor.isEnabled) {
        print('[AutoInjector] Detected WebSocket upgrade response: statusCode=${response.statusCode}');
        // Find the WebSocket connection ID by matching URL
        final connections = WebSocketInterceptor.getConnections();
        WebSocketConnection? matchingConnection;
        try {
          matchingConnection = connections.firstWhere(
            (conn) => conn.url == _inner.uri.toString(),
          );
        } catch (e) {
          // If no exact match, use the most recent connection
          if (connections.isNotEmpty) {
            matchingConnection = connections.last;
          }
        }
        
        if (matchingConnection != null) {
          if (response.statusCode == 101) {
            WebSocketInterceptor.captureEvent(
              connectionId: matchingConnection.id,
              type: WebSocketEventType.connect,
            );
            print('[AutoInjector] WebSocket connection established');
          } else if (response.statusCode >= 400) {
            WebSocketInterceptor.captureEvent(
              connectionId: matchingConnection.id,
              type: WebSocketEventType.error,
              error: 'HTTP ${response.statusCode}: ${responseBody ?? "Unknown error"}',
            );
            print('[AutoInjector] WebSocket connection failed: ${response.statusCode}');
          }
        }
      }
      print('[AutoInjector] Completer future completed, capturing response: requestId=$requestId, bodyLength=${responseBody?.length ?? 0}');
      NetworkInterceptor.captureResponse(
        requestId: requestId,
        statusCode: response.statusCode,
        headers: responseHeaders,
        body: responseBody,
      );
      print('[AutoInjector] Response captured in NetworkInterceptor');
    }).catchError((error) {
      print('[AutoInjector] Error in completer future: $error');
    });

    print('[AutoInjector] Returning wrapped response from _interceptResponse');
    return wrappedResponse;
  }

  @override
  bool get followRedirects => _inner.followRedirects;

  @override
  set followRedirects(bool value) => _inner.followRedirects = value;

  @override
  int get maxRedirects => _inner.maxRedirects;

  @override
  set maxRedirects(int value) => _inner.maxRedirects = value;

  @override
  void write(Object? obj) {
    print('[AutoInjector] _InterceptingRequest.write() called');
    _inner.write(obj);
  }

  @override
  void writeAll(Iterable objects, [String separator = ""]) => _inner.writeAll(objects, separator);

  @override
  void writeCharCode(int charCode) => _inner.writeCharCode(charCode);

  @override
  void writeln([Object? obj = ""]) => _inner.writeln(obj);

  @override
  HttpHeaders get headers {
    print('[AutoInjector] _InterceptingRequest.headers getter accessed');
    return _inner.headers;
  }

  @override
  String get method {
    print('[AutoInjector] _InterceptingRequest.method getter accessed: ${_inner.method}');
    return _inner.method;
  }

  @override
  Uri get uri {
    print('[AutoInjector] _InterceptingRequest.uri getter accessed: ${_inner.uri}');
    return _inner.uri;
  }

  @override
  void set bufferOutput(bool value) => _inner.bufferOutput = value;

  @override
  bool get bufferOutput => _inner.bufferOutput;

  @override
  bool get persistentConnection => _inner.persistentConnection;

  @override
  set persistentConnection(bool value) {
    print('[AutoInjector] _InterceptingRequest.persistentConnection setter called: $value');
    _inner.persistentConnection = value;
  }

  @override
  int get contentLength => _inner.contentLength;

  @override
  set contentLength(int value) {
    print('[AutoInjector] _InterceptingRequest.contentLength setter called: $value');
    _inner.contentLength = value;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    print('[AutoInjector] _InterceptingRequest.noSuchMethod() called: ${invocation.memberName}');
    print('[AutoInjector] noSuchMethod arguments: ${invocation.positionalArguments}');
    print('[AutoInjector] noSuchMethod named arguments: ${invocation.namedArguments}');
    return _inner.noSuchMethod(invocation);
  }
}

/// A replayable HttpClientResponse: buffers the underlying response bytes and exposes a new stream.
/// This allows us to read the response in the hook and still let Dio/http read it normally.
class _ReplayedHttpClientResponse extends Stream<List<int>> implements HttpClientResponse {
  final HttpClientResponse _original;
  final Uint8List? _bytes;
  final Stream<List<int>> _byteStream;

  _ReplayedHttpClientResponse._(this._original, this._bytes) 
      : _byteStream = _bytes != null 
          ? Stream<List<int>>.fromIterable([_bytes])
          : Stream<List<int>>.empty();

  // Stream<List<int>> implementation forwards to our byte stream
  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _byteStream.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  // HttpClientResponse members delegated to original
  @override
  X509Certificate? get certificate => _original.certificate;

  @override
  HttpConnectionInfo? get connectionInfo => _original.connectionInfo;

  @override
  int get contentLength => _bytes?.length ?? _original.contentLength;

  @override
  bool get persistentConnection => _original.persistentConnection;

  @override
  String get reasonPhrase => _original.reasonPhrase;

  @override
  int get statusCode => _original.statusCode;

  @override
  HttpHeaders get headers => _original.headers;

  @override
  bool get isRedirect => _original.isRedirect;

  @override
  List<RedirectInfo> get redirects => _original.redirects;

  @override
  List<Cookie> get cookies => _original.cookies;

  @override
  Future<Socket> detachSocket() => _original.detachSocket();

  @override
  dynamic noSuchMethod(Invocation invocation) => _original.noSuchMethod(invocation);
}

/// A wrapper for HttpClientResponse that uses a transformed stream
/// This allows us to capture response data without consuming the original stream
class _StreamedHttpClientResponse extends Stream<List<int>> implements HttpClientResponse {
  final HttpClientResponse _original;
  final Stream<List<int>> _transformedStream;

  _StreamedHttpClientResponse(this._original, this._transformedStream) {
    print('[AutoInjector] _StreamedHttpClientResponse created');
  }

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    print('[AutoInjector] _StreamedHttpClientResponse.listen() called');
    final subscription = _transformedStream.listen(
      (data) {
        print('[AutoInjector] Stream data received in listen: ${data.length} bytes');
        onData?.call(data);
      },
      onError: (error, stackTrace) {
        print('[AutoInjector] Stream error in listen: $error');
        onError?.call(error, stackTrace);
      },
      onDone: () {
        print('[AutoInjector] Stream done in listen');
        onDone?.call();
      },
      cancelOnError: cancelOnError,
    );
    print('[AutoInjector] StreamSubscription created: ${subscription.runtimeType}');
    return subscription;
  }

  @override
  X509Certificate? get certificate => _original.certificate;

  @override
  HttpConnectionInfo? get connectionInfo => _original.connectionInfo;

  @override
  int get contentLength => _original.contentLength;

  @override
  bool get persistentConnection => _original.persistentConnection;

  @override
  String get reasonPhrase => _original.reasonPhrase;

  @override
  int get statusCode => _original.statusCode;

  @override
  HttpHeaders get headers => _original.headers;

  @override
  bool get isRedirect => _original.isRedirect;

  @override
  List<RedirectInfo> get redirects => _original.redirects;

  @override
  List<Cookie> get cookies => _original.cookies;

  @override
  Future<Socket> detachSocket() => _original.detachSocket();

  @override
  dynamic noSuchMethod(Invocation invocation) => _original.noSuchMethod(invocation);
}

