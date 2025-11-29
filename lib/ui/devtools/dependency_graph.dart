import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/devtools.dart' show SwiftDevTools;

/// Dependency Graph View - Visual representation of reactive dependencies
class DependencyGraphView extends StatefulWidget {
  const DependencyGraphView({super.key});

  @override
  State<DependencyGraphView> createState() => _DependencyGraphViewState();
}

class _DependencyGraphViewState extends State<DependencyGraphView> {
  Map<String, dynamic>? _graphData;
  String? _selectedNodeId;
  double _zoomLevel = 1.0;
  Offset _panOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _refreshGraph();
  }

  void _refreshGraph() {
    setState(() {
      _graphData = SwiftDevTools.getDependencyGraph();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildToolbar(),
        Expanded(
          child: _graphData == null
              ? const Center(child: CircularProgressIndicator())
              : _buildGraph(),
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
            icon: const Icon(Icons.zoom_in),
            tooltip: 'Zoom In',
            onPressed: () {
              setState(() {
                _zoomLevel = math.min(_zoomLevel + 0.1, 2.0);
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out),
            tooltip: 'Zoom Out',
            onPressed: () {
              setState(() {
                _zoomLevel = math.max(_zoomLevel - 0.1, 0.5);
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.fit_screen),
            tooltip: 'Reset View',
            onPressed: () {
              setState(() {
                _zoomLevel = 1.0;
                _panOffset = Offset.zero;
              });
            },
          ),
          const Spacer(),
          if (_graphData != null)
            Text(
              'Nodes: ${(_graphData!['nodes'] as List).length}, '
              'Edges: ${(_graphData!['edges'] as List).length}',
              style: TextStyle(color: Colors.grey.shade700),
            ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _refreshGraph,
          ),
        ],
      ),
    );
  }

  Widget _buildGraph() {
    final nodes = _graphData!['nodes'] as List<dynamic>? ?? [];
    final edges = _graphData!['edges'] as List<dynamic>? ?? [];

    if (nodes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_tree_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No dependencies tracked yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enable dependency tracking in your app',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _panOffset += details.delta;
        });
      },
      child: CustomPaint(
        painter: _DependencyGraphPainter(
          nodes: nodes,
          edges: edges,
          selectedNodeId: _selectedNodeId,
          zoomLevel: _zoomLevel,
          panOffset: _panOffset,
          onNodeTap: (nodeId) {
            setState(() {
              _selectedNodeId = _selectedNodeId == nodeId ? null : nodeId;
            });
          },
        ),
        child: Container(),
      ),
    );
  }
}

class _DependencyGraphPainter extends CustomPainter {
  final List<dynamic> nodes;
  final List<dynamic> edges;
  final String? selectedNodeId;
  final double zoomLevel;
  final Offset panOffset;
  final Function(String) onNodeTap;

  _DependencyGraphPainter({
    required this.nodes,
    required this.edges,
    this.selectedNodeId,
    required this.zoomLevel,
    required this.panOffset,
    required this.onNodeTap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.3;

    // Draw edges first (so they appear behind nodes)
    for (final edge in edges) {
      final fromId = edge['from'] as String? ?? '';
      final toId = edge['to'] as String? ?? '';
      
      final fromNode = nodes.firstWhere(
        (n) => n['id'] == fromId,
        orElse: () => null,
      );
      final toNode = nodes.firstWhere(
        (n) => n['id'] == toId,
        orElse: () => null,
      );

      if (fromNode != null && toNode != null) {
        final fromIndex = nodes.indexOf(fromNode);
        final toIndex = nodes.indexOf(toNode);
        
        final fromAngle = (fromIndex * 2 * math.pi) / nodes.length;
        final toAngle = (toIndex * 2 * math.pi) / nodes.length;
        
        final fromPos = Offset(
          center.dx + radius * math.cos(fromAngle),
          center.dy + radius * math.sin(fromAngle),
        ) * zoomLevel + panOffset;
        
        final toPos = Offset(
          center.dx + radius * math.cos(toAngle),
          center.dy + radius * math.sin(toAngle),
        ) * zoomLevel + panOffset;

        // Draw edge
        final paint = Paint()
          ..color = Colors.grey.shade400
          ..strokeWidth = 1.5;
        
        canvas.drawLine(fromPos, toPos, paint);
      }
    }

    // Draw nodes
    for (int i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      final nodeId = node['id'] as String? ?? '';
      final nodeType = node['type'] as String? ?? '';
      final nodeName = node['name'] as String? ?? '';
      final isSelected = selectedNodeId == nodeId;

      final angle = (i * 2 * math.pi) / nodes.length;
      final pos = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      ) * zoomLevel + panOffset;

      // Node color based on type
      Color nodeColor;
      switch (nodeType) {
        case 'SwiftValue':
        case 'Rx':
          nodeColor = Colors.blue;
          break;
        case 'Computed':
          nodeColor = Colors.green;
          break;
        case 'ReduxStore':
          nodeColor = Colors.purple;
          break;
        case 'Controller':
          nodeColor = Colors.orange;
          break;
        case 'Mark':
          nodeColor = Colors.teal;
          break;
        default:
          nodeColor = Colors.grey;
      }

      // Draw node
      final nodePaint = Paint()
        ..color = isSelected ? nodeColor.withOpacity(0.7) : nodeColor
        ..style = PaintingStyle.fill;
      
      final nodeRadius = isSelected ? 20.0 : 15.0;
      canvas.drawCircle(pos, nodeRadius * zoomLevel, nodePaint);

      // Draw border if selected
      if (isSelected) {
        final borderPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawCircle(pos, nodeRadius * zoomLevel, borderPaint);
      }

      // Draw node label
      final textPainter = TextPainter(
        text: TextSpan(
          text: nodeName.length > 10 ? '${nodeName.substring(0, 10)}...' : nodeName,
          style: TextStyle(
            color: Colors.white,
            fontSize: 10 * zoomLevel,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          pos.dx - textPainter.width / 2,
          pos.dy + nodeRadius * zoomLevel + 5,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(_DependencyGraphPainter oldDelegate) {
    return nodes != oldDelegate.nodes ||
        edges != oldDelegate.edges ||
        selectedNodeId != oldDelegate.selectedNodeId ||
        zoomLevel != oldDelegate.zoomLevel ||
        panOffset != oldDelegate.panOffset;
  }
}

