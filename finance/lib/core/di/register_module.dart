import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/database_service.dart';
import '../database/app_database.dart';

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
      ]);

  /// Provides HTTP client for network operations
  @lazySingleton
  http.Client get httpClient => http.Client();

  /// Provides DatabaseService instance for production
  @lazySingleton
  DatabaseService get databaseService => DatabaseService();

  /// Provides AppDatabase instance from DatabaseService
  @lazySingleton
  AppDatabase appDatabase(DatabaseService service) => service.database;

}