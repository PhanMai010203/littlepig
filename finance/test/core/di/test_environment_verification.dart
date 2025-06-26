import 'dart:io';

import 'package:test/test.dart';
import 'package:get_it/get_it.dart';
import 'package:finance/core/di/injection.dart';
import 'package:finance/core/services/database_service.dart';
import 'package:finance/core/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';

void main() {
  group('Task 2 Verification: Test Environment Configuration', () {
    test('File existence check', () async {
      final requiredFiles = [
        'lib/core/di/register_module.dart',
        'lib/core/di/injection.dart',
        'lib/core/di/injection.config.dart',
        'lib/core/services/database_service.dart',
        'test/helpers/test_di.dart'
      ];
      for (final file in requiredFiles) {
        expect(await File(file).exists(), isTrue, reason: '$file should exist');
      }
    });

    test('Injectable annotations check in RegisterModule', () async {
      final registerModuleContent =
          await File('lib/core/di/register_module.dart').readAsString();
      expect(registerModuleContent, contains('@Environment(Environment.test)'));
      expect(registerModuleContent,
          contains('DatabaseService get testDatabaseService => DatabaseService.forTesting()'));
      expect(registerModuleContent,
          contains('AppDatabase testAppDatabase(DatabaseService service)'));
    });

    test('Generated configuration check in injection.config.dart', () async {
      final configContent = await File('lib/core/di/injection.config.dart').readAsString();
      expect(configContent, contains("const String _test = 'test';"));
      expect(configContent, contains('registerFor: {_test}'));
      expect(configContent, contains('testDatabaseService'));
      expect(configContent, contains('testAppDatabase'));
    });

    test('DatabaseService uses in-memory database for testing', () async {
      await configureDependencies('test');
      final dbService = getIt<DatabaseService>();
      // We expect the test instance, which uses an in-memory db
      // There isn't a direct public type for `InMemory`, so we check the executor type.
      expect(dbService.database.executor, isA<NativeDatabase>());
      await getIt.reset();
    });
  });
} 