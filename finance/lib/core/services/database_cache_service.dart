import 'dart:async';

class CachedResult<T> {
  final T data;
  final DateTime expiry;

  CachedResult({required this.data, required this.expiry});

  bool get isValid => DateTime.now().isBefore(expiry);
}

class DatabaseCacheService {
  static final DatabaseCacheService _instance = DatabaseCacheService._internal();
  factory DatabaseCacheService() {
    return _instance;
  }
  DatabaseCacheService._internal();

  final Map<String, CachedResult> _cache = {};
  static const Duration _defaultTTL = Duration(minutes: 5);

  Future<T?> get<T>(String key) async {
    final cachedResult = _cache[key];
    if (cachedResult != null && cachedResult.isValid) {
      return cachedResult.data as T;
    } else {
      _cache.remove(key);
    }
    return null;
  }

  Future<void> set<T>(String key, T data, {Duration? ttl}) async {
    _cache[key] = CachedResult(
      data: data,
      expiry: DateTime.now().add(ttl ?? _defaultTTL),
    );
  }

  Future<void> invalidate(String key) async {
    _cache.remove(key);
  }

  Future<void> clear() async {
    _cache.clear();
  }

  void cleanExpired() {
    _cache.removeWhere((key, value) => !value.isValid);
  }
} 