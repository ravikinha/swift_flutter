import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'rx.dart';
import 'persistence.dart' show StorageBackend;

/// A/B test variant
class ABVariant<T> {
  final String name;
  final T value;
  final double weight;

  const ABVariant({
    required this.name,
    required this.value,
    this.weight = 1.0,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'value': value,
        'weight': weight,
      };
}

/// A/B test experiment
class ABExperiment<T> {
  final String id;
  final String name;
  final List<ABVariant<T>> variants;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool enabled;

  const ABExperiment({
    required this.id,
    required this.name,
    required this.variants,
    this.startDate,
    this.endDate,
    this.enabled = true,
  });

  bool get isActive {
    if (!enabled) return false;

    final now = DateTime.now();
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;

    return true;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'variants': variants.map((v) => v.toJson()).toList(),
        if (startDate != null) 'startDate': startDate!.toIso8601String(),
        if (endDate != null) 'endDate': endDate!.toIso8601String(),
        'enabled': enabled,
      };
}

/// A/B testing service
class ABTestingService {
  static final Map<String, String> _userVariants = {};
  static final Map<String, ABExperiment<dynamic>> _experiments = {};
  static StorageBackend? _storage;
  static const String _storageKey = 'ab_test_variants';
  static final Random _random = Random();

  /// Initialize with storage
  static Future<void> initialize({StorageBackend? storage}) async {
    _storage = storage;
    await _loadUserVariants();
  }

  /// Register experiment
  static void registerExperiment<T>(ABExperiment<T> experiment) {
    _experiments[experiment.id] = experiment;
  }

  /// Get variant for user
  static ABVariant<T> getVariant<T>(String experimentId) {
    final experiment = _experiments[experimentId] as ABExperiment<T>?;
    if (experiment == null) {
      throw StateError('Experiment $experimentId not found');
    }

    if (!experiment.isActive) {
      // Return control variant if experiment is not active
      return experiment.variants.first;
    }

    // Check if user already has a variant assigned
    if (_userVariants.containsKey(experimentId)) {
      final variantName = _userVariants[experimentId]!;
      return experiment.variants.firstWhere(
        (v) => v.name == variantName,
        orElse: () => experiment.variants.first,
      );
    }

    // Assign new variant based on weights
    final variant = _selectVariantByWeight(experiment.variants);
    _userVariants[experimentId] = variant.name;
    _saveUserVariants();

    return variant;
  }

  /// Force set variant for user (for testing)
  static void forceVariant(String experimentId, String variantName) {
    _userVariants[experimentId] = variantName;
    _saveUserVariants();
  }

  /// Clear user variants
  static Future<void> clearUserVariants() async {
    _userVariants.clear();
    if (_storage != null) {
      await _storage!.delete(_storageKey);
    }
  }

  /// Get all user variants
  static Map<String, String> getUserVariants() {
    return Map.unmodifiable(_userVariants);
  }

  /// Check if user is in variant
  static bool isInVariant(String experimentId, String variantName) {
    return _userVariants[experimentId] == variantName;
  }

  /// Select variant by weight
  static ABVariant<T> _selectVariantByWeight<T>(List<ABVariant<T>> variants) {
    final totalWeight = variants.fold<double>(0, (sum, v) => sum + v.weight);
    final randomValue = _random.nextDouble() * totalWeight;

    var cumulativeWeight = 0.0;
    for (final variant in variants) {
      cumulativeWeight += variant.weight;
      if (randomValue <= cumulativeWeight) {
        return variant;
      }
    }

    return variants.last;
  }

  /// Save user variants to storage
  static Future<void> _saveUserVariants() async {
    if (_storage == null) return;

    try {
      await _storage!.save(_storageKey, jsonEncode(_userVariants));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error saving user variants: $e');
      }
    }
  }

  /// Load user variants from storage
  static Future<void> _loadUserVariants() async {
    if (_storage == null) return;

    try {
      final data = await _storage!.load(_storageKey);
      if (data == null) return;
      final decoded = jsonDecode(data) as Map;
      _userVariants.clear();
      _userVariants.addAll(Map<String, String>.from(decoded));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading user variants: $e');
      }
    }
  }

  /// Get experiment
  static ABExperiment<T>? getExperiment<T>(String experimentId) {
    return _experiments[experimentId] as ABExperiment<T>?;
  }

  /// Get all experiments
  static List<ABExperiment<dynamic>> getAllExperiments() {
    return _experiments.values.toList();
  }

  /// Remove experiment
  static void removeExperiment(String experimentId) {
    _experiments.remove(experimentId);
  }
}

