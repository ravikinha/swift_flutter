import 'package:flutter/material.dart';
import '../core/devtools.dart' show SwiftDevTools;
import 'devtools/state_inspector.dart';
import 'devtools/dependency_graph.dart';
import 'devtools/performance_profiler.dart';
import 'devtools/time_travel.dart';
import 'devtools/devtools_tabs.dart';

/// Main DevTools UI widget for Swift Flutter
/// 
/// Provides comprehensive visual debugging tools:
/// - State Inspector: View all reactive state
/// - Dependency Graph: Visualize dependencies
/// - Performance Profiler: Monitor performance
/// - Time-travel Debugging: For ReduxStore
class SwiftDevToolsUI extends StatefulWidget {
  final bool enableStateInspector;
  final bool enableDependencyGraph;
  final bool enablePerformanceProfiler;
  final bool enableTimeTravel;
  
  const SwiftDevToolsUI({
    super.key,
    this.enableStateInspector = true,
    this.enableDependencyGraph = true,
    this.enablePerformanceProfiler = true,
    this.enableTimeTravel = true,
  });

  @override
  State<SwiftDevToolsUI> createState() => _SwiftDevToolsUIState();
}

class _SwiftDevToolsUIState extends State<SwiftDevToolsUI> {
  int _selectedTab = 0;
  bool _isEnabled = false;

  @override
  void initState() {
    super.initState();
    _isEnabled = SwiftDevTools.isEnabled;
    if (!_isEnabled) {
      // Auto-enable if not already enabled
      SwiftDevTools.enable(
        trackDependencies: widget.enableDependencyGraph,
        trackStateHistory: widget.enableTimeTravel,
        trackPerformance: widget.enablePerformanceProfiler,
      );
      _isEnabled = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isEnabled) {
      return _buildEnablePrompt();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Swift Flutter DevTools'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => setState(() {}),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => _showSettings(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: _buildTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildEnablePrompt() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Swift Flutter DevTools'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bug_report,
                size: 64,
                color: Colors.blue.shade300,
              ),
              const SizedBox(height: 24),
              const Text(
                'DevTools Not Enabled',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Enable DevTools in your app to use visual debugging tools.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  SwiftDevTools.enable(
                    trackDependencies: widget.enableDependencyGraph,
                    trackStateHistory: widget.enableTimeTravel,
                    trackPerformance: widget.enablePerformanceProfiler,
                  );
                  setState(() => _isEnabled = true);
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Enable DevTools'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Add this to your main.dart:\n'
                'SwiftDevTools.enable();',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = <DevToolsTab>[];
    
    if (widget.enableStateInspector) {
      tabs.add(DevToolsTab(
        index: tabs.length,
        icon: Icons.inventory_2,
        label: 'State Inspector',
      ));
    }
    
    if (widget.enableDependencyGraph) {
      tabs.add(DevToolsTab(
        index: tabs.length,
        icon: Icons.account_tree,
        label: 'Dependencies',
      ));
    }
    
    if (widget.enablePerformanceProfiler) {
      tabs.add(DevToolsTab(
        index: tabs.length,
        icon: Icons.speed,
        label: 'Performance',
      ));
    }
    
    if (widget.enableTimeTravel) {
      tabs.add(DevToolsTab(
        index: tabs.length,
        icon: Icons.history,
        label: 'Time Travel',
      ));
    }

    return Container(
      color: Colors.grey.shade200,
      child: TabBar(
        isScrollable: true,
        tabs: tabs.map((tab) => Tab(
          icon: Icon(tab.icon),
          text: tab.label,
        )).toList(),
        onTap: (index) {
          setState(() {
            _selectedTab = tabs[index].index;
          });
        },
        indicatorColor: Colors.blue.shade700,
        labelColor: Colors.blue.shade700,
        unselectedLabelColor: Colors.grey.shade600,
      ),
    );
  }

  Widget _buildTabContent() {
    if (!widget.enableStateInspector && _selectedTab == 0) {
      return const Center(child: Text('No tabs enabled'));
    }

    int tabIndex = 0;
    
    if (widget.enableStateInspector) {
      if (_selectedTab == tabIndex) {
        return const StateInspectorView();
      }
      tabIndex++;
    }
    
    if (widget.enableDependencyGraph) {
      if (_selectedTab == tabIndex) {
        return const DependencyGraphView();
      }
      tabIndex++;
    }
    
    if (widget.enablePerformanceProfiler) {
      if (_selectedTab == tabIndex) {
        return const PerformanceProfilerView();
      }
      tabIndex++;
    }
    
    if (widget.enableTimeTravel) {
      if (_selectedTab == tabIndex) {
        return const TimeTravelView();
      }
    }

    return const Center(child: Text('Tab not found'));
  }

  void _showSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('DevTools Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('Track Dependencies'),
              value: SwiftDevTools.isTrackingDependencies,
              onChanged: (value) {
                // Note: This would require a setter in SwiftDevTools
                // For now, just show current state
              },
            ),
            SwitchListTile(
              title: const Text('Track State History'),
              value: SwiftDevTools.isTrackingStateHistory,
              onChanged: (value) {
                // Note: This would require a setter in SwiftDevTools
              },
            ),
            SwitchListTile(
              title: const Text('Track Performance'),
              value: SwiftDevTools.isTrackingPerformance,
              onChanged: (value) {
                // Note: This would require a setter in SwiftDevTools
              },
            ),
          ],
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
}

/// Helper class for tab configuration
class DevToolsTab {
  final int index;
  final IconData icon;
  final String label;

  DevToolsTab({
    required this.index,
    required this.icon,
    required this.label,
  });
}

