import 'package:flutter_test/flutter_test.dart';
import 'package:swift_flutter/core/ab_testing.dart';
import 'package:swift_flutter/core/persistence.dart';

void main() {
  group('ABTestingService', () {
    setUp(() async {
      await ABTestingService.initialize(storage: MemoryStorage());
      await ABTestingService.clearUserVariants();
      // Clear all experiments from previous tests
      final experiments = ABTestingService.getAllExperiments();
      for (final exp in experiments) {
        ABTestingService.removeExperiment(exp.id);
      }
    });

    test('should register experiment', () {
      final experiment = ABExperiment<String>(
        id: 'test_exp',
        name: 'Test Experiment',
        variants: [
          const ABVariant(name: 'control', value: 'A'),
          const ABVariant(name: 'treatment', value: 'B'),
        ],
      );

      ABTestingService.registerExperiment(experiment);
      expect(ABTestingService.getExperiment('test_exp'), isNotNull);
    });

    test('should get variant for user', () {
      final experiment = ABExperiment<String>(
        id: 'test_exp',
        name: 'Test',
        variants: [
          const ABVariant(name: 'control', value: 'A'),
          const ABVariant(name: 'treatment', value: 'B'),
        ],
      );

      ABTestingService.registerExperiment(experiment);
      final variant = ABTestingService.getVariant<String>('test_exp');

      expect(variant.value, anyOf('A', 'B'));
    });

    test('should return same variant for same user', () {
      final experiment = ABExperiment<String>(
        id: 'test_exp',
        name: 'Test',
        variants: [
          const ABVariant(name: 'control', value: 'A'),
          const ABVariant(name: 'treatment', value: 'B'),
        ],
      );

      ABTestingService.registerExperiment(experiment);

      final variant1 = ABTestingService.getVariant<String>('test_exp');
      final variant2 = ABTestingService.getVariant<String>('test_exp');

      expect(variant1.name, variant2.name);
    });

    test('should force variant', () {
      final experiment = ABExperiment<String>(
        id: 'test_exp',
        name: 'Test',
        variants: [
          const ABVariant(name: 'control', value: 'A'),
          const ABVariant(name: 'treatment', value: 'B'),
        ],
      );

      ABTestingService.registerExperiment(experiment);
      ABTestingService.forceVariant('test_exp', 'treatment');

      final variant = ABTestingService.getVariant<String>('test_exp');
      expect(variant.name, 'treatment');
    });

    test('should check if user is in variant', () {
      final experiment = ABExperiment<String>(
        id: 'test_exp',
        name: 'Test',
        variants: [
          const ABVariant(name: 'control', value: 'A'),
          const ABVariant(name: 'treatment', value: 'B'),
        ],
      );

      ABTestingService.registerExperiment(experiment);
      ABTestingService.forceVariant('test_exp', 'control');

      expect(ABTestingService.isInVariant('test_exp', 'control'), isTrue);
      expect(ABTestingService.isInVariant('test_exp', 'treatment'), isFalse);
    });

    test('should return control variant if experiment is inactive', () {
      final experiment = ABExperiment<String>(
        id: 'test_exp',
        name: 'Test',
        variants: [
          const ABVariant(name: 'control', value: 'A'),
          const ABVariant(name: 'treatment', value: 'B'),
        ],
        enabled: false,
      );

      ABTestingService.registerExperiment(experiment);
      final variant = ABTestingService.getVariant<String>('test_exp');

      expect(variant.name, 'control');
    });

    test('should get all experiments', () {
      final exp1 = ABExperiment<String>(
        id: 'exp1',
        name: 'Experiment 1',
        variants: [const ABVariant(name: 'control', value: 'A')],
      );

      final exp2 = ABExperiment<int>(
        id: 'exp2',
        name: 'Experiment 2',
        variants: [const ABVariant(name: 'control', value: 1)],
      );

      ABTestingService.registerExperiment(exp1);
      ABTestingService.registerExperiment(exp2);

      final experiments = ABTestingService.getAllExperiments();
      expect(experiments.length, 2);
    });

    test('should remove experiment', () {
      final experiment = ABExperiment<String>(
        id: 'test_exp',
        name: 'Test',
        variants: [const ABVariant(name: 'control', value: 'A')],
      );

      ABTestingService.registerExperiment(experiment);
      ABTestingService.removeExperiment('test_exp');

      expect(ABTestingService.getExperiment('test_exp'), isNull);
    });
  });

  group('ABExperiment', () {
    test('should check if experiment is active', () {
      final activeExp = ABExperiment<String>(
        id: 'test',
        name: 'Test',
        variants: [const ABVariant(name: 'control', value: 'A')],
        enabled: true,
      );

      expect(activeExp.isActive, isTrue);

      final inactiveExp = ABExperiment<String>(
        id: 'test',
        name: 'Test',
        variants: [const ABVariant(name: 'control', value: 'A')],
        enabled: false,
      );

      expect(inactiveExp.isActive, isFalse);
    });

    test('should check date range', () {
      final futureExp = ABExperiment<String>(
        id: 'test',
        name: 'Test',
        variants: [const ABVariant(name: 'control', value: 'A')],
        startDate: DateTime.now().add(const Duration(days: 1)),
      );

      expect(futureExp.isActive, isFalse);

      final pastExp = ABExperiment<String>(
        id: 'test',
        name: 'Test',
        variants: [const ABVariant(name: 'control', value: 'A')],
        endDate: DateTime.now().subtract(const Duration(days: 1)),
      );

      expect(pastExp.isActive, isFalse);
    });

    test('should serialize to JSON', () {
      final experiment = ABExperiment<String>(
        id: 'test',
        name: 'Test',
        variants: [const ABVariant(name: 'control', value: 'A')],
      );

      final json = experiment.toJson();
      expect(json['id'], 'test');
      expect(json['name'], 'Test');
      expect(json['variants'], isNotEmpty);
    });
  });

  group('ABTestRx', () {
    setUp(() async {
      await ABTestingService.initialize(storage: MemoryStorage());
      await ABTestingService.clearUserVariants();
    });

    test('should initialize with variant', () async {
      final experiment = ABExperiment<String>(
        id: 'test_exp',
        name: 'Test',
        variants: [
          const ABVariant(name: 'control', value: 'A'),
          const ABVariant(name: 'treatment', value: 'B'),
        ],
      );

      ABTestingService.registerExperiment(experiment);

      final abTest = ABTestRx<String>(
        'test_exp',
        {'control': 'A', 'treatment': 'B'},
      );

      await abTest.initialize();
      expect(abTest.isInitialized, isTrue);
      expect(abTest.value, anyOf('A', 'B'));
    });

    test('should get current variant name', () async {
      final experiment = ABExperiment<String>(
        id: 'test_exp',
        name: 'Test',
        variants: [
          const ABVariant(name: 'control', value: 'A'),
          const ABVariant(name: 'treatment', value: 'B'),
        ],
      );

      ABTestingService.registerExperiment(experiment);
      ABTestingService.forceVariant('test_exp', 'treatment');

      final abTest = ABTestRx<String>(
        'test_exp',
        {'control': 'A', 'treatment': 'B'},
      );

      await abTest.initialize();
      expect(abTest.currentVariantName, 'treatment');
    });
  });

  group('ABTestHelper', () {
    test('should create simple A/B test', () {
      final experiment = ABTestHelper.createSimpleTest<String>(
        id: 'test',
        name: 'Test',
        controlValue: 'A',
        treatmentValue: 'B',
      );

      expect(experiment.variants.length, 2);
      expect(experiment.variants[0].name, 'control');
      expect(experiment.variants[1].name, 'treatment');
    });

    test('should create multivariate test', () {
      final experiment = ABTestHelper.createMultivariateTest<String>(
        id: 'test',
        name: 'Test',
        variants: {
          'A': 'Value A',
          'B': 'Value B',
          'C': 'Value C',
        },
      );

      expect(experiment.variants.length, 3);
    });

    test('should create time-limited test', () {
      final now = DateTime.now();
      final experiment = ABTestHelper.createTimeLimitedTest<String>(
        id: 'test',
        name: 'Test',
        variants: [const ABVariant(name: 'control', value: 'A')],
        startDate: now,
        endDate: now.add(const Duration(days: 7)),
      );

      expect(experiment.startDate, isNotNull);
      expect(experiment.endDate, isNotNull);
    });
  });

  group('ABTestAnalytics', () {
    setUp(() {
      ABTestAnalytics.clear();
    });

    test('should track impression', () {
      ABTestAnalytics.trackImpression('test_exp', 'control');
      ABTestAnalytics.trackImpression('test_exp', 'control');

      final results = ABTestAnalytics.getExperimentResults('test_exp');
      expect(results['control']['impressions'], 2);
    });

    test('should track conversion', () {
      ABTestAnalytics.trackConversion('test_exp', 'control');

      final results = ABTestAnalytics.getExperimentResults('test_exp');
      expect(results['control']['conversions'], 1);
    });

    test('should calculate conversion rate', () {
      ABTestAnalytics.trackImpression('test_exp', 'control');
      ABTestAnalytics.trackImpression('test_exp', 'control');
      ABTestAnalytics.trackConversion('test_exp', 'control');

      final rate = ABTestAnalytics.getConversionRate('test_exp', 'control');
      expect(rate, 0.5);
    });

    test('should get experiment results', () {
      ABTestAnalytics.trackImpression('test_exp', 'control');
      ABTestAnalytics.trackImpression('test_exp', 'treatment');
      ABTestAnalytics.trackConversion('test_exp', 'control');

      final results = ABTestAnalytics.getExperimentResults('test_exp');
      expect(results['control'], isNotNull);
      expect(results['treatment'], isNotNull);
    });
  });
}