/// Reactive A/B test state
class ABTestRx<T> extends Rx<T> {
  final String experimentId;
  final Map<String, T> variants;
  bool _initialized = false;

  ABTestRx(
    this.experimentId,
    this.variants, {
    T? defaultValue,
  }) : super(defaultValue ?? variants.values.first);

  /// Initialize and get variant
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final variant = ABTestingService.getVariant<T>(experimentId);
      value = variant.value;
      _initialized = true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error initializing AB test: $e');
      }
      // Use default value
    }
  }

  /// Check if initialized
  bool get isInitialized => _initialized;

  /// Get current variant name
  String? get currentVariantName {
    final userVariants = ABTestingService.getUserVariants();
    return userVariants[experimentId];
  }
}

/// A/B test helper
class ABTestHelper {
  /// Create simple A/B test (50/50 split)
  static ABExperiment<T> createSimpleTest<T>({
    required String id,
    required String name,
    required T controlValue,
    required T treatmentValue,
  }) {
    return ABExperiment<T>(
      id: id,
      name: name,
      variants: [
        ABVariant(name: 'control', value: controlValue, weight: 0.5),
        ABVariant(name: 'treatment', value: treatmentValue, weight: 0.5),
      ],
    );
  }

  /// Create multivariate test
  static ABExperiment<T> createMultivariateTest<T>({
    required String id,
    required String name,
    required Map<String, T> variants,
    Map<String, double>? weights,
  }) {
    final variantList = variants.entries.map((entry) {
      return ABVariant<T>(
        name: entry.key,
        value: entry.value,
        weight: weights?[entry.key] ?? 1.0,
      );
    }).toList();

    return ABExperiment<T>(
      id: id,
      name: name,
      variants: variantList,
    );
  }

  /// Create time-limited test
  static ABExperiment<T> createTimeLimitedTest<T>({
    required String id,
    required String name,
    required List<ABVariant<T>> variants,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return ABExperiment<T>(
      id: id,
      name: name,
      variants: variants,
      startDate: startDate,
      endDate: endDate,
    );
  }
}

/// A/B test analytics
class ABTestAnalytics {
  static final Map<String, Map<String, int>> _conversions = {};
  static final Map<String, Map<String, int>> _impressions = {};

  /// Track impression
  static void trackImpression(String experimentId, String variantName) {
    _impressions.putIfAbsent(experimentId, () => {});
    _impressions[experimentId]![variantName] =
        (_impressions[experimentId]![variantName] ?? 0) + 1;
  }

  /// Track conversion
  static void trackConversion(String experimentId, String variantName) {
    _conversions.putIfAbsent(experimentId, () => {});
    _conversions[experimentId]![variantName] =
        (_conversions[experimentId]![variantName] ?? 0) + 1;
  }

  /// Get conversion rate
  static double getConversionRate(String experimentId, String variantName) {
    final impressions = _impressions[experimentId]?[variantName] ?? 0;
    final conversions = _conversions[experimentId]?[variantName] ?? 0;

    if (impressions == 0) return 0.0;
    return conversions / impressions;
  }

  /// Get experiment results
  static Map<String, dynamic> getExperimentResults(String experimentId) {
    final results = <String, dynamic>{};

    final experimentImpressions = _impressions[experimentId] ?? {};
    final experimentConversions = _conversions[experimentId] ?? {};

    // Include all variants that have either impressions or conversions
    final allVariantNames = <String>{};
    allVariantNames.addAll(experimentImpressions.keys);
    allVariantNames.addAll(experimentConversions.keys);

    for (final variantName in allVariantNames) {
      results[variantName] = {
        'impressions': experimentImpressions[variantName] ?? 0,
        'conversions': experimentConversions[variantName] ?? 0,
        'conversionRate': getConversionRate(experimentId, variantName),
      };
    }

    return results;
  }

  /// Clear analytics data
  static void clear() {
    _conversions.clear();
    _impressions.clear();
  }
}

