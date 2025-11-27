import 'package:flutter/foundation.dart';
import 'rx.dart';
import 'rx_future.dart';
import 'transaction.dart';
import 'logger.dart';

/// Pagination state
class PaginationState<T> {
  final List<T> items;
  final int currentPage;
  final int pageSize;
  final int? totalItems;
  final bool hasMore;
  final bool isLoading;
  final Object? error;

  const PaginationState({
    this.items = const [],
    this.currentPage = 0,
    this.pageSize = 20,
    this.totalItems,
    this.hasMore = true,
    this.isLoading = false,
    this.error,
  });

  PaginationState<T> copyWith({
    List<T>? items,
    int? currentPage,
    int? pageSize,
    int? totalItems,
    bool? hasMore,
    bool? isLoading,
    Object? error,
  }) {
    return PaginationState<T>(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      totalItems: totalItems ?? this.totalItems,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  bool get isEmpty => items.isEmpty && !isLoading;
  bool get isNotEmpty => items.isNotEmpty;
  int get totalPages => totalItems != null
      ? (totalItems! / pageSize).ceil()
      : (hasMore ? currentPage + 1 : currentPage);
}

/// Reactive pagination controller
class PaginationController<T> extends ChangeNotifier {
  final Rx<PaginationState<T>> _state;
  final Future<List<T>> Function(int page, int pageSize) _loadPage;
  final int _pageSize;

  PaginationController({
    required Future<List<T>> Function(int page, int pageSize) loadPage,
    int pageSize = 20,
    int? totalItems,
  })  : _state = Rx(PaginationState<T>(
          pageSize: pageSize,
          totalItems: totalItems,
        )),
        _loadPage = loadPage,
        _pageSize = pageSize;

  /// Current pagination state
  PaginationState<T> get state => _state.value;

  /// Current items
  List<T> get items => _state.value.items;

  /// Current page
  int get currentPage => _state.value.currentPage;

  /// Page size
  int get pageSize => _state.value.pageSize;

  /// Total items
  int? get totalItems => _state.value.totalItems;

  /// Has more pages
  bool get hasMore => _state.value.hasMore;

  /// Is loading
  bool get isLoading => _state.value.isLoading;

  /// Error
  Object? get error => _state.value.error;

  /// Load initial page
  Future<void> loadInitial() async {
    await loadPage(0);
  }

  /// Load a specific page
  Future<void> loadPage(int page) async {
    if (_state.value.isLoading) return;

    Transaction.run(() {
      _state.value = _state.value.copyWith(isLoading: true, error: null);
    });

    try {
      final items = await _loadPage(page, _pageSize);
      final hasMore = items.length >= _pageSize;

      Transaction.run(() {
        if (page == 0) {
          // First page - replace items
          _state.value = _state.value.copyWith(
            items: items,
            currentPage: page,
            hasMore: hasMore,
            isLoading: false,
            error: null,
          );
        } else {
          // Subsequent pages - append items
          _state.value = _state.value.copyWith(
            items: [..._state.value.items, ...items],
            currentPage: page,
            hasMore: hasMore,
            isLoading: false,
            error: null,
          );
        }
      });

      Logger.debug('Loaded page $page with ${items.length} items');
    } catch (e, stackTrace) {
      Transaction.run(() {
        _state.value = _state.value.copyWith(
          isLoading: false,
          error: e,
        );
      });
      Logger.error('Error loading page $page', e);
      rethrow;
    }
  }

  /// Load next page
  Future<void> loadNext() async {
    if (!_state.value.hasMore || _state.value.isLoading) return;
    await loadPage(_state.value.currentPage + 1);
  }

  /// Refresh (reload from beginning)
  Future<void> refresh() async {
    await loadPage(0);
  }

  /// Reset pagination
  void reset() {
    Transaction.run(() {
      _state.value = PaginationState<T>(
        pageSize: _pageSize,
        totalItems: _state.value.totalItems,
      );
    });
  }

  /// Update total items count
  void setTotalItems(int total) {
    Transaction.run(() {
      _state.value = _state.value.copyWith(
        totalItems: total,
        hasMore: _state.value.currentPage * _pageSize < total,
      );
    });
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }
}

/// Pagination helper for SwiftFuture
class SwiftFuturePagination<T> {
  final SwiftFuture<List<T>> _future;
  final int _pageSize;
  int _currentPage = 0;
  final List<T> _allItems = [];
  int? _totalItems;

  SwiftFuturePagination({
    required Future<List<T>> Function(int page, int pageSize) loadPage,
    int pageSize = 20,
    int? totalItems,
    RetryConfig? retryConfig,
  })  : _future = SwiftFuture<List<T>>(retryConfig: retryConfig),
        _pageSize = pageSize,
        _totalItems = totalItems {
    _loadPage = loadPage;
  }

  late final Future<List<T>> Function(int page, int pageSize) _loadPage;

  /// Current future state
  SwiftFuture<List<T>> get future => _future;

  /// All loaded items
  List<T> get items => List.unmodifiable(_allItems);

  /// Current page
  int get currentPage => _currentPage;

  /// Has more pages
  bool get hasMore {
    if (_totalItems != null) {
      return _allItems.length < _totalItems!;
    }
    return _future.value.isSuccess && _allItems.length % _pageSize == 0;
  }

  /// Load initial page
  Future<void> loadInitial() async {
    await loadPage(0);
  }

  /// Load a specific page
  Future<void> loadPage(int page) async {
    _currentPage = page;
    await _future.execute(() => _loadPage(page, _pageSize));

    if (_future.value.isSuccess && _future.data != null) {
      if (page == 0) {
        _allItems.clear();
      }
      _allItems.addAll(_future.data!);
    }
  }

  /// Load next page
  Future<void> loadNext() async {
    if (hasMore && !_future.isLoading) {
      await loadPage(_currentPage + 1);
    }
  }

  /// Refresh
  Future<void> refresh() async {
    await loadPage(0);
  }

  /// Reset
  void reset() {
    _currentPage = 0;
    _allItems.clear();
    _future.reset();
  }
}

