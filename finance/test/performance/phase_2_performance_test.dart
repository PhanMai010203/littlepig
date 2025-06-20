import 'package:flutter_test/flutter_test.dart';
import 'dart:async';

import 'package:finance/core/services/database_cache_service.dart';

void main() {
  group('Phase 2 – Database Optimization Benchmarks', () {
    late DatabaseCacheService cacheService;

    /// A mock expensive fetch that simulates an I/O-heavy database call.
    Future<int> _expensiveFetch() async {
      // Simulate latency – this value is intentionally high enough so that a
      // cached call will be noticeably faster even on slower CI machines.
      await Future.delayed(const Duration(milliseconds: 50));
      return 42;
    }

    Future<int> _getDataWithCache(String key) async {
      // Check the in-memory cache first
      final cached = await cacheService.get<int>(key);
      if (cached != null) return cached;

      // Otherwise perform the expensive operation and cache the result
      final data = await _expensiveFetch();
      await cacheService.set<int>(key, data);
      return data;
    }

    setUp(() {
      cacheService = DatabaseCacheService();
      cacheService.clear();
    });

    test('cached retrieval is significantly faster than initial fetch', () async {
      // First call – should execute the expensive fetch
      final stopwatchFirst = Stopwatch()..start();
      await _getDataWithCache('demo');
      stopwatchFirst.stop();

      // Second call – should hit the in-memory cache
      final stopwatchSecond = Stopwatch()..start();
      await _getDataWithCache('demo');
      stopwatchSecond.stop();

      // On most machines/CI systems the cached call should be at least 4× faster.
      // We use a conservative threshold ( >2× faster ) to avoid flaky tests.
      expect(stopwatchSecond.elapsedMicroseconds * 2,
          lessThan(stopwatchFirst.elapsedMicroseconds));
    });

    test('cache invalidation resets performance advantage', () async {
      // Populate cache
      await _getDataWithCache('invalidate_demo');

      // Cached call (baseline time)
      final cachedTimer = Stopwatch()..start();
      await _getDataWithCache('invalidate_demo');
      cachedTimer.stop();

      // Invalidate and fetch again – should be slower than cached call
      await cacheService.invalidate('invalidate_demo');
      final uncachedTimer = Stopwatch()..start();
      await _getDataWithCache('invalidate_demo');
      uncachedTimer.stop();

      expect(cachedTimer.elapsedMicroseconds,
          lessThan(uncachedTimer.elapsedMicroseconds));
    });
  });
}
