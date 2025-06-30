import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Smart caching system for bottom sheet snap size calculations
/// 
/// Phase 2 optimization: Eliminates redundant snap size calculations by caching
/// results based on screen dimensions, keyboard state, and configuration.
/// Target: 80% cache hit rate for improved performance.
class SnapSizeCache {
  SnapSizeCache._();
  
  /// Internal cache storage with LRU behavior
  static final Map<String, _CacheEntry> _cache = {};
  static const int _maxCacheSize = 50; // Reasonable limit for memory usage
  static int _accessCounter = 0;
  
  /// Statistics for performance monitoring
  static int _hitCount = 0;
  static int _missCount = 0;
  
  /// Get cached snap sizes or calculate and cache new ones
  static List<double> getSnapSizes({
    required Size screenSize,
    required bool isKeyboardVisible,
    required bool fullSnap,
    required bool popupWithKeyboard,
    required bool isFullScreen,
  }) {
    final key = _generateCacheKey(
      screenSize: screenSize,
      isKeyboardVisible: isKeyboardVisible,
      fullSnap: fullSnap,
      popupWithKeyboard: popupWithKeyboard,
      isFullScreen: isFullScreen,
    );
    
    // Check cache first
    final cached = _cache[key];
    if (cached != null) {
      // Update access time for LRU
      cached.lastAccessed = ++_accessCounter;
      _hitCount++;
      
      if (kDebugMode) {
        debugPrint('📊 SnapSizeCache: Cache HIT for $key');
      }
      
      return cached.snapSizes;
    }
    
    // Cache miss - calculate new values
    _missCount++;
    final snapSizes = _calculateSnapSizes(
      screenSize: screenSize,
      isKeyboardVisible: isKeyboardVisible,
      fullSnap: fullSnap,
      popupWithKeyboard: popupWithKeyboard,
      isFullScreen: isFullScreen,
    );
    
    // Store in cache with LRU management
    _cache[key] = _CacheEntry(
      snapSizes: snapSizes,
      lastAccessed: ++_accessCounter,
    );
    
    // Evict oldest entries if cache is full
    if (_cache.length > _maxCacheSize) {
      _evictOldestEntries();
    }
    
    if (kDebugMode) {
      debugPrint('📊 SnapSizeCache: Cache MISS for $key, calculated: $snapSizes');
    }
    
    return snapSizes;
  }
  
  /// Generate cache key from parameters
  static String _generateCacheKey({
    required Size screenSize,
    required bool isKeyboardVisible,
    required bool fullSnap,
    required bool popupWithKeyboard,
    required bool isFullScreen,
  }) {
    // Round screen size to reduce cache fragmentation
    final roundedWidth = (screenSize.width / 10).round() * 10;
    final roundedHeight = (screenSize.height / 10).round() * 10;
    
    return '${roundedWidth}x${roundedHeight}_kb:${isKeyboardVisible}_fs:${fullSnap}_pk:${popupWithKeyboard}_scr:$isFullScreen';
  }
  
  /// Calculate snap sizes using the same logic as BottomSheetService
  static List<double> _calculateSnapSizes({
    required Size screenSize,
    required bool isKeyboardVisible,
    required bool fullSnap,
    required bool popupWithKeyboard,
    required bool isFullScreen,
  }) {
    // Calculate device aspect ratio
    final deviceAspectRatio = screenSize.height / screenSize.width;
    
    // Smart snapping logic from BottomSheetService
    if (popupWithKeyboard == false && 
        fullSnap == false && 
        isFullScreen == false && 
        deviceAspectRatio > 2) {
      // Standard two-point snapping for tall devices
      return [0.6, 1.0];
    } else {
      // Near-full screen snapping for:
      // - Keyboards present
      // - Full snap requested
      // - Full screen devices
      // - Landscape orientation
      return [0.95, 1.0];
    }
  }
  
  /// Evict oldest cache entries to maintain size limit
  static void _evictOldestEntries() {
    // Find entries to remove (25% of cache size)
    final entriesToRemove = (_maxCacheSize * 0.25).ceil();
    
    // Sort by access time and remove oldest
    final sortedEntries = _cache.entries.toList()
      ..sort((a, b) => a.value.lastAccessed.compareTo(b.value.lastAccessed));
    
    for (int i = 0; i < entriesToRemove && i < sortedEntries.length; i++) {
      _cache.remove(sortedEntries[i].key);
    }
    
    if (kDebugMode) {
      debugPrint('📊 SnapSizeCache: Evicted $entriesToRemove entries, cache size now: ${_cache.length}');
    }
  }
  
  /// Clear the entire cache (useful for memory pressure or testing)
  static void clearCache() {
    _cache.clear();
    _accessCounter = 0;
    
    if (kDebugMode) {
      debugPrint('📊 SnapSizeCache: Cache cleared');
    }
  }
  
  /// Get cache statistics for performance monitoring
  static CacheStatistics getStatistics() {
    final total = _hitCount + _missCount;
    final hitRate = total > 0 ? (_hitCount / total) : 0.0;
    
    return CacheStatistics(
      hitCount: _hitCount,
      missCount: _missCount,
      hitRate: hitRate,
      cacheSize: _cache.length,
      maxCacheSize: _maxCacheSize,
    );
  }
  
  /// Reset statistics (useful for testing)
  static void resetStatistics() {
    _hitCount = 0;
    _missCount = 0;
  }
  
  /// Print cache statistics to debug console
  static void printStatistics() {
    if (kDebugMode) {
      final stats = getStatistics();
      debugPrint('\n📊 SnapSizeCache Statistics:');
      debugPrint('   Hit Rate: ${(stats.hitRate * 100).toStringAsFixed(1)}%');
      debugPrint('   Hits: ${stats.hitCount}');
      debugPrint('   Misses: ${stats.missCount}');
      debugPrint('   Cache Size: ${stats.cacheSize}/${stats.maxCacheSize}');
      debugPrint('');
    }
  }
}

/// Internal cache entry with LRU tracking
class _CacheEntry {
  final List<double> snapSizes;
  int lastAccessed;
  
  _CacheEntry({
    required this.snapSizes,
    required this.lastAccessed,
  });
}

/// Cache performance statistics
class CacheStatistics {
  final int hitCount;
  final int missCount;
  final double hitRate;
  final int cacheSize;
  final int maxCacheSize;
  
  const CacheStatistics({
    required this.hitCount,
    required this.missCount,
    required this.hitRate,
    required this.cacheSize,
    required this.maxCacheSize,
  });
  
  /// Whether the cache is performing well (target: 80% hit rate)
  bool get isPerformingWell => hitRate >= 0.8;
  
  /// Whether the cache is nearly full
  bool get isNearlyFull => cacheSize >= (maxCacheSize * 0.9);
  
  @override
  String toString() {
    return 'CacheStatistics(hitRate: ${(hitRate * 100).toStringAsFixed(1)}%, '
           'hits: $hitCount, misses: $missCount, size: $cacheSize/$maxCacheSize)';
  }
}