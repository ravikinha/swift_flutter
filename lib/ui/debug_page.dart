import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../core/network_interceptor.dart';
import '../core/log_interceptor.dart';
import '../core/websocket_interceptor.dart';

/// Debug page to view network requests, responses, and logs
class SwiftDebugPage extends StatefulWidget {
  const SwiftDebugPage({super.key});

  @override
  State<SwiftDebugPage> createState() => _SwiftDebugPageState();
}

class _SwiftDebugPageState extends State<SwiftDebugPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedRequestId = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool get _isMobile => MediaQuery.of(context).size.width < 600;
  bool get _isTablet => MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1200;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.bug_report, color: Colors.blue, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'Swift Debug Tool',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blue,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          isScrollable: _isMobile,
          tabs: [
            Tab(
              icon: const Icon(Icons.network_check, size: 20),
              text: _isMobile ? null : 'HTTP',
            ),
            Tab(
              icon: const Icon(Icons.cable, size: 20),
              text: _isMobile ? null : 'WebSocket',
            ),
            Tab(
              icon: const Icon(Icons.description, size: 20),
              text: _isMobile ? null : 'Logs',
            ),
            Tab(
              icon: const Icon(Icons.code, size: 20),
              text: _isMobile ? null : 'Curl',
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear All',
            onPressed: () {
              _showClearDialog();
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNetworkTab(),
          _buildWebSocketTab(),
          _buildLogsTab(),
          _buildCurlTab(),
        ],
      ),
    );
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text('Are you sure you want to clear all network requests and logs?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              NetworkInterceptor.clear();
              LogInterceptor.clear();
              WebSocketInterceptor.clear();
              setState(() {
                _selectedRequestId = '';
              });
              Navigator.pop(context);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkTab() {
    final requests = NetworkInterceptor.getRequests();
    
    if (requests.isEmpty) {
      return _buildEmptyState(
        icon: Icons.network_check,
        title: 'No Network Requests',
        message: 'Network requests will appear here once you make API calls.',
      );
    }

    if (_isMobile) {
      return _buildMobileNetworkView(requests);
    } else {
      return _buildDesktopNetworkView(requests);
    }
  }

  Widget _buildMobileNetworkView(List<NetworkRequest> requests) {
    if (_selectedRequestId.isEmpty) {
      // Show list view
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).cardColor,
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tap a request to view details',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[requests.length - 1 - index];
                return _buildRequestCard(request, true);
              },
            ),
          ),
        ],
      );
    } else {
      // Show details view
      return _buildRequestDetailsMobile();
    }
  }

  Widget _buildDesktopNetworkView(List<NetworkRequest> requests) {
    return Row(
      children: [
        // Request list sidebar
        Container(
          width: _isTablet ? 250 : 320,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(
              right: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.list, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Requests (${requests.length})',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final request = requests[requests.length - 1 - index];
                    return _buildRequestListItem(request);
                  },
                ),
              ),
            ],
          ),
        ),
        // Request details
        Expanded(
          child: _selectedRequestId.isEmpty
              ? _buildEmptyDetailsView()
              : _buildRequestDetails(),
        ),
      ],
    );
  }

  Widget _buildRequestCard(NetworkRequest request, bool isMobile) {
    final hasResponse = request.response != null;
    final statusCode = request.response?.statusCode;
    
    Color statusColor = Colors.grey;
    String statusText = 'Pending';
    if (statusCode != null) {
      if (statusCode >= 200 && statusCode < 300) {
        statusColor = Colors.green;
        statusText = '$statusCode';
      } else if (statusCode >= 300 && statusCode < 400) {
        statusColor = Colors.blue;
        statusText = '$statusCode';
      } else if (statusCode >= 400) {
        statusColor = Colors.red;
        statusText = '$statusCode';
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedRequestId = request.id;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getMethodColor(request.method).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      request.method,
                      style: TextStyle(
                        color: _getMethodColor(request.method),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (hasResponse)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    )
                  else
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                request.url,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                _formatTimestamp(request.timestamp),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestListItem(NetworkRequest request) {
    final isSelected = request.id == _selectedRequestId;
    final hasResponse = request.response != null;
    final statusCode = request.response?.statusCode;
    
    Color statusColor = Colors.grey;
    if (statusCode != null) {
      if (statusCode >= 200 && statusCode < 300) {
        statusColor = Colors.green;
      } else if (statusCode >= 300 && statusCode < 400) {
        statusColor = Colors.blue;
      } else if (statusCode >= 400) {
        statusColor = Colors.red;
      }
    }

    return InkWell(
      onTap: () {
        setState(() {
          _selectedRequestId = request.id;
        });
      },
      child: Container(
        color: isSelected ? Colors.blue.withValues(alpha: 0.1) : null,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: _getMethodColor(request.method).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                request.method,
                style: TextStyle(
                  color: _getMethodColor(request.method),
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getUrlPath(request.url),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatTimestamp(request.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (hasResponse)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  '$statusCode',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              )
            else
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestDetailsMobile() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: Theme.of(context).cardColor,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _selectedRequestId = '';
                  });
                },
              ),
              const Expanded(
                child: Text(
                  'Request Details',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _buildRequestDetails(),
        ),
      ],
    );
  }

  Widget _buildRequestDetails() {
    final request = NetworkInterceptor.getRequest(_selectedRequestId);
    if (request == null) {
      return const Center(child: Text('Request not found'));
    }

    final hasResponse = request.response != null;
    final statusCode = request.response?.statusCode;
    
    Color statusColor = Colors.grey;
    if (statusCode != null) {
      if (statusCode >= 200 && statusCode < 300) {
        statusColor = Colors.green;
      } else if (statusCode >= 300 && statusCode < 400) {
        statusColor = Colors.blue;
      } else if (statusCode >= 400) {
        statusColor = Colors.red;
      }
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(_isMobile ? 12 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Request Header Card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getMethodColor(request.method).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          request.method,
                          style: TextStyle(
                            color: _getMethodColor(request.method),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (hasResponse) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${request.response!.statusCode}',
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  SelectableText(
                    request.url,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTimestamp(request.timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (hasResponse && request.response!.duration != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Duration: ${request.response!.duration!.inMilliseconds}ms',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Request Section
          _buildDetailSection(
            'Request',
            Icons.arrow_upward,
            Colors.blue,
            [
              _buildDetailItem('Method', request.method),
              _buildDetailItem('URL', request.url),
              _buildDetailItem('Timestamp', _formatTimestamp(request.timestamp)),
              if (request.headers.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildDetailSubsection('Headers', request.headers),
              ],
              if (request.body != null) ...[
                const SizedBox(height: 12),
                _buildDetailSubsection('Body', _formatBody(request.body)),
              ],
            ],
          ),
          
          // Response Section
          if (hasResponse) ...[
            const SizedBox(height: 20),
            _buildDetailSection(
              'Response',
              Icons.arrow_downward,
              statusColor,
              [
                _buildDetailItem('Status Code', '${request.response!.statusCode}'),
                _buildDetailItem('Timestamp', _formatTimestamp(request.response!.timestamp)),
                if (request.response!.duration != null)
                  _buildDetailItem('Duration', '${request.response!.duration!.inMilliseconds}ms'),
                if (request.response!.headers.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildDetailSubsection('Headers', request.response!.headers),
                ],
                if (request.response!.body != null) ...[
                  const SizedBox(height: 12),
                  _buildDetailSubsection('Body', _formatBody(request.response!.body)),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, IconData icon, Color color, List<Widget> children) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSubsection(String title, dynamic data) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
            ),
          ),
          child: SelectableText(
            data is Map ? _formatMap(data) : data.toString(),
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: isDark ? Colors.grey.shade200 : Colors.grey.shade900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyDetailsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.touch_app,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Select a request',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a request from the list to view\ndetailed information',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 48,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsTab() {
    final logs = LogInterceptor.getLogs();
    
    if (logs.isEmpty) {
      return _buildEmptyState(
        icon: Icons.description,
        title: 'No Logs',
        message: 'Logs will appear here when you use swiftPrint() or other logging functions.',
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: Theme.of(context).cardColor,
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                '${logs.length} log entries',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: logs.length,
            reverse: true,
            itemBuilder: (context, index) {
              final log = logs[logs.length - 1 - index];
              return _buildLogCard(log);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLogCard(InterceptedLogEntry log) {
    Color logColor;
    IconData logIcon;
    Color backgroundColor;
    
    switch (log.type) {
      case LogType.error:
        logColor = Colors.red;
        logIcon = Icons.error;
        backgroundColor = Colors.red.withValues(alpha: 0.1);
        break;
      case LogType.warning:
        logColor = Colors.orange;
        logIcon = Icons.warning;
        backgroundColor = Colors.orange.withValues(alpha: 0.1);
        break;
      case LogType.debug:
        logColor = Colors.blue;
        logIcon = Icons.bug_report;
        backgroundColor = Colors.blue.withValues(alpha: 0.1);
        break;
      case LogType.info:
        logColor = Colors.green;
        logIcon = Icons.info;
        backgroundColor = Colors.green.withValues(alpha: 0.1);
        break;
      case LogType.print:
        logColor = Colors.grey;
        logIcon = Icons.print;
        backgroundColor = Colors.grey.withValues(alpha: 0.1);
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 1,
      child: InkWell(
        onTap: log.data != null
            ? () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Row(
                      children: [
                        Icon(logIcon, color: logColor, size: 20),
                        const SizedBox(width: 8),
                        const Text('Log Details'),
                      ],
                    ),
                    content: SingleChildScrollView(
                      child: SelectableText(
                        log.data.toString(),
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(logIcon, color: logColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      log.message,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTimestamp(log.timestamp),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (log.data != null)
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: Colors.grey.shade400,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebSocketTab() {
    final connections = WebSocketInterceptor.getConnections();
    
    if (connections.isEmpty) {
      return _buildEmptyState(
        icon: Icons.cable,
        title: 'No WebSocket Connections',
        message: 'WebSocket connections and events will appear here when you use SwiftWebSocket.connect().',
      );
    }

    if (_isMobile) {
      return _buildMobileWebSocketView(connections);
    } else {
      return _buildDesktopWebSocketView(connections);
    }
  }

  Widget _buildMobileWebSocketView(List<WebSocketConnection> connections) {
    if (_selectedRequestId.isEmpty) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).cardColor,
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tap a connection to view events',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: connections.length,
              itemBuilder: (context, index) {
                final connection = connections[connections.length - 1 - index];
                return _buildWebSocketCard(connection, true);
              },
            ),
          ),
        ],
      );
    } else {
      return _buildWebSocketDetailsMobile();
    }
  }

  Widget _buildDesktopWebSocketView(List<WebSocketConnection> connections) {
    return Row(
      children: [
        Container(
          width: _isTablet ? 250 : 320,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(
              right: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cable, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Connections (${connections.length})',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: connections.length,
                  itemBuilder: (context, index) {
                    final connection = connections[connections.length - 1 - index];
                    return _buildWebSocketListItem(connection);
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _selectedRequestId.isEmpty
              ? _buildEmptyDetailsView()
              : _buildWebSocketDetails(),
        ),
      ],
    );
  }

  Widget _buildWebSocketCard(WebSocketConnection connection, bool isMobile) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedRequestId = connection.id;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: connection.isConnected 
                          ? Colors.green.withValues(alpha: 0.2)
                          : Colors.grey.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      connection.isConnected ? Icons.cable : Icons.cable_outlined,
                      color: connection.isConnected ? Colors.green : Colors.grey,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getUrlPath(connection.url),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: connection.isConnected 
                          ? Colors.green.withValues(alpha: 0.2)
                          : Colors.grey.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      connection.isConnected ? 'Connected' : 'Disconnected',
                      style: TextStyle(
                        color: connection.isConnected ? Colors.green : Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.event, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    '${connection.events.length} events',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatTimestamp(connection.connectedAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebSocketListItem(WebSocketConnection connection) {
    final isSelected = connection.id == _selectedRequestId;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedRequestId = connection.id;
        });
      },
      child: Container(
        color: isSelected ? Colors.blue.withValues(alpha: 0.1) : null,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: connection.isConnected 
                    ? Colors.green.withValues(alpha: 0.2)
                    : Colors.grey.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                connection.isConnected ? Icons.cable : Icons.cable_outlined,
                color: connection.isConnected ? Colors.green : Colors.grey,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getUrlPath(connection.url),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        '${connection.events.length} events',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: connection.isConnected ? Colors.green : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebSocketDetailsMobile() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: Theme.of(context).cardColor,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _selectedRequestId = '';
                  });
                },
              ),
              const Expanded(
                child: Text(
                  'WebSocket Details',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _buildWebSocketDetails(),
        ),
      ],
    );
  }

  Widget _buildWebSocketDetails() {
    final connection = WebSocketInterceptor.getConnection(_selectedRequestId);
    if (connection == null) {
      return const Center(child: Text('Connection not found'));
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(_isMobile ? 12 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Connection Header Card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: connection.isConnected 
                              ? Colors.green.withValues(alpha: 0.2)
                              : Colors.grey.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          connection.isConnected ? Icons.cable : Icons.cable_outlined,
                          color: connection.isConnected ? Colors.green : Colors.grey,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              connection.isConnected ? 'Connected' : 'Disconnected',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: connection.isConnected ? Colors.green : Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            SelectableText(
                              connection.url,
                              style: const TextStyle(
                                fontSize: 13,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildInfoChip('Events', '${connection.events.length}'),
                      const SizedBox(width: 8),
                      _buildInfoChip('Connected', _formatTimestamp(connection.connectedAt)),
                      if (connection.disconnectedAt != null) ...[
                        const SizedBox(width: 8),
                        _buildInfoChip('Disconnected', _formatTimestamp(connection.disconnectedAt!)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Connection Info
          _buildDetailSection(
            'Connection Info',
            Icons.info,
            Colors.blue,
            [
              _buildDetailItem('URL', connection.url),
              _buildDetailItem('Connected At', _formatTimestamp(connection.connectedAt)),
              if (connection.disconnectedAt != null)
                _buildDetailItem('Disconnected At', _formatTimestamp(connection.disconnectedAt!)),
              if (connection.headers.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildDetailSubsection('Headers', connection.headers),
              ],
            ],
          ),
          
          // Events Section
          const SizedBox(height: 20),
          _buildDetailSection(
            'Events (${connection.events.length})',
            Icons.event,
            Colors.purple,
            [
              if (connection.events.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No events captured yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else
                ...connection.events.map((event) => _buildEventCard(event)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildEventCard(WebSocketEvent event) {
    Color eventColor;
    IconData eventIcon;
    String eventLabel;
    
    switch (event.type) {
      case WebSocketEventType.connect:
        eventColor = Colors.green;
        eventIcon = Icons.link;
        eventLabel = 'Connected';
        break;
      case WebSocketEventType.disconnect:
        eventColor = Colors.red;
        eventIcon = Icons.link_off;
        eventLabel = 'Disconnected';
        break;
      case WebSocketEventType.messageSent:
        eventColor = Colors.blue;
        eventIcon = Icons.arrow_upward;
        eventLabel = 'Sent';
        break;
      case WebSocketEventType.messageReceived:
        eventColor = Colors.orange;
        eventIcon = Icons.arrow_downward;
        eventLabel = 'Received';
        break;
      case WebSocketEventType.error:
        eventColor = Colors.red;
        eventIcon = Icons.error;
        eventLabel = 'Error';
        break;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: eventColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(eventIcon, color: eventColor, size: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  eventLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: eventColor,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatTimestamp(event.timestamp),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            if (event.data != null || event.error != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: SelectableText(
                  event.error ?? event.data?.toString() ?? '',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: isDark ? Colors.grey.shade200 : Colors.grey.shade900,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCurlTab() {
    final requests = NetworkInterceptor.getRequests();
    
    if (requests.isEmpty) {
      return _buildEmptyState(
        icon: Icons.code,
        title: 'No Curl Commands',
        message: 'Curl commands will be generated for network requests.',
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: Theme.of(context).cardColor,
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                '${requests.length} requests available',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: requests.length,
            reverse: true,
            itemBuilder: (context, index) {
              final request = requests[requests.length - 1 - index];
              return _buildCurlCard(request);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCurlCard(NetworkRequest request) {
    final curl = request.toCurl();
    final hasResponse = request.response != null;
    final statusCode = request.response?.statusCode;
    
    Color statusColor = Colors.grey;
    if (statusCode != null) {
      if (statusCode >= 200 && statusCode < 300) {
        statusColor = Colors.green;
      } else if (statusCode >= 300 && statusCode < 400) {
        statusColor = Colors.blue;
      } else if (statusCode >= 400) {
        statusColor = Colors.red;
      }
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getMethodColor(request.method).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            request.method,
            style: TextStyle(
              color: _getMethodColor(request.method),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        title: Text(
          _getUrlPath(request.url),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Row(
          children: [
            Text(
              _formatTimestamp(request.timestamp),
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
            if (hasResponse) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  '$statusCode',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Curl Command',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 20),
                      tooltip: 'Copy curl command',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: curl));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.white),
                                SizedBox(width: 8),
                                Text('Curl command copied to clipboard'),
                              ],
                            ),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    curl,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                ),
                if (hasResponse) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Response',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                      ),
                    ),
                    child: SelectableText(
                      _formatBody(request.response!.body),
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: isDark ? Colors.grey.shade200 : Colors.grey.shade900,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getMethodColor(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return Colors.green;
      case 'POST':
        return Colors.blue;
      case 'PUT':
        return Colors.orange;
      case 'PATCH':
        return Colors.purple;
      case 'DELETE':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getUrlPath(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.path.isEmpty ? '/' : uri.path;
    } catch (e) {
      return url.length > 50 ? '${url.substring(0, 50)}...' : url;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  String _formatBody(dynamic body) {
    if (body is String) {
      try {
        final decoded = jsonDecode(body);
        return const JsonEncoder.withIndent('  ').convert(decoded);
      } catch (e) {
        return body;
      }
    } else if (body is Map || body is List) {
      return const JsonEncoder.withIndent('  ').convert(body);
    }
    return body.toString();
  }

  String _formatMap(Map map) {
    return map.entries
        .map((e) => '${e.key}: ${e.value}')
        .join('\n');
  }
}
