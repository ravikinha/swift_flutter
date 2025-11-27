import 'package:flutter/material.dart' hide Action;
import 'package:swift_flutter/swift_flutter.dart' hide Action;
import 'package:swift_flutter/core/devtools.dart';
import 'package:swift_flutter/core/reducers.dart' show Action;

/// DevTools Example - Demonstrates DevTools integration
class DevToolsExample extends StatefulWidget {
  const DevToolsExample({super.key});

  @override
  State<DevToolsExample> createState() => _DevToolsExampleState();
}

class _DevToolsExampleState extends State<DevToolsExample> {
  late final Rx<int> counter;
  late final Rx<String> name;
  late final Computed<String> greeting;
  late final ReduxStore<int> counterStore;
  
  bool _devToolsEnabled = false;
  Map<String, dynamic>? _summary;
  Map<String, dynamic>? _stateInspector;
  Map<String, dynamic>? _dependencyGraph;
  Map<String, dynamic>? _performanceReport;
  List<Map<String, dynamic>>? _stateHistory;

  @override
  void initState() {
    super.initState();
    
    // Initialize reactive state
    counter = swift(0, name: 'counter');
    name = swift('Flutter', name: 'name');
    greeting = Computed(() => 'Hello, ${name.value}!', name: 'greeting');
    
    // Initialize Redux store
    counterStore = ReduxStore<int>(
      0,
      (state, action) {
        switch (action.type) {
          case 'INCREMENT':
            return state + 1;
          case 'DECREMENT':
            return state - 1;
          default:
            return state;
        }
      },
      name: 'counterStore',
    );
    
    // Enable DevTools
    _enableDevTools();
  }
  
  void _enableDevTools() {
    SwiftDevTools.enable(
      trackDependencies: true,
      trackStateHistory: true,
      trackPerformance: true,
    );
    _devToolsEnabled = true;
    _refreshData();
  }
  
  void _disableDevTools() {
    SwiftDevTools.disable();
    _devToolsEnabled = false;
    setState(() {
      _summary = null;
      _stateInspector = null;
      _dependencyGraph = null;
      _performanceReport = null;
      _stateHistory = null;
    });
  }
  
