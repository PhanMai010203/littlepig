import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

import '../services/database_service.dart';
import '../database/app_database.dart';
import '../sync/incremental_sync_service.dart';
import '../sync/google_drive_sync_service.dart';
import '../sync/sync_service.dart';

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
  GoogleSignIn get googleSignIn => GoogleSignIn(scopes: [
        'https://www.googleapis.com/auth/drive.file',
        'https://www.googleapis.com/auth/drive.appdata',
      ]);

  /// Provides HTTP client for network operations
  @lazySingleton
  http.Client get httpClient => http.Client();

  /// Provides DatabaseService instance for production and development
  @lazySingleton
  @Environment(Environment.prod)
  @Environment(Environment.dev)
  DatabaseService get databaseService => DatabaseService();

  /// Provides DatabaseService instance for testing with in-memory database
  @lazySingleton
  @Environment(Environment.test)
  DatabaseService get testDatabaseService => DatabaseService.forTesting();

  /// Provides AppDatabase instance from DatabaseService for production and development
  @lazySingleton
  @Environment(Environment.prod)
  @Environment(Environment.dev)
  AppDatabase appDatabase(DatabaseService service) => service.database;

  /// Provides AppDatabase instance from test DatabaseService for testing
  @lazySingleton
  @Environment(Environment.test)
  AppDatabase testAppDatabase(DatabaseService service) => service.database;

  /// Provides IncrementalSyncService with async initialization
  /// Uses @preResolve to handle the async initialize() call
  @preResolve
  Future<IncrementalSyncService> incrementalSyncService(
    AppDatabase database,
    SharedPreferences prefs,
  ) async {
    final service = IncrementalSyncService(database, prefs);
    await service.initialize();
    return service;
  }

  /// Provides GoogleDriveSyncService with async initialization
  /// Uses @preResolve to handle the async initialize() call
  @preResolve
  Future<GoogleDriveSyncService> googleDriveSyncService(AppDatabase database) async {
    final service = GoogleDriveSyncService(database);
    await service.initialize();
    return service;
  }

  /// Provides SyncService implementation
  /// Uses IncrementalSyncService as the default implementation
  @lazySingleton
  SyncService syncService(IncrementalSyncService service) => service;

  /// Provides ImagePicker instance
  @lazySingleton
  ImagePicker get imagePicker => ImagePicker();
}