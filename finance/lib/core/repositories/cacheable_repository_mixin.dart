import 'dart:async';
import '../services/database_cache_service.dart';

/// Mixin that provides caching functionality for repository read operations
/// 
/// Usage:
/// ```dart
/// class MyRepositoryImpl with CacheableRepositoryMixin implements MyRepository {
///   @override
///   Future<List<Entity>> getAllEntities() async {
///     return cacheRead(
///       'getAllEntities',
///       () => _database.select(_database.entitiesTable).get(),
///       ttl: Duration(minutes: 10),
///     );
///   }
/// }
/// ```
mixin CacheableRepositoryMixin {
  final DatabaseCacheService _cache = DatabaseCacheService();

  /// Cache a read operation with automatic key generation
  /// 
  /// [method] - Method name for cache key generation
  /// [fetchOperation] - Function that performs the actual database read
  /// [params] - Optional parameters to include in cache key
  /// [ttl] - Time to live for cached data
  Future<T> cacheRead<T>(
    String method,
    Future<T> Function() fetchOperation, {
    Map<String, dynamic>? params,
    Duration? ttl,
  }) async {
    final cacheKey = _generateCacheKey(method, params);
    
    // Try to get from cache first
    final cached = await _cache.get<T>(cacheKey);
    if (cached != null) {
      return cached;
    }
    
    // Cache miss - fetch from database
    final result = await fetchOperation();
    
    // Cache the result
    await _cache.set(cacheKey, result, ttl: ttl);
    
    return result;
  }

  /// Cache a single entity read operation
  Future<T?> cacheReadSingle<T>(
    String method,
    Future<T?> Function() fetchOperation, {
    Map<String, dynamic>? params,
    Duration? ttl,
  }) async {
    final cacheKey = _generateCacheKey(method, params);
    
    // Try to get from cache first
    final cached = await _cache.get<T?>(cacheKey);
    if (cached != null) {
      return cached;
    }
    
    // Cache miss - fetch from database
    final result = await fetchOperation();
    
    // Cache the result (including null results to prevent repeated queries)
    await _cache.set(cacheKey, result, ttl: ttl);
    
    return result;
  }

  /// Invalidate cache entries for a specific entity type
  /// 
  /// [entityType] - The entity type to invalidate (e.g., 'transaction', 'budget')
  /// [id] - Optional specific entity ID to invalidate
  Future<void> invalidateCache(String entityType, {int? id}) async {
    if (id != null) {
      // Invalidate specific entity cache entries
      final patterns = [
        '${entityType}_getById_${id}',
        '${entityType}_getBySyncId_',
      ];
      
      for (final pattern in patterns) {
        await _cache.invalidate(pattern);
      }
    } else {
      // For now, clear all cache - could be optimized to pattern matching
      await _cache.clear();
    }
  }

  /// Invalidate all cache entries for an entity type
  Future<void> invalidateEntityCache(String entityType) async {
    // Since we don't have pattern-based invalidation, clear all cache
    // This could be optimized in the future with a more sophisticated cache key system
    await _cache.clear();
  }

  /// Generate a cache key based on method name and parameters
  String _generateCacheKey(String method, Map<String, dynamic>? params) {
    if (params == null || params.isEmpty) {
      return method;
    }
    
    // Sort parameters for consistent cache keys
    final sortedParams = Map.fromEntries(
      params.entries.toList()..sort((a, b) => a.key.compareTo(b.key))
    );
    
    final paramString = sortedParams.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    
    return '${method}_$paramString';
  }

  /// Clean expired cache entries
  Future<void> cleanExpiredCache() async {
    _cache.cleanExpired();
  }
} 