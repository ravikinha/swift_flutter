import 'package:flutter/material.dart';
import '../../core/devtools.dart' show SwiftDevTools;

/// Performance Profiler View - Monitor performance metrics
class PerformanceProfilerView extends StatefulWidget {
  const PerformanceProfilerView({super.key});

  @override
  State<PerformanceProfilerView> createState() => _PerformanceProfilerViewState();
}

class _PerformanceProfilerViewState extends State<PerformanceProfilerView> {
  Map<String, dynamic>? _performanceData;
  String _selectedMetric = 'rebuilds';

  @override
  void initState() {
    super.initState();
    _refreshPerformance();
  }

  void _refreshPerformance() {
    setState(() {
      _performanceData = SwiftDevTools.getPerformanceReport();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildToolbar(),
        Expanded(
          child: _performanceData == null
              ? const Center(child: CircularProgressIndicator())
              : _buildPerformanceView(),
        ),
      ],
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.grey.shade100,
      child: Row(
        children: [
          const Text('Metric: '),
          DropdownButton<String>(
            value: _selectedMetric,
            items: const [
              DropdownMenuItem(value: 'rebuilds', child: Text('Rebuilds')),
              DropdownMenuItem(value: 'updates', child: Text('Updates')),
              DropdownMenuItem(value: 'events', child: Text('Events')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedMetric = value ?? 'rebuilds';
              });
            },
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _refreshPerformance,
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear Data',
            onPressed: () {
              // Note: Would need clear method in SwiftDevTools
              _refreshPerformance();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceView() {
    if (_performanceData == null || _performanceData!.containsKey('error')) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.speed_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _performanceData?['error'] ?? 'Performance tracking not enabled',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCards(),
          const SizedBox(height: 24),
          _buildMetricsList(),
          const SizedBox(height: 24),
          _buildRecentEvents(),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    final totalRebuilds = _performanceData!['totalRebuilds'] as int? ?? 0;
    final totalUpdates = _performanceData!['totalUpdates'] as int? ?? 0;
    final totalEvents = _performanceData!['recentEvents']?.length ?? 0;

    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: 'Total Rebuilds',
            value: totalRebuilds.toString(),
            icon: Icons.refresh,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _SummaryCard(
            title: 'Total Updates',
            value: totalUpdates.toString(),
            icon: Icons.update,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _SummaryCard(
            title: 'Recent Events',
            value: totalEvents.toString(),
            icon: Icons.event,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsList() {
    final rebuilds = _performanceData!['rebuilds'] as Map<String, dynamic>? ?? {};
    final avgUpdateTime = _performanceData!['avgUpdateTime'] as Map<String, dynamic>? ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Performance Metrics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (_selectedMetric == 'rebuilds')
          ...rebuilds.entries.map((entry) => _MetricTile(
                name: entry.key,
                value: '${entry.value} rebuilds',
                type: 'rebuilds',
              )),
        if (_selectedMetric == 'updates')
          ...avgUpdateTime.entries.map((entry) => _MetricTile(
                name: entry.key,
                value: '${(entry.value as num).toStringAsFixed(2)} ms avg',
                type: 'updates',
              )),
      ],
    );
  }

  Widget _buildRecentEvents() {
    final events = _performanceData!['recentEvents'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Performance Events',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (events.isEmpty)
          const Text('No recent events')
        else
          ...events.take(20).map((event) => _EventTile(event: event)),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String name;
  final String value;
  final String type;

  const _MetricTile({
    required this.name,
    required this.value,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          type == 'rebuilds' ? Icons.refresh : Icons.timer,
          color: type == 'rebuilds' ? Colors.blue : Colors.green,
        ),
        title: Text(name),
        trailing: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  final Map<String, dynamic> event;

  const _EventTile({required this.event});

  @override
  Widget build(BuildContext context) {
    final name = event['name'] as String? ?? 'Unknown';
    final duration = event['durationMs'] as num? ?? 0;
    final timestamp = event['timestamp'] as String? ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          Icons.event,
          color: duration > 16 ? Colors.red : Colors.green,
        ),
        title: Text(name),
        subtitle: Text(timestamp),
        trailing: Text(
          '${duration.toStringAsFixed(2)} ms',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: duration > 16 ? Colors.red : Colors.green,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }
}

