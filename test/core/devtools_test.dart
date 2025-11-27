import 'package:flutter_test/flutter_test.dart';
import 'package:swift_flutter/swift_flutter.dart' hide Action;
import 'package:swift_flutter/core/devtools.dart';
import 'package:swift_flutter/core/reducers.dart' show Action;

void main() {
  group('SwiftDevTools', () {
    tearDown(() {
      // Clean up after each test
      SwiftDevTools.disable();
      SwiftDevTools.clear();
    });

    test('should be disabled by default', () {
      expect(SwiftDevTools.isEnabled, false);
    });

    test('should enable DevTools with default settings', () {
      SwiftDevTools.enable();
      expect(SwiftDevTools.isEnabled, true);
      expect(SwiftDevTools.isTrackingDependencies, true);
      expect(SwiftDevTools.isTrackingPerformance, true);
    });

    test('should enable DevTools with custom settings', () {
      SwiftDevTools.enable(
        trackDependencies: true,
        trackStateHistory: true,
        trackPerformance: false,
      );
      expect(SwiftDevTools.isEnabled, true);
      expect(SwiftDevTools.isTrackingDependencies, true);
      expect(SwiftDevTools.isTrackingPerformance, false);
    });

    test('should disable DevTools', () {
      SwiftDevTools.enable();
      expect(SwiftDevTools.isEnabled, true);
      
      SwiftDevTools.disable();
      expect(SwiftDevTools.isEnabled, false);
    });

    test('should track Rx creation', () {
      SwiftDevTools.enable();
      
      swift(0, name: 'counter');
      
      final summary = SwiftDevTools.getSummary();
      expect(summary['rxCount'], 1);
      
      final stateInspector = SwiftDevTools.getStateInspector();
      expect(stateInspector['totalCount'], greaterThanOrEqualTo(1));
    });

    test('should track Computed creation', () {
      SwiftDevTools.enable();
      
      final price = swift(100.0, name: 'price');
      final quantity = swift(2, name: 'quantity');
      final total = Computed(() => price.value * quantity.value, name: 'total');
      
      // Access computed to trigger creation tracking
      final _ = total.value;
      
      final summary = SwiftDevTools.getSummary();
      expect(summary['computedCount'], 1);
    });

    test('should track dependency relationships', () {
      SwiftDevTools.enable();
      
      final counter = swift(0, name: 'counter');
      final doubled = Computed(() => counter.value * 2, name: 'doubled');
      
      // Access computed to create dependency
      final _ = doubled.value;
      
      final graph = SwiftDevTools.getDependencyGraph();
      expect(graph['edges'], isNotEmpty);
    });

    test('should track state changes when history tracking is enabled', () {
      SwiftDevTools.enable(trackStateHistory: true);
      
      final counter = swift(0, name: 'counter');
      counter.value = 1;
      counter.value = 2;
      
      final history = SwiftDevTools.getStateHistory();
      expect(history.length, greaterThanOrEqualTo(2));
    });

    test('should not track state changes when history tracking is disabled', () {
      SwiftDevTools.enable(trackStateHistory: false);
      
      final counter = swift(0, name: 'counter');
      counter.value = 1;
      
      final history = SwiftDevTools.getStateHistory();
      expect(history, isEmpty);
    });

    test('should track performance events', () {
      SwiftDevTools.enable(trackPerformance: true);
      
      SwiftDevTools.trackPerformanceEvent(
        'test_event',
        const Duration(milliseconds: 10),
        {'test': 'data'},
      );
      
      final report = SwiftDevTools.getPerformanceReport();
      expect(report['totalEvents'], 1);
    });

    test('should get state inspector data', () {
      SwiftDevTools.enable();
      
      swift(42, name: 'counter');
      swift('Test', name: 'name');
      
      final inspector = SwiftDevTools.getStateInspector();
      expect(inspector['totalCount'], greaterThanOrEqualTo(2));
      expect(inspector['states'], isA<Map<String, dynamic>>());
    });

    test('should get dependency graph', () {
      SwiftDevTools.enable();
      
      final a = swift(1, name: 'a');
      final b = swift(2, name: 'b');
      final sum = Computed(() => a.value + b.value, name: 'sum');
      
      // Access computed to create dependencies
      final _ = sum.value;
      
      final graph = SwiftDevTools.getDependencyGraph();
      expect(graph['nodes'], isNotEmpty);
      expect(graph['rxCount'], greaterThanOrEqualTo(2));
      expect(graph['computedCount'], 1);
    });

    test('should get performance report', () {
      SwiftDevTools.enable(trackPerformance: true);
      
      SwiftDevTools.trackPerformanceEvent(
        'test',
        const Duration(milliseconds: 5),
        null,
      );
      
      final report = SwiftDevTools.getPerformanceReport();
      expect(report['totalEvents'], 1);
      expect(report['recentEvents'], isA<List>());
    });

    test('should return error when DevTools is disabled', () {
      SwiftDevTools.disable();
      
      final graph = SwiftDevTools.getDependencyGraph();
      expect(graph['error'], 'DevTools not enabled');
      
      final inspector = SwiftDevTools.getStateInspector();
      expect(inspector['error'], 'DevTools not enabled');
      
      final report = SwiftDevTools.getPerformanceReport();
      expect(report['error'], 'Performance tracking not enabled');
    });

    test('should limit state history size', () {
      SwiftDevTools.enable(trackStateHistory: true);
      SwiftDevTools.setMaxHistorySize(5);
      
      final counter = swift(0, name: 'counter');
      for (int i = 1; i <= 10; i++) {
        counter.value = i;
      }
      
      final history = SwiftDevTools.getStateHistory();
      expect(history.length, lessThanOrEqualTo(5));
    });

    test('should limit performance events', () {
      SwiftDevTools.enable(trackPerformance: true);
      SwiftDevTools.setMaxPerformanceEvents(3);
      
      for (int i = 0; i < 10; i++) {
        SwiftDevTools.trackPerformanceEvent(
          'event_$i',
          const Duration(milliseconds: 1),
          null,
        );
      }
      
      final report = SwiftDevTools.getPerformanceReport();
      expect(report['totalEvents'], lessThanOrEqualTo(3));
    });

    test('should track ReduxStore', () {
      SwiftDevTools.enable();
      
      final store = ReduxStore<int>(
        0,
        (state, action) {
          if (action.type == 'INCREMENT') return state + 1;
          return state;
        },
        name: 'testStore',
      );
      
      store.dispatch(_TestAction('INCREMENT'));
      
      final stores = SwiftDevTools.getAllReduxStores();
      expect(stores.length, 1);
      expect(stores[0]['name'], 'testStore');
      expect(stores[0]['actionCount'], 1);
    });

    test('should get time-travel data for ReduxStore', () {
      SwiftDevTools.enable();
      
      final store = ReduxStore<int>(
        0,
        (state, action) {
          if (action.type == 'INCREMENT') return state + 1;
          return state;
        },
        name: 'testStore',
      );
      
      store.dispatch(_TestAction('INCREMENT'));
      store.dispatch(_TestAction('INCREMENT'));
      
      final storeId = 'redux_${store.hashCode}';
      final timeTravel = SwiftDevTools.getTimeTravelData(storeId);
      
      expect(timeTravel, isNotNull);
      expect(timeTravel!['currentState'], 2);
      expect(timeTravel['actionCount'], 2);
      expect(timeTravel['canTimeTravel'], true);
    });

    test('should clear all tracking data', () {
      SwiftDevTools.enable();
      
      final counter = swift(0, name: 'counter');
      counter.value = 1;
      
      SwiftDevTools.clear();
      
      final summary = SwiftDevTools.getSummary();
      expect(summary['rxCount'], 0);
      expect(summary['stateHistorySize'], 0);
    });

    test('should serialize complex values in state inspector', () {
      SwiftDevTools.enable();
      
      swift([1, 2, 3], name: 'list');
      swift({'key': 'value'}, name: 'map');
      
      final inspector = SwiftDevTools.getStateInspector();
      expect(inspector['states'], isA<Map<String, dynamic>>());
    });

    test('should track multiple Rx values', () {
      SwiftDevTools.enable();
      
      swift(1, name: 'a');
      swift(2, name: 'b');
      swift(3, name: 'c');
      
      final summary = SwiftDevTools.getSummary();
      expect(summary['rxCount'], 3);
    });

    test('should track nested computed dependencies', () {
      SwiftDevTools.enable();
      
      final price = swift(100.0, name: 'price');
      final quantity = swift(2, name: 'quantity');
      final subtotal = Computed(() => price.value * quantity.value, name: 'subtotal');
      final tax = Computed(() => subtotal.value * 0.1, name: 'tax');
      final total = Computed(() => subtotal.value + tax.value, name: 'total');
      
      // Access to trigger tracking
      final _ = total.value;
      
      final graph = SwiftDevTools.getDependencyGraph();
      expect(graph['computedCount'], 3);
    });

    test('should get summary with all counts', () {
      SwiftDevTools.enable();
      
      final counter = swift(0, name: 'counter');
      final doubled = Computed(() => counter.value * 2, name: 'doubled');
      final _ = doubled.value;
      
      final summary = SwiftDevTools.getSummary();
      expect(summary['enabled'], true);
      expect(summary['rxCount'], greaterThanOrEqualTo(1));
      expect(summary['computedCount'], 1);
      expect(summary['dependencyEdges'], isA<int>());
    });

    test('should handle state inspector when objects are disposed', () {
      SwiftDevTools.enable();
      
      final counter = swift(0, name: 'counter');
      
      // Dispose the counter
      counter.dispose();
      
      // State inspector should still work
      final inspector = SwiftDevTools.getStateInspector();
      expect(inspector['states'], isA<Map<String, dynamic>>());
    });
  });
}

class _TestAction implements Action {
  @override
  final String type;
  
  _TestAction(this.type);
  
  @override
  Map<String, dynamic>? get payload => null;
}

