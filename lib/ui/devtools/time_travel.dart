import 'package:flutter/material.dart';
import 'dart:convert';
import '../../core/devtools.dart' show SwiftDevTools;

/// Time-travel Debugging View - For ReduxStore state history
class TimeTravelView extends StatefulWidget {
  const TimeTravelView({super.key});

  @override
  State<TimeTravelView> createState() => _TimeTravelViewState();
}

class _TimeTravelViewState extends State<TimeTravelView> {
  List<Map<String, dynamic>>? _reduxStores;
  String? _selectedStoreId;
  Map<String, dynamic>? _timeTravelData;
  int? _selectedActionIndex;

  @override
  void initState() {
    super.initState();
    _refreshStores();
  }

  void _refreshStores() {
    setState(() {
      _reduxStores = SwiftDevTools.getAllReduxStores();
    });
  }

  void _loadTimeTravelData(String storeId) {
    setState(() {
      _selectedStoreId = storeId;
      _timeTravelData = SwiftDevTools.getTimeTravelData(storeId);
      _selectedActionIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildToolbar(),
        Expanded(
          child: _reduxStores == null
              ? const Center(child: CircularProgressIndicator())
              : _buildTimeTravelView(),
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
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _refreshStores,
          ),
          const Spacer(),
          if (_selectedStoreId != null)
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedStoreId = null;
                  _timeTravelData = null;
                  _selectedActionIndex = null;
                });
              },
              icon: const Icon(Icons.close),
              label: const Text('Close Store'),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeTravelView() {
    if (_selectedStoreId == null) {
      return _buildStoreList();
    }

    return _buildTimeTravelInterface();
  }

  Widget _buildStoreList() {
    if (_reduxStores!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No ReduxStore found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create a ReduxStore to use time-travel debugging',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reduxStores!.length,
      itemBuilder: (context, index) {
        final store = _reduxStores![index];
        final id = store['id'] as String? ?? '';
        final name = store['name'] as String? ?? 'ReduxStore';
        final actionCount = store['actionCount'] as int? ?? 0;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.store, color: Colors.purple),
            title: Text(name),
            subtitle: Text('$actionCount actions'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _loadTimeTravelData(id),
          ),
        );
      },
    );
  }

  Widget _buildTimeTravelInterface() {
    if (_timeTravelData == null || _timeTravelData!.containsKey('error')) {
      return Center(
        child: Text(
          _timeTravelData?['error'] ?? 'Unable to load time-travel data',
        ),
      );
    }

    final actionHistory = _timeTravelData!['actionHistory'] as List<dynamic>? ?? [];
    final currentState = _timeTravelData!['currentState'];

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey.shade100,
                child: Row(
                  children: [
                    const Text(
                      'Action History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${actionHistory.length} actions',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: actionHistory.length,
                  itemBuilder: (context, index) {
                    final action = actionHistory[index];
                    final isSelected = _selectedActionIndex == index;
                    final isPast = _selectedActionIndex != null && index < _selectedActionIndex!;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedActionIndex = isSelected ? null : index;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.purple.shade50
                              : isPast
                                  ? Colors.grey.shade50
                                  : null,
                          border: Border(
                            left: BorderSide(
                              color: isSelected
                                  ? Colors.purple
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color: isSelected ? Colors.purple : Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    action['type'] as String? ?? 'Unknown',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isPast ? Colors.grey : Colors.black,
                                    ),
                                  ),
                                  if (action['payload'] != null)
                                    Text(
                                      'Payload: ${action['payload']}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (isPast)
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Container(width: 1, color: Colors.grey.shade300),
        Expanded(
          flex: 3,
          child: _StateViewer(
            state: currentState,
            actionIndex: _selectedActionIndex,
            totalActions: actionHistory.length,
          ),
        ),
      ],
    );
  }
}

class _StateViewer extends StatelessWidget {
  final dynamic state;
  final int? actionIndex;
  final int totalActions;

  const _StateViewer({
    required this.state,
    this.actionIndex,
    required this.totalActions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'State Viewer',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (actionIndex != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Action ${actionIndex! + 1} of $totalActions',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 16),
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
                  _formatState(state),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatState(dynamic state) {
    if (state == null) return 'null';
    try {
      return const JsonEncoder.withIndent('  ').convert(state);
    } catch (e) {
      return state.toString();
    }
  }
}

