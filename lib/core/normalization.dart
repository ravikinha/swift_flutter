import 'rx.dart';
import 'logger.dart';

/// Normalized state structure for managing collections
class NormalizedState<T> {
  final Map<String, T> _entities = {};
  final Set<String> _ids = {};

  /// Get all entities
  Map<String, T> get entities => Map.unmodifiable(_entities);

  /// Get all IDs
  Set<String> get ids => Set.unmodifiable(_ids);

  /// Get entity by ID
  T? getById(String id) => _entities[id];

  /// Get multiple entities by IDs
  List<T> getByIds(List<String> ids) {
    return ids.map((id) => _entities[id]).whereType<T>().toList();
  }

  /// Add or update entity
  void upsert(String id, T entity) {
    _entities[id] = entity;
    _ids.add(id);
  }

  /// Add or update multiple entities
  void upsertMany(Map<String, T> entities) {
    _entities.addAll(entities);
    _ids.addAll(entities.keys);
  }

  /// Remove entity
  void remove(String id) {
    _entities.remove(id);
    _ids.remove(id);
  }

  /// Remove multiple entities
  void removeMany(List<String> ids) {
    for (final id in ids) {
      _entities.remove(id);
      _ids.remove(id);
    }
  }

  /// Clear all entities
  void clear() {
    _entities.clear();
    _ids.clear();
  }

  /// Check if entity exists
  bool contains(String id) => _entities.containsKey(id);

  /// Get count
  int get count => _entities.length;

  /// Check if empty
  bool get isEmpty => _entities.isEmpty;

  /// Check if not empty
  bool get isNotEmpty => _entities.isNotEmpty;
}

/// Reactive normalized state
class RxNormalizedState<T> extends Rx<NormalizedState<T>> {
  RxNormalizedState() : super(NormalizedState<T>());

  /// Get entity by ID
  T? getById(String id) => value.getById(id);

  /// Get multiple entities by IDs
  List<T> getByIds(List<String> ids) => value.getByIds(ids);

  /// Add or update entity
  void upsert(String id, T entity) {
    value.upsert(id, entity);
    notifyListenersTransaction();
  }

  /// Add or update multiple entities
  void upsertMany(Map<String, T> entities) {
    value.upsertMany(entities);
    notifyListenersTransaction();
  }

  /// Remove entity
  void remove(String id) {
    value.remove(id);
    notifyListenersTransaction();
  }

  /// Remove multiple entities
  void removeMany(List<String> ids) {
    value.removeMany(ids);
    notifyListenersTransaction();
  }

  /// Clear all entities
  void clear() {
    value.clear();
    notifyListenersTransaction();
  }

  /// Check if entity exists
  bool contains(String id) => value.contains(id);

  /// Get count
  int get count => value.count;

  /// Get all entities
  Map<String, T> get entities => value.entities;

  /// Get all IDs
  Set<String> get ids => value.ids;
}

/// Helper to extract ID from entity
typedef IdExtractor<T> = String Function(T entity);

/// Normalize a list of entities into a map
Map<String, T> normalize<T>(List<T> entities, IdExtractor<T> extractId) {
  final normalized = <String, T>{};
  for (final entity in entities) {
    normalized[extractId(entity)] = entity;
  }
  return normalized;
}

/// Denormalize a map of entities into a list
List<T> denormalize<T>(Map<String, T> normalized) {
  return normalized.values.toList();
}

