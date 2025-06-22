import 'package:flutter_test/flutter_test.dart';
import 'package:finance/core/services/database_cache_service.dart';

void main() {
  group('DatabaseCacheService', () {
    late DatabaseCacheService cacheService;

    setUp(() {
      cacheService = DatabaseCacheService();
      cacheService.clear();
    });

    test('should cache and retrieve a value', () async {
      const key = 'test_key';
      const value = 'test_value';

      await cacheService.set(key, value);
      final cachedValue = await cacheService.get<String>(key);

      expect(cachedValue, equals(value));
    });

    test('should return null for expired cache item', () async {
      const key = 'expired_key';
      const value = 'expired_value';

      await cacheService.set(key, value, ttl: const Duration(milliseconds: 10));
      await Future.delayed(const Duration(milliseconds: 20));

      final cachedValue = await cacheService.get<String>(key);
      expect(cachedValue, isNull);
    });

    test('should invalidate a cached item', () async {
      const key = 'invalidate_key';
      const value = 'invalidate_value';

      await cacheService.set(key, value);
      var cachedValue = await cacheService.get<String>(key);
      expect(cachedValue, equals(value));

      await cacheService.invalidate(key);
      cachedValue = await cacheService.get<String>(key);
      expect(cachedValue, isNull);
    });

    test('should clear all cached items', () async {
      await cacheService.set('key1', 'value1');
      await cacheService.set('key2', 'value2');

      await cacheService.clear();

      final value1 = await cacheService.get<String>('key1');
      final value2 = await cacheService.get<String>('key2');

      expect(value1, isNull);
      expect(value2, isNull);
    });

    test('should clean up expired items', () async {
      const validKey = 'valid_key';
      const expiredKey = 'expired_key';

      await cacheService.set(validKey, 'valid_data');
      await cacheService.set(expiredKey, 'expired_data',
          ttl: const Duration(milliseconds: 10));

      await Future.delayed(const Duration(milliseconds: 20));

      cacheService.cleanExpired();

      final validData = await cacheService.get(validKey);
      final expiredData = await cacheService.get(expiredKey);

      expect(validData, isNotNull);
      expect(expiredData, isNull);
    });
  });
}
