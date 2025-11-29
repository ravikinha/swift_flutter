import 'package:flutter/material.dart';
import 'dart:convert';
import '../../core/devtools.dart' show SwiftDevTools;

/// State Inspector View - Visual tool to inspect all reactive state
class StateInspectorView extends StatefulWidget {
  const StateInspectorView({super.key});

  @override
  State<StateInspectorView> createState() => _StateInspectorViewState();
}

class _StateInspectorViewState extends State<StateInspectorView> {
  Map<String, dynamic>? _stateData;
  String? _selectedStateId;
  String _searchQuery = '';
  String _filterType = 'All';

  @override
  void initState() {
    super.initState();
    _refreshState();
  }

  void _refreshState() {
    setState(() {
      _stateData = SwiftDevTools.getStateInspector();
    });
  }

  List<MapEntry<String, dynamic>> get _filteredStates {
    if (_stateData == null) return [];
    
    final states = _stateData!['states'] as Map<String, dynamic>? ?? {};
    var entries = states.entries.toList();

    // Filter by type
    if (_filterType != 'All') {
      entries = entries.where((e) {
        final type = e.value['type'] as String? ?? '';
        return type == _filterType;
      }).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      entries = entries.where((e) {
        final name = (e.value['name'] as String? ?? '').toLowerCase();
        final id = e.key.toLowerCase();
        return name.contains(query) || id.contains(query);
      }).toList();
    }

    return entries;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildToolbar(),
        Expanded(
          child: _stateData == null
              ? const Center(child: CircularProgressIndicator())
              : _buildStateList(),
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
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search states...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: _filterType,
            items: const [
              DropdownMenuItem(value: 'All', child: Text('All')),
              DropdownMenuItem(value: 'SwiftValue', child: Text('SwiftValue')),
              DropdownMenuItem(value: 'Computed', child: Text('Computed')),
              DropdownMenuItem(value: 'ReduxStore', child: Text('ReduxStore')),
              DropdownMenuItem(value: 'StoreState', child: Text('StoreState')),
            ],
            onChanged: (value) {
              setState(() {
                _filterType = value ?? 'All';
              });
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _refreshState,
          ),
        ],
      ),
    );
  }

  Widget _buildStateList() {
    final states = _filteredStates;
    
    if (states.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty || _filterType != 'All'
                  ? 'No states match your filters'
                  : 'No reactive state found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: ListView.builder(
            itemCount: states.length,
            itemBuilder: (context, index) {
              final entry = states[index];
              final id = entry.key;
              final data = entry.value as Map<String, dynamic>;
              final isSelected = _selectedStateId == id;

              return _StateListItem(
                id: id,
                data: data,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    _selectedStateId = isSelected ? null : id;
                  });
                },
              );
            },
          ),
        ),
        if (_selectedStateId != null)
          Container(
            width: 1,
            color: Colors.grey.shade300,
          ),
        if (_selectedStateId != null)
          Expanded(
            flex: 3,
            child: _StateDetailView(
              stateId: _selectedStateId!,
              stateData: states.firstWhere((e) => e.key == _selectedStateId).value,
            ),
          ),
      ],
    );
  }
}

class _StateListItem extends StatelessWidget {
  final String id;
  final Map<String, dynamic> data;
  final bool isSelected;
  final VoidCallback onTap;

  const _StateListItem({
    required this.id,
    required this.data,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final type = data['type'] as String? ?? 'Unknown';
    final name = data['name'] as String? ?? id;
    final value = data['value'];
    final status = data['status'] as String?;

    Color typeColor;
    IconData typeIcon;
    switch (type) {
      case 'SwiftValue':
      case 'Rx':
        typeColor = Colors.blue;
        typeIcon = Icons.circle;
        break;
      case 'Computed':
        typeColor = Colors.green;
        typeIcon = Icons.functions;
        break;
      case 'ReduxStore':
        typeColor = Colors.purple;
        typeIcon = Icons.store;
        break;
      case 'StoreState':
        typeColor = Colors.orange;
        typeIcon = Icons.storage;
        break;
      default:
        typeColor = Colors.grey;
        typeIcon = Icons.help_outline;
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : null,
          border: Border(
            left: BorderSide(
              color: isSelected ? Colors.blue : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(typeIcon, color: typeColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatValue(value),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontFamily: 'monospace',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (status != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: const TextStyle(fontSize: 10),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatValue(dynamic value) {
    if (value == null) return 'null';
    if (value is String) return '"$value"';
    if (value is Map || value is List) {
      return const JsonEncoder.withIndent('  ').convert(value);
    }
    return value.toString();
  }
}

class _StateDetailView extends StatelessWidget {
  final String stateId;
  final Map<String, dynamic> stateData;

  const _StateDetailView({
    required this.stateId,
    required this.stateData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'State Details',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Divider(),
          const SizedBox(height: 8),
          _DetailRow(label: 'ID', value: stateId),
          _DetailRow(
            label: 'Type',
            value: stateData['type'] as String? ?? 'Unknown',
          ),
          _DetailRow(
            label: 'Name',
            value: stateData['name'] as String? ?? 'N/A',
          ),
          if (stateData['createdAt'] != null)
            _DetailRow(
              label: 'Created At',
              value: stateData['createdAt'] as String? ?? 'N/A',
            ),
          const SizedBox(height: 16),
          const Text(
            'Value',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  _formatValue(stateData['value']),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
          if (stateData['actionHistoryCount'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: _DetailRow(
                label: 'Action History',
                value: '${stateData['actionHistoryCount']} actions',
              ),
            ),
        ],
      ),
    );
  }

  String _formatValue(dynamic value) {
    if (value == null) return 'null';
    try {
      return const JsonEncoder.withIndent('  ').convert(value);
    } catch (e) {
      return value.toString();
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}

