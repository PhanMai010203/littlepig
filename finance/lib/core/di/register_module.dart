import 'package:finance/core/database/app_database.dart';
import 'package:finance/core/services/database_service.dart';
import 'package:finance/core/sync/google_drive_sync_service.dart';
import 'package:finance/core/sync/incremental_sync_service.dart';
import 'package:finance/core/sync/sync_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Injectable module for dependency registration
/// This module handles the registration of core dependencies that require
/// special initialization or are not easily handled by Injectable's
/// automatic registration.
@module
abstract class RegisterModule {
  /// Provides SharedPreferences instance
  /// Uses @preResolve to handle the async initialization
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  /// Provides GoogleSignIn instance with required scopes
  @lazySingleton
  GoogleSignIn googleSignIn() => GoogleSignIn(scopes: [
        'https://www.googleapis.com/auth/drive.file',
      ]);

  /// Provides HTTP client for network operations
  @lazySingleton
  http.Client httpClient() => http.Client();

  /// Provides DatabaseService instance
  @lazySingleton
  DatabaseService databaseService() => DatabaseService();

  /// Provides AppDatabase instance by exposing the database from DatabaseService
  /// This allows the generated Injectable factories to inject AppDatabase directly
  @lazySingleton
  AppDatabase appDatabase(DatabaseService databaseService) => 
      databaseService.database;

  @preResolve
  @LazySingleton(as: SyncService)
  Future<SyncService> incrementalSyncService(AppDatabase db) async {
    final service = IncrementalSyncService(db);
    await service.initialize();
    return service;
  }

  @preResolve
  @lazySingleton
  Future<GoogleDriveSyncService> googleDriveSyncService(AppDatabase db) async {
    final service = GoogleDriveSyncService(db);
    await service.initialize();
    return service;
  }

  /// Provides test-specific DatabaseService (for testing only)
  @Environment('test')
  @LazySingleton(as: DatabaseService)
  DatabaseService testDatabaseService() => DatabaseService.forTesting();

  /// Provides test-specific AppDatabase (for testing only)
  @Environment('test')
  @LazySingleton(as: AppDatabase)
  AppDatabase testAppDatabase(DatabaseService databaseService) => 
      databaseService.database;
}