  void _refreshData() {
    if (!_devToolsEnabled) return;
    
    setState(() {
      _summary = SwiftDevTools.getSummary();
      _stateInspector = SwiftDevTools.getStateInspector();
      _dependencyGraph = SwiftDevTools.getDependencyGraph();
      _performanceReport = SwiftDevTools.getPerformanceReport();
      _stateHistory = SwiftDevTools.getStateHistory(limit: 10);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Controls
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'DevTools Controls',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _devToolsEnabled ? null : _enableDevTools,
                        child: const Text('Enable DevTools'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _devToolsEnabled ? _disableDevTools : null,
                        child: const Text('Disable DevTools'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _devToolsEnabled ? _refreshData : null,
                        child: const Text('Refresh Data'),
                      ),
                    ),
                  ],
                ),
                if (_devToolsEnabled)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '✅ DevTools Enabled',
                      style: TextStyle(color: Colors.green[700]),
                    ),
                  ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Reactive State Demo
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Reactive State Demo',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Mark(
                  builder: (context) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Counter: ${counter.value}'),
                      Text('Name: ${name.value}'),
                      Text('Greeting: ${greeting.value}'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          counter.value++;
                          _refreshData();
                        },
                        child: const Text('Increment Counter'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          name.value = name.value == 'Flutter' ? 'Dart' : 'Flutter';
                          _refreshData();
                        },
                        child: const Text('Toggle Name'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Redux Store Demo
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Redux Store Demo',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Mark(
                  builder: (context) => Text('Store Counter: ${counterStore.value}'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          counterStore.dispatch(_IncrementAction());
                          _refreshData();
                        },
                        child: const Text('Increment'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          counterStore.dispatch(_DecrementAction());
                          _refreshData();
                        },
                        child: const Text('Decrement'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // DevTools Data Display
        if (_devToolsEnabled && _summary != null) ...[
          _buildSummaryCard(),
          const SizedBox(height: 16),
          _buildStateInspectorCard(),
          const SizedBox(height: 16),
          _buildDependencyGraphCard(),
          const SizedBox(height: 16),
          _buildPerformanceReportCard(),
          const SizedBox(height: 16),
          _buildStateHistoryCard(),
        ],
      ],
    );
  }
  
  Widget _buildSummaryCard() {
    return Card(
      child: ExpansionTile(
        title: const Text('DevTools Summary'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildKeyValue('Enabled', _summary!['enabled'].toString()),
                _buildKeyValue('Track Dependencies', _summary!['trackDependencies'].toString()),
                _buildKeyValue('Track State History', _summary!['trackStateHistory'].toString()),
                _buildKeyValue('Track Performance', _summary!['trackPerformance'].toString()),
                _buildKeyValue('Rx Count', _summary!['rxCount'].toString()),
                _buildKeyValue('Computed Count', _summary!['computedCount'].toString()),
                _buildKeyValue('Mark Count', _summary!['markCount'].toString()),
                _buildKeyValue('Redux Store Count', _summary!['reduxStoreCount'].toString()),
                _buildKeyValue('Dependency Edges', _summary!['dependencyEdges'].toString()),
                _buildKeyValue('State History Size', _summary!['stateHistorySize'].toString()),
                _buildKeyValue('Performance Events', _summary!['performanceEvents'].toString()),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStateInspectorCard() {
    return Card(
      child: ExpansionTile(
        title: Text('State Inspector (${_stateInspector!['totalCount']} states)'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total States: ${_stateInspector!['totalCount']}'),
                const SizedBox(height: 8),
                ...(_stateInspector!['states'] as Map<String, dynamic>).entries.map((entry) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(entry.key),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Type: ${entry.value['type']}'),
                          Text('Name: ${entry.value['name']}'),
                          Text('Value: ${entry.value['value']}'),
                          if (entry.value['actionHistoryCount'] != null)
                            Text('Actions: ${entry.value['actionHistoryCount']}'),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDependencyGraphCard() {
    return Card(
      child: ExpansionTile(
        title: Text('Dependency Graph (${_dependencyGraph!['nodes'].length} nodes, ${_dependencyGraph!['edges'].length} edges)'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildKeyValue('Rx Count', _dependencyGraph!['rxCount'].toString()),
                _buildKeyValue('Computed Count', _dependencyGraph!['computedCount'].toString()),
                _buildKeyValue('Mark Count', _dependencyGraph!['markCount'].toString()),
                const SizedBox(height: 16),
                const Text('Nodes:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...(_dependencyGraph!['nodes'] as List).map((node) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 16, top: 4),
                    child: Text('${node['type']}: ${node['name']} (${node['id']})'),
                  );
                }),
                const SizedBox(height: 16),
                const Text('Edges:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...(_dependencyGraph!['edges'] as List).map((edge) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 16, top: 4),
                    child: Text('${edge['from']} → ${edge['to']}'),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPerformanceReportCard() {
    if (_performanceReport == null || _performanceReport!.containsKey('error')) {
      return Card(
        child: ListTile(
          title: const Text('Performance Report'),
          subtitle: const Text('Not available'),
        ),
      );
    }
    
    return Card(
      child: ExpansionTile(
        title: const Text('Performance Report'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_performanceReport!['totalRebuilds'] != null)
                  _buildKeyValue('Total Rebuilds', _performanceReport!['totalRebuilds'].toString()),
                if (_performanceReport!['totalUpdates'] != null)
                  _buildKeyValue('Total Updates', _performanceReport!['totalUpdates'].toString()),
                if (_performanceReport!['recentEvents'] != null)
                  Text('Recent Events: ${(_performanceReport!['recentEvents'] as List).length}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStateHistoryCard() {
    return Card(
      child: ExpansionTile(
        title: Text('State History (${_stateHistory?.length ?? 0} entries)'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _stateHistory?.map((entry) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(entry['stateId']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Old: ${entry['oldValue']}'),
                        Text('New: ${entry['newValue']}'),
                        Text('Time: ${entry['timestamp']}'),
                      ],
                    ),
                  ),
                );
              }).toList() ?? [],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildKeyValue(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$key:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _IncrementAction implements Action {
  @override
  String get type => 'INCREMENT';
  
  @override
  Map<String, dynamic>? get payload => null;
}

class _DecrementAction implements Action {
  @override
  String get type => 'DECREMENT';
  
  @override
  Map<String, dynamic>? get payload => null;
}

