import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart';
import '../database/app_database.dart';

/// Database connection optimizer for Drift
///
/// Implements optimizations such as:
/// - WAL (Write-Ahead Logging) mode for better concurrency
/// - Connection pooling simulation through reusable connections
/// - Performance pragmas
/// - Memory optimization
class DatabaseConnectionOptimizer {
  static DatabaseConnection? _sharedConnection;
  static AppDatabase? _sharedDatabase;

  /// Get optimized database instance (singleton pattern)
  static Future<AppDatabase> getOptimizedDatabase() async {
    if (_sharedDatabase != null) {
      return _sharedDatabase!;
    }

    _sharedDatabase = AppDatabase();

    // Apply optimizations after database creation
    await applyOptimizations(_sharedDatabase!);

    return _sharedDatabase!;
  }

  /// Apply optimization pragmas to an existing database
  static Future<void> applyOptimizations(AppDatabase database) async {
    try {
      // Enable WAL mode for better concurrency
      await database.customStatement('PRAGMA journal_mode = WAL');

      // Optimize for performance
      await database
          .customStatement('PRAGMA synchronous = NORMAL'); // Faster than FULL
      await database
          .customStatement('PRAGMA cache_size = -64000'); // 64MB cache
      await database.customStatement(
          'PRAGMA temp_store = MEMORY'); // Use memory for temp tables

      // Enable foreign keys
      await database.customStatement('PRAGMA foreign_keys = ON');

      // Optimize query planner
      await database.customStatement('PRAGMA optimize');

      // Set WAL checkpoint for better performance
      await database.customStatement('PRAGMA wal_autocheckpoint = 1000');

      // Memory management
      await database
          .customStatement('PRAGMA mmap_size = 268435456'); // 256MB mmap
    } catch (e) {
      // Log error but don't throw - fallback to default settings
      print('Warning: Could not apply all database optimizations: $e');
    }
  }

  /// Create an optimized database connection with performance settings
  static DatabaseConnection createOptimizedConnection(String dbPath) {
    if (_sharedConnection != null) {
      return _sharedConnection!;
    }

    final database = sqlite3.open(dbPath);

    // Apply optimization settings directly to sqlite3 database
    _applySqlite3Optimizations(database);

    _sharedConnection =
        DatabaseConnection.fromExecutor(NativeDatabase.opened(database));

    return _sharedConnection!;
  }

  /// Apply optimizations directly to sqlite3 database
  static void _applySqlite3Optimizations(Database database) {
    try {
      // WAL mode for better concurrency
      database.execute('PRAGMA journal_mode = WAL');

      // Performance optimizations
      database.execute('PRAGMA synchronous = NORMAL');
      database.execute('PRAGMA cache_size = -64000'); // 64MB cache
      database.execute('PRAGMA temp_store = MEMORY');
      database.execute('PRAGMA foreign_keys = ON');
      database.execute('PRAGMA optimize');
      database.execute('PRAGMA wal_autocheckpoint = 1000');
      database.execute('PRAGMA mmap_size = 268435456'); // 256MB mmap

      // Additional performance settings
      database.execute('PRAGMA busy_timeout = 30000'); // 30 second timeout
      database.execute(
          'PRAGMA locking_mode = NORMAL'); // Allow multiple connections
    } catch (e) {
      print('Warning: Could not apply sqlite3 optimizations: $e');
    }
  }

  /// Monitor database performance and return metrics
  static Future<Map<String, dynamic>> getPerformanceMetrics(
      AppDatabase database) async {
    try {
      final journalMode =
          await database.customSelect('PRAGMA journal_mode').getSingle();
      final cacheSize =
          await database.customSelect('PRAGMA cache_size').getSingle();
      final synchronous =
          await database.customSelect('PRAGMA synchronous').getSingle();
      final tempStore =
          await database.customSelect('PRAGMA temp_store').getSingle();
      final foreignKeys =
          await database.customSelect('PRAGMA foreign_keys').getSingle();

      return {
        'journal_mode': journalMode.data.values.first,
        'cache_size': cacheSize.data.values.first,
        'synchronous': synchronous.data.values.first,
        'temp_store': tempStore.data.values.first,
        'foreign_keys': foreignKeys.data.values.first,
        'optimization_applied': true,
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'optimization_applied': false,
      };
    }
  }

  /// Cleanup and close connections
  static Future<void> cleanup() async {
    try {
      if (_sharedDatabase != null) {
        await _sharedDatabase!.close();
        _sharedDatabase = null;
      }

      _sharedConnection = null;
    } catch (e) {
      print('Warning: Error during database cleanup: $e');
    }
  }

  /// Run database maintenance operations
  static Future<void> performMaintenance(AppDatabase database) async {
    try {
      // Run VACUUM to optimize database file
      await database.customStatement('VACUUM');

      // Update query statistics
      await database.customStatement('ANALYZE');

      // Optimize query planner
      await database.customStatement('PRAGMA optimize');

      // Force WAL checkpoint
      await database.customStatement('PRAGMA wal_checkpoint(TRUNCATE)');
    } catch (e) {
      print('Warning: Error during database maintenance: $e');
    }
  }
}
