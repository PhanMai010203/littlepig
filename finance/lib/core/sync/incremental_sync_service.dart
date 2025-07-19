import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'sync_service.dart';
import 'sync_event.dart';
import 'crdt_conflict_resolver.dart';
import '../database/app_database.dart';
import '../utils/safe_parsing.dart';
import 'google_drive_sync_service.dart';

/// Incremental sync service using event sourcing
/// This implements Phase 3 of the sync upgrade - real-time event-driven sync
class IncrementalSyncService implements SyncService {
  static const List<String> _scopes = [
    'https://www.googleapis.com/auth/drive.file',
    'https://www.googleapis.com/auth/drive.appdata',
  ];

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: _scopes,
    signInOption: SignInOption.standard,
    // Set hostedDomain to null to allow any Google account
    hostedDomain: null,
    // Force user consent dialog every time to help with testing
    forceCodeForRefreshToken: true,
  );
  final AppDatabase _database;
  final SharedPreferences _prefs;
  final StreamController<SyncStatus> _statusController =
      StreamController<SyncStatus>.broadcast();
  final CRDTConflictResolver _conflictResolver = CRDTConflictResolver();

  String? _deviceId;
  bool _isSyncing = false;
  
  // Authentication state caching keys
  static const String _authStatusKey = 'sync_auth_status';
  static const String _userEmailKey = 'sync_user_email';
  static const String _lastAuthCheckKey = 'sync_last_auth_check';

  IncrementalSyncService(this._database, this._prefs);

  @override
  Stream<SyncStatus> get syncStatusStream => _statusController.stream;

  @override
  bool get isSyncing => _isSyncing;

  @override
  Future<bool> initialize() async {
    try {
      // 🔧 Migrate any legacy timestamp strings to ISO-8601 before we start using the database
      await _migrateLegacyTimestampFormats();

      _deviceId = await _getOrCreateDeviceId();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> isSignedIn() async {
    try {
      // First check cached authentication status for faster startup
      final cached = _getCachedAuthenticationStatus();
      if (cached != null) {
        final (isSignedIn, _) = cached;
        if (isSignedIn) {
          // Verify current user exists for cached positive results
          final currentUser = _googleSignIn.currentUser;
          if (currentUser != null) {
            debugPrint('🔬 Using cached auth status: signed-in=true');
            return true;
          }
        } else {
          // For cached negative results, trust them for faster negative response
          debugPrint('🔬 Using cached auth status: signed-in=false');
          return false;
        }
      }
      
      // If no valid cache, perform full authentication check
      debugPrint('🔬 Performing fresh authentication check...');
      
      bool finalResult = false;
      String? finalEmail;
      
      // Check current Google Sign-In status
      final result = await _googleSignIn.isSignedIn();
      debugPrint('🔬 GoogleSignIn.isSignedIn() returned: $result');
      
      if (result) {
        final currentUser = _googleSignIn.currentUser;
        debugPrint('🔬 Current user: ${currentUser?.email ?? 'null'}');
        
        if (currentUser != null) {
          finalResult = true;
          finalEmail = currentUser.email;
        } else {
          // If signed in but no current user, try silent sign-in to restore session
          debugPrint('🔬 User signed in but no current user, attempting silent sign-in...');
          try {
            final account = await _googleSignIn.signInSilently();
            debugPrint('🔬 Silent sign-in result: ${account?.email ?? 'null'}');
            finalResult = account != null;
            finalEmail = account?.email;
          } catch (silentSignInError) {
            debugPrint('❌ Silent sign-in failed: $silentSignInError');
            finalResult = false;
          }
        }
      } else {
        // Try silent sign-in to restore previous authentication
        debugPrint('🔬 Not signed in, attempting silent sign-in to restore session...');
        try {
          final account = await _googleSignIn.signInSilently();
          debugPrint('🔬 Silent sign-in result: ${account?.email ?? 'null'}');
          finalResult = account != null;
          finalEmail = account?.email;
        } catch (silentSignInError) {
          debugPrint('🔬 Silent sign-in failed (expected if never signed in): $silentSignInError');
          finalResult = false;
        }
      }
      
      // Cache the result for future use
      await _cacheAuthenticationStatus(finalResult, finalEmail);
      
      return finalResult;
    } catch (e) {
      debugPrint('❌ Error checking sign-in status: $e');
      // Cache negative result on error
      await _cacheAuthenticationStatus(false, null);
      return false;
    }
  }

  @override
  Future<bool> signIn() async {
    debugPrint('🔐 IncrementalSyncService: Starting Google Sign-In process...');
    debugPrint('🔬 GoogleSignIn config - scopes: $_scopes');
    debugPrint('🔬 Current device ID: $_deviceId');
    
    // Get package info for debugging
    try {
      const packageName = 'com.sheep.budget';
      debugPrint('📦 Package name: $packageName');
    } catch (e) {
      debugPrint('❌ Error getting package info: $e');
    }
    
    try {
      // Check if already signed in
      final isSignedIn = await _googleSignIn.isSignedIn();
      debugPrint('🔬 GoogleSignIn.isSignedIn() returned: $isSignedIn');
      
      if (isSignedIn) {
        final currentUser = _googleSignIn.currentUser;
        debugPrint('🔬 Already signed in: ${currentUser?.email}, attempting to retrieve auth headers...');
        try {
          final headers = await currentUser?.authHeaders;
          debugPrint('🔬 Auth headers: ${headers?.keys.toList()}');
          debugPrint('🔬 Auth token available: ${headers?['Authorization'] != null}');
        } catch (headerError) {
          debugPrint('❌ Error retrieving auth headers: $headerError');
        }
      }
      
      // Try silent sign-in first
      try {
        debugPrint('🔬 Attempting silent sign-in first...');
        final silentAccount = await _googleSignIn.signInSilently();
        if (silentAccount != null) {
          debugPrint('✅ Silent sign-in succeeded with account: ${silentAccount.email}');
          return true;
        } else {
          debugPrint('ℹ️ Silent sign-in returned null, continuing to interactive sign-in');
        }
      } catch (silentError) {
        debugPrint('ℹ️ Silent sign-in failed: $silentError, continuing to interactive sign-in');
      }
      
      debugPrint('🔬 Calling _googleSignIn.signIn()...');
      final account = await _googleSignIn.signIn();
      
      debugPrint('🔐 IncrementalSyncService: Sign-In result: ${account != null ? 'Success' : 'Canceled/Failed'}');
      
      if (account != null) {
        debugPrint('🔬 ACCOUNT RAW DATA:');
        debugPrint('� - ID: ${account.id}');
        debugPrint('🔬 - Email: ${account.email}');
        debugPrint('🔬 - Display Name: ${account.displayName}');
        debugPrint('🔬 - Photo URL: ${account.photoUrl}');
        debugPrint('🔬 - Server Auth Code available: ${account.serverAuthCode != null}');
        
        try {
          final authHeaders = await account.authHeaders;
          debugPrint('🔬 Auth headers obtained: ${authHeaders.keys.toList()}');
          final authToken = authHeaders['Authorization']?.split(' ')[1];
          debugPrint('🔬 Auth token available: ${authToken != null}, First 10 chars: ${authToken?.substring(0, min(10, authToken.length))}...');
          
          // Check if we can access Drive API
          debugPrint('🔬 Testing Drive API access...');
          final client = authenticatedClient(
            http.Client(),
            AccessCredentials(
              AccessToken('Bearer', authToken ?? '', DateTime.now().toUtc().add(const Duration(hours: 1))),
              null,
              _scopes,
            ),
          );
          
          try {
            final driveApi = drive.DriveApi(client);
            final about = await driveApi.about.get($fields: 'user');
            debugPrint('🔬 Drive API access successful: ${about.toJson()}');
          } catch (driveError) {
            debugPrint('❌ Drive API access failed: $driveError');
          } finally {
            client.close();
          }
        } catch (authError) {
          debugPrint('❌ Failed to get auth headers: $authError');
        }
      } else {
        debugPrint('❌ Sign-in failed or was cancelled by the user');
      }
      
      final success = account != null;
      
      // Cache authentication status after sign-in attempt
      if (success) {
        await _cacheAuthenticationStatus(true, account.email);
      } else {
        await _cacheAuthenticationStatus(false, null);
      }
      
      return success;
    } catch (e, stackTrace) {
      debugPrint('❌ IncrementalSyncService: Sign-In error: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      
      // More detailed error reporting for common Google Sign-In errors
      if (e is PlatformException) {
        if (e.code == 'sign_in_failed') {
          if (e.message?.contains('ApiException: 10') == true) {
            debugPrint('❗❗❗ GOOGLE SIGN IN ERROR DIAGNOSIS ❗❗❗');
            debugPrint('Error code 10 indicates a developer configuration error OR app verification issue.');
            
            if (e.message?.contains('blocked') == true || e.message?.contains('verification') == true) {
              debugPrint('❗❗❗ APP VERIFICATION ISSUE DETECTED ❗❗❗');
              debugPrint('Your app has not completed the Google verification process for sensitive scopes.');
              debugPrint('This is preventing users from signing in with Google Drive access.');
              
              debugPrint('\n🔐 SOLUTIONS:');
              debugPrint('1. SHORT TERM: Add test users to your Google Cloud Console project:');
              debugPrint('   - Go to: https://console.cloud.google.com/apis/credentials/consent');
              debugPrint('   - Click on your OAuth consent screen');
              debugPrint('   - Scroll down to "Test users" and click "ADD USERS"');
              debugPrint('   - Add your Google email address and any other test users');
              debugPrint('   - Save changes and try again with those accounts');
              
              debugPrint('\n2. LONG TERM: Complete Google\'s verification process:');
              debugPrint('   - Go to: https://console.cloud.google.com/apis/credentials/consent');
              debugPrint('   - Click "EDIT APP" and complete all required fields');
              debugPrint('   - Submit your app for verification by Google');
              debugPrint('   - This may take several days to weeks to complete');
            } else {
              debugPrint('This typically means:');
              debugPrint('1. SHA-1/SHA-256 fingerprints don\'t match what\'s in Google Cloud Console');
              debugPrint('2. Package name (com.sheep.budget) doesn\'t match what\'s registered');
              debugPrint('3. The Google Cloud project isn\'t properly configured for OAuth');
              
              // Print debug information to help with troubleshooting
              debugPrint('\n📱 APP CONFIGURATION:');
              debugPrint('Package name: com.sheep.budget');
              debugPrint('Requested scopes: $_scopes');
              
              // Generate helpful command to obtain SHA-1
              debugPrint('\n🔑 TO FIX: Run this command to get your debug SHA-1:');
              debugPrint('keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android');
              debugPrint('\nThen update this SHA-1 in your Google Cloud Console project.');
              debugPrint('Go to: https://console.cloud.google.com/apis/credentials');
            }
          } else if (e.message?.contains('12501') == true) {
            debugPrint('❗ User cancelled the sign-in process');
          } else {
            debugPrint('❗ Unknown sign-in failure: ${e.message}');
          }
        }
      }
      
      return false;
    }
  }

  @override
  Future<void> signOut() async {
    debugPrint('🔬 Attempting to sign out user...');
    try {
      final wasSignedIn = await _googleSignIn.isSignedIn();
      debugPrint('🔬 User was signed in: $wasSignedIn');
      if (wasSignedIn) {
        final email = _googleSignIn.currentUser?.email;
        debugPrint('🔬 Signing out user: $email');
      }
      
      await _googleSignIn.signOut();
      debugPrint('✅ User signed out successfully');
      
      // Clear authentication cache after sign-out
      await _clearAuthenticationCache();
      
      final isStillSignedIn = await _googleSignIn.isSignedIn();
      debugPrint('🔬 User is still signed in after signOut: $isStillSignedIn');
    } catch (e) {
      debugPrint('❌ Error during sign out: $e');
      debugPrint('❌ Stack trace: ${StackTrace.current}');
    }
  }

  @override
  Future<String?> getCurrentUserEmail() async {
    try {
      var account = _googleSignIn.currentUser;
      debugPrint('🔬 getCurrentUserEmail - currentUser: ${account != null ? 'found' : 'null'}');
      
      // If no current user, try silent sign-in to restore session
      if (account == null) {
        debugPrint('🔬 No current user, attempting silent sign-in...');
        try {
          account = await _googleSignIn.signInSilently();
          debugPrint('🔬 Silent sign-in result: ${account?.email ?? 'null'}');
        } catch (silentSignInError) {
          debugPrint('🔬 Silent sign-in failed: $silentSignInError');
        }
      }
      
      if (account != null) {
        debugPrint('🔬 getCurrentUserEmail - email: ${account.email}');
        
        try {
          // Check if auth is still valid
          final authHeaders = await account.authHeaders;
          debugPrint('🔬 Auth headers valid: ${authHeaders.isNotEmpty}');
        } catch (authError) {
          debugPrint('❌ Auth validation failed: $authError');
          // If auth is invalid, try to sign out and return null
          await _googleSignIn.signOut();
          return null;
        }
      }
      return account?.email;
    } catch (e) {
      debugPrint('❌ Error in getCurrentUserEmail: $e');
      return null;
    }
  }

  @override
  Future<SyncResult> syncToCloud() async {
    if (_isSyncing) {
      return SyncResult(
        success: false,
        error: 'Sync already in progress',
        uploadedCount: 0,
        downloadedCount: 0,
        timestamp: DateTime.now(),
      );
    }

    _isSyncing = true;
    _statusController.add(SyncStatus.uploading);

    try {
      debugPrint('📤 Starting syncToCloud...');
      
      // 🌡️ Extra diagnostic – ensure no bad timestamps remain before proceeding
      await _detectInvalidTimestamps();

      // Get unsynced events since last sync
      debugPrint('📋 Fetching unsynced events...');
      List<SyncEventLogData> unsyncedEvents;
      try {
        unsyncedEvents = await _getUnsyncedEvents();
        debugPrint('📋 Found ${unsyncedEvents.length} unsynced events');
      } catch (e, stackTrace) {
        debugPrint('❌ ERROR in _getUnsyncedEvents: $e');
        debugPrint('📍 Stack trace: $stackTrace');
        rethrow;
      }

      if (unsyncedEvents.isEmpty) {
        debugPrint('✅ No unsynced events found, sync complete');
        _statusController.add(SyncStatus.completed);
        return SyncResult(
          success: true,
          uploadedCount: 0,
          downloadedCount: 0,
          timestamp: DateTime.now(),
        );
      }

      debugPrint('🔑 Checking authentication...');
      final account = _googleSignIn.currentUser;
      if (account == null) {
        throw Exception('Not signed in');
      }

      debugPrint('🔐 Getting auth headers...');
      final authHeaders = await account.authHeaders;
      final client = authenticatedClient(
        http.Client(),
        AccessCredentials(
          AccessToken(
              'Bearer',
              authHeaders['Authorization']?.split(' ')[1] ?? '',
              DateTime.now().toUtc().add(const Duration(hours: 1))),
          null,
          _scopes,
        ),
      );

      final driveApi = drive.DriveApi(client);

      // Create events batch (much smaller than entire database!)
      debugPrint('📦 Creating events batch...');
      List<SyncEvent> events;
      try {
        events = unsyncedEvents.map(SyncEvent.fromEventLog).toList();
        debugPrint('📦 Successfully created ${events.length} sync events');
      } catch (e, stackTrace) {
        debugPrint('❌ ERROR creating SyncEvent from EventLog: $e');
        debugPrint('📍 Stack trace: $stackTrace');
        
        // Check if it's a FormatException (radix 10 error)
        if (e is FormatException) {
          debugPrint('🔢 RADIX 10 ERROR detected in SyncEvent creation!');
          debugPrint('   - FormatException message: ${e.message}');
          debugPrint('   - FormatException source: ${e.source}');
          debugPrint('   - FormatException offset: ${e.offset}');
        }
        
        // Log details about each problematic event
        for (int i = 0; i < unsyncedEvents.length; i++) {
          final event = unsyncedEvents[i];
          try {
            debugPrint('🔍 Testing event $i: eventId=${event.eventId}, sequenceNumber=${event.sequenceNumber} (${event.sequenceNumber.runtimeType}), timestamp=${event.timestamp} (${event.timestamp.runtimeType})');
            SyncEvent.fromEventLog(event);
            debugPrint('✅ Event $i processed successfully');
          } catch (eventError) {
            debugPrint('❌ Problem with event $i: eventId=${event.eventId}, timestamp=${event.timestamp}, sequenceNumber=${event.sequenceNumber}, error=$eventError');
            if (eventError is FormatException) {
              debugPrint('🔢 RADIX 10 ERROR in event $i:');
              debugPrint('   - message: ${eventError.message}');
              debugPrint('   - source: ${eventError.source}');
              debugPrint('   - offset: ${eventError.offset}');
            }
          }
        }
        rethrow;
      }

      final eventsBatch = SyncEventBatch(
        deviceId: _deviceId!,
        timestamp: DateTime.now(),
        events: events,
      );

      // Upload to dedicated sync folder
      debugPrint('📁 Ensuring sync folder exists...');
      final syncFolderId = await _ensureFolderExists(
          driveApi, GoogleDriveSyncService.SYNC_FOLDER);
      final fileName =
          'events_${_deviceId}_${DateTime.now().millisecondsSinceEpoch}.json';

      debugPrint('☁️ Uploading events batch...');
      await _uploadEventBatch(driveApi, syncFolderId, fileName, eventsBatch);

      // Mark events as synced
      debugPrint('✅ Marking events as synced...');
      await _markEventsAsSynced(unsyncedEvents);

      // Update sync state
      debugPrint('🔄 Updating sync state...');
      await _updateSyncState();

      client.close();
      _statusController.add(SyncStatus.completed);
      debugPrint('✅ syncToCloud completed successfully');

      return SyncResult(
        success: true,
        uploadedCount: unsyncedEvents.length,
        downloadedCount: 0,
        timestamp: DateTime.now(),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ FATAL ERROR in syncToCloud: $e');
      debugPrint('📍 Full stack trace: $stackTrace');
      
      // Check if it's a FormatException specifically (radix 10 error)
      if (e is FormatException) {
        debugPrint('🔢 RADIX 10 ERROR DETECTED in syncToCloud!');
        debugPrint('   - FormatException message: ${e.message}');
        debugPrint('   - FormatException source: ${e.source}');
        debugPrint('   - FormatException offset: ${e.offset}');
        debugPrint('🔧 This error has been improved with debug information. Please provide this debug output to the developer.');
      }
      
      _statusController.add(SyncStatus.error);
      return SyncResult(
        success: false,
        error: e.toString(),
        uploadedCount: 0,
        downloadedCount: 0,
        timestamp: DateTime.now(),
      );
    } finally {
      _isSyncing = false;
      _statusController.add(SyncStatus.idle);
    }
  }

  @override
  Future<SyncResult> syncFromCloud() async {
    debugPrint('📥 Starting syncFromCloud...');
    
    if (_isSyncing) {
      debugPrint('❌ Sync already in progress, aborting download');
      return SyncResult(
        success: false,
        error: 'Sync already in progress',
        uploadedCount: 0,
        downloadedCount: 0,
        timestamp: DateTime.now(),
      );
    }

    _isSyncing = true;
    _statusController.add(SyncStatus.downloading);
    debugPrint('🔄 Set sync status to downloading, _isSyncing = true');

    try {
      debugPrint('🔑 Checking authentication...');
      final account = _googleSignIn.currentUser;
      if (account == null) {
        debugPrint('❌ Not signed in, cannot download');
        throw Exception('Not signed in');
      }
      debugPrint('✅ Authenticated as: ${account.email}');

      debugPrint('🔐 Getting auth headers...');
      final authHeaders = await account.authHeaders;
      final client = authenticatedClient(
        http.Client(),
        AccessCredentials(
          AccessToken(
              'Bearer',
              authHeaders['Authorization']?.split(' ')[1] ?? '',
              DateTime.now().toUtc().add(const Duration(hours: 1))),
          null,
          _scopes,
        ),
      );

      final driveApi = drive.DriveApi(client);
      debugPrint('✅ Google Drive API client created');

      // Download event files from other devices
      debugPrint('📁 Ensuring sync folder exists...');
      final syncFolderId = await _ensureFolderExists(
          driveApi, GoogleDriveSyncService.SYNC_FOLDER);
      debugPrint('📁 Sync folder ID: $syncFolderId');
      
      debugPrint('🔍 Looking for event files from other devices...');
      List<drive.File> eventFiles;
      
      // Try file discovery with retry logic for eventual consistency
      int retryCount = 0;
      const maxRetries = 3;
      const retryDelay = Duration(seconds: 2);
      
      while (retryCount < maxRetries) {
        eventFiles = await _getEventFilesFromOtherDevices(driveApi, syncFolderId);
        
        if (eventFiles.isNotEmpty) {
          debugPrint('✅ Found ${eventFiles.length} files on attempt ${retryCount + 1}');
          break;
        }
        
        retryCount++;
        if (retryCount < maxRetries) {
          debugPrint('⏳ No files found on attempt $retryCount/$maxRetries, retrying in ${retryDelay.inSeconds}s...');
          await Future.delayed(retryDelay);
        } else {
          debugPrint('ℹ️ No files found after $maxRetries attempts');
        }
      }

      debugPrint('📋 Found ${eventFiles.length} event files to process');
      int appliedEvents = 0;

      if (eventFiles.isNotEmpty) {
        debugPrint('🔄 Setting status to merging...');
        _statusController.add(SyncStatus.merging);

        for (int i = 0; i < eventFiles.length; i++) {
          final file = eventFiles[i];
          debugPrint('📥 Processing file ${i + 1}/${eventFiles.length}: "${file.name}"');
          
          try {
            final eventBatch = await _downloadAndParseEventBatch(driveApi, file);
            debugPrint('📦 Downloaded event batch with ${eventBatch.events.length} events');
            
            final applied = await _applyEventBatch(eventBatch);
            debugPrint('✅ Applied $applied events from "${file.name}"');
            appliedEvents += applied;

            // Clean up processed event file
            debugPrint('🧹 Cleaning up processed file "${file.name}"');
            await _cleanupProcessedEventFile(driveApi, file);
          } catch (fileError, fileStackTrace) {
            debugPrint('❌ Error processing file "${file.name}": $fileError');
            debugPrint('📍 File error stack trace: $fileStackTrace');
            // Continue with other files even if one fails
          }
        }
      } else {
        debugPrint('ℹ️ No event files found from other devices');
        debugPrint('ℹ️ This could mean:');
        debugPrint('   - No other devices have uploaded events');
        debugPrint('   - Files were already processed and cleaned up');
        debugPrint('   - There is a file discovery issue');
        debugPrint('   - Device ID filtering is too aggressive');
      }

      client.close();
      debugPrint('🔒 Closed Google Drive API client');

      // Update last sync time
      debugPrint('🕒 Updating last sync time...');
      await _updateLastSyncTime(DateTime.now());

      _statusController.add(SyncStatus.completed);
      debugPrint('✅ syncFromCloud completed successfully');
      debugPrint('📊 Total events applied: $appliedEvents');

      return SyncResult(
        success: true,
        uploadedCount: 0,
        downloadedCount: appliedEvents,
        timestamp: DateTime.now(),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ FATAL ERROR in syncFromCloud: $e');
      debugPrint('📍 Full stack trace: $stackTrace');
      
      // Check if it's a specific type of error
      if (e.toString().contains('not found') || e.toString().contains('404')) {
        debugPrint('🔍 Folder or file not found error - may be first time sync');
      } else if (e.toString().contains('auth') || e.toString().contains('401')) {
        debugPrint('🔑 Authentication error - may need to re-sign in');
      } else if (e.toString().contains('quota') || e.toString().contains('limit')) {
        debugPrint('⚠️ Rate limit or quota error - should retry later');
      }
      
      _statusController.add(SyncStatus.error);
      return SyncResult(
        success: false,
        error: e.toString(),
        uploadedCount: 0,
        downloadedCount: 0,
        timestamp: DateTime.now(),
      );
    } finally {
      _isSyncing = false;
      _statusController.add(SyncStatus.idle);
      debugPrint('🔄 Reset _isSyncing = false, status = idle');
    }
  }

  @override
  Future<SyncResult> performFullSync() async {
    debugPrint('🔄 Starting performFullSync...');
    
    // Check if any sync is already in progress
    if (_isSyncing) {
      debugPrint('❌ Another sync operation is already in progress');
      return SyncResult(
        success: false,
        error: 'Sync already in progress',
        uploadedCount: 0,
        downloadedCount: 0,
        timestamp: DateTime.now(),
      );
    }
    
    // First sync to cloud, then sync from cloud
    debugPrint('📤 Phase 1: Uploading local changes...');
    final uploadResult = await syncToCloud();
    if (!uploadResult.success) {
      debugPrint('❌ Upload phase failed, aborting full sync');
      return uploadResult;
    }
    
    debugPrint('✅ Upload phase completed - uploaded ${uploadResult.uploadedCount} items');
    
    // Add delay to handle Google Drive eventual consistency
    // Google Drive may take time to make uploaded files available for listing
    if (uploadResult.uploadedCount > 0) {
      debugPrint('⏳ Adding delay for Google Drive consistency (uploaded ${uploadResult.uploadedCount} items)...');
      await Future.delayed(const Duration(seconds: 3));
      debugPrint('✅ Consistency delay completed');
    }

    debugPrint('📥 Phase 2: Downloading remote changes...');
    
    // For download phase, we need to work around the _isSyncing check
    // since we're still in the middle of a full sync operation
    final downloadResult = await _syncFromCloudInternal();
    
    if (downloadResult.success) {
      debugPrint('✅ Download phase completed - downloaded ${downloadResult.downloadedCount} items');
    } else {
      debugPrint('❌ Download phase failed: ${downloadResult.error}');
    }

    debugPrint('🏁 Full sync completed - uploaded: ${uploadResult.uploadedCount}, downloaded: ${downloadResult.downloadedCount}');

    return SyncResult(
      success: downloadResult.success,
      error: downloadResult.error,
      uploadedCount: uploadResult.uploadedCount,
      downloadedCount: downloadResult.downloadedCount,
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<DateTime?> getLastSyncTime() async {
    final query = _database.select(_database.syncMetadataTable)
      ..where((t) => t.key.equals('last_sync_time'));
    final result = await query.getSingleOrNull();
    if (result != null) {
      return DateTime.parse(result.value);
    }
    return null;
  }

  // ============ PRIVATE METHODS ============

  /// Internal sync from cloud method that doesn't check _isSyncing flag
  /// Used by performFullSync to avoid conflicts with the sync state management
  Future<SyncResult> _syncFromCloudInternal() async {
    debugPrint('📥 Starting _syncFromCloudInternal (bypassing _isSyncing check)...');
    
    // We don't set _isSyncing here since it's already set by the parent operation
    _statusController.add(SyncStatus.downloading);

    try {
      debugPrint('🔑 Checking authentication...');
      final account = _googleSignIn.currentUser;
      if (account == null) {
        debugPrint('❌ Not signed in, cannot download');
        throw Exception('Not signed in');
      }
      debugPrint('✅ Authenticated as: ${account.email}');

      debugPrint('🔐 Getting auth headers...');
      final authHeaders = await account.authHeaders;
      final client = authenticatedClient(
        http.Client(),
        AccessCredentials(
          AccessToken(
              'Bearer',
              authHeaders['Authorization']?.split(' ')[1] ?? '',
              DateTime.now().toUtc().add(const Duration(hours: 1))),
          null,
          _scopes,
        ),
      );

      final driveApi = drive.DriveApi(client);
      debugPrint('✅ Google Drive API client created');

      // Download event files from other devices
      debugPrint('📁 Ensuring sync folder exists...');
      final syncFolderId = await _ensureFolderExists(
          driveApi, GoogleDriveSyncService.SYNC_FOLDER);
      debugPrint('📁 Sync folder ID: $syncFolderId');
      
      debugPrint('🔍 Looking for event files from other devices...');
      List<drive.File> eventFiles;
      
      // Try file discovery with retry logic for eventual consistency
      int retryCount = 0;
      const maxRetries = 3;
      const retryDelay = Duration(seconds: 2);
      
      while (retryCount < maxRetries) {
        eventFiles = await _getEventFilesFromOtherDevices(driveApi, syncFolderId);
        
        if (eventFiles.isNotEmpty) {
          debugPrint('✅ Found ${eventFiles.length} files on attempt ${retryCount + 1}');
          break;
        }
        
        retryCount++;
        if (retryCount < maxRetries) {
          debugPrint('⏳ No files found on attempt $retryCount/$maxRetries, retrying in ${retryDelay.inSeconds}s...');
          await Future.delayed(retryDelay);
        } else {
          debugPrint('ℹ️ No files found after $maxRetries attempts');
        }
      }

      debugPrint('📋 Found ${eventFiles.length} event files to process');
      int appliedEvents = 0;

      if (eventFiles.isNotEmpty) {
        debugPrint('🔄 Setting status to merging...');
        _statusController.add(SyncStatus.merging);

        for (int i = 0; i < eventFiles.length; i++) {
          final file = eventFiles[i];
          debugPrint('📥 Processing file ${i + 1}/${eventFiles.length}: "${file.name}"');
          
          try {
            final eventBatch = await _downloadAndParseEventBatch(driveApi, file);
            debugPrint('📦 Downloaded event batch with ${eventBatch.events.length} events');
            
            final applied = await _applyEventBatch(eventBatch);
            debugPrint('✅ Applied $applied events from "${file.name}"');
            appliedEvents += applied;

            // Clean up processed event file
            debugPrint('🧹 Cleaning up processed file "${file.name}"');
            await _cleanupProcessedEventFile(driveApi, file);
          } catch (fileError, fileStackTrace) {
            debugPrint('❌ Error processing file "${file.name}": $fileError');
            debugPrint('📍 File error stack trace: $fileStackTrace');
            // Continue with other files even if one fails
          }
        }
      } else {
        debugPrint('ℹ️ No event files found from other devices');
        debugPrint('ℹ️ This could mean:');
        debugPrint('   - No other devices have uploaded events');
        debugPrint('   - Files were already processed and cleaned up');
        debugPrint('   - There is a file discovery issue');
        debugPrint('   - Device ID filtering is too aggressive');
      }

      client.close();
      debugPrint('🔒 Closed Google Drive API client');

      // Update last sync time
      debugPrint('🕒 Updating last sync time...');
      await _updateLastSyncTime(DateTime.now());

      _statusController.add(SyncStatus.completed);
      debugPrint('✅ _syncFromCloudInternal completed successfully');
      debugPrint('📊 Total events applied: $appliedEvents');

      return SyncResult(
        success: true,
        uploadedCount: 0,
        downloadedCount: appliedEvents,
        timestamp: DateTime.now(),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ FATAL ERROR in _syncFromCloudInternal: $e');
      debugPrint('📍 Full stack trace: $stackTrace');
      
      // Check if it's a specific type of error
      if (e.toString().contains('not found') || e.toString().contains('404')) {
        debugPrint('🔍 Folder or file not found error - may be first time sync');
      } else if (e.toString().contains('auth') || e.toString().contains('401')) {
        debugPrint('🔑 Authentication error - may need to re-sign in');
      } else if (e.toString().contains('quota') || e.toString().contains('limit')) {
        debugPrint('⚠️ Rate limit or quota error - should retry later');
      }
      
      _statusController.add(SyncStatus.error);
      return SyncResult(
        success: false,
        error: e.toString(),
        uploadedCount: 0,
        downloadedCount: 0,
        timestamp: DateTime.now(),
      );
    }
    // Note: We don't reset _isSyncing here since it's managed by the parent operation
  }

  Future<String> _getOrCreateDeviceId() async {
    debugPrint('🔧 _getOrCreateDeviceId: Getting or creating device ID...');
    
    try {
      final query = _database.select(_database.syncMetadataTable)
        ..where((t) => t.key.equals('device_id'));
      final result = await query.getSingleOrNull();

      if (result != null) {
        debugPrint('✅ Found existing device ID: ${result.value}');
        debugPrint('🔧 Device ID last updated: ${result.updatedAt}');
        return result.value;
      }

      // Create new device ID
      final deviceId = 'device_${DateTime.now().millisecondsSinceEpoch}';
      debugPrint('🆕 Creating new device ID: $deviceId');
      
      await _database.into(_database.syncMetadataTable).insert(
            SyncMetadataTableCompanion.insert(
              key: 'device_id',
              value: deviceId,
            ),
          );

      debugPrint('✅ New device ID created and saved: $deviceId');
      return deviceId;
    } catch (e, stackTrace) {
      debugPrint('❌ Error in _getOrCreateDeviceId: $e');
      debugPrint('📍 Stack trace: $stackTrace');
      
      // Fallback: create a temporary device ID for this session
      final fallbackId = 'device_temp_${DateTime.now().millisecondsSinceEpoch}';
      debugPrint('🚨 Using fallback device ID: $fallbackId');
      return fallbackId;
    }
  }

  /// Converts legacy timestamp strings that use a space separator (e.g. "2025-07-14 09:35:13")
  /// to proper ISO-8601 strings with a "T" separator so that `DateTime.parse` can read them.
  ///
  /// Older app versions saved `DateTime` values as TEXT in the form `yyyy-MM-dd HH:mm:ss` which
  /// is not accepted by `DateTime.parse`. This leads to a `FormatException` when Drift tries to
  /// hydrate those rows. Running this SQL once at startup fixes the data in-place so normal
  /// queries work again.
  Future<void> _migrateLegacyTimestampFormats() async {
    try {
      debugPrint('🛠️ Running legacy timestamp migration…');

      // First, let's see what we're working with
      debugPrint('🔍 Inspecting current timestamp data...');
      final sampleRows = await _database.customSelect(
        'SELECT event_id, timestamp, typeof(timestamp) as type FROM sync_event_log LIMIT 5'
      ).get();
      
      for (int i = 0; i < sampleRows.length; i++) {
        final row = sampleRows[i];
        debugPrint('🔍 Sample row $i: event_id=${row.data['event_id']}, timestamp="${row.data['timestamp']}", type=${row.data['type']}');
      }

      // Count rows that have TEXT timestamps (should be INTEGER for Drift)
      final textTimestamps = await _database.customSelect(
        "SELECT COUNT(*) AS cnt FROM sync_event_log WHERE typeof(timestamp) = 'text'",
      ).getSingle();
      debugPrint('🕑 Rows with TEXT timestamps: ${textTimestamps.data['cnt']}');

      if (SafeParsing.parseInt(textTimestamps.data['cnt']) > 0) {
        debugPrint('🔧 Converting TEXT timestamps to Unix timestamps...');
        
        // Test the conversion on one row first
        debugPrint('🧪 Testing conversion on first row...');
        final testResult = await _database.customSelect('''
          SELECT 
            timestamp as original,
            CASE
              WHEN timestamp LIKE '%T%' THEN
                CAST((julianday(timestamp) - julianday('1970-01-01 00:00:00')) * 86400 AS INTEGER)
              WHEN timestamp LIKE '% %' THEN
                CAST((julianday(REPLACE(timestamp, ' ', 'T')) - julianday('1970-01-01 00:00:00')) * 86400 AS INTEGER)
              ELSE timestamp
            END as converted
          FROM sync_event_log 
          WHERE typeof(timestamp) = 'text' 
          LIMIT 1
        ''').getSingle();
        
        debugPrint('🧪 Test conversion: "${testResult.data['original']}" -> ${testResult.data['converted']}');
        
        // Convert ISO-8601 strings to Unix timestamps
        debugPrint('🔧 Executing bulk conversion...');
        await _database.customStatement('''
          UPDATE sync_event_log 
          SET timestamp = (
            CASE 
              WHEN typeof(timestamp) = 'text' THEN
                CASE
                  WHEN timestamp LIKE '%T%' THEN
                    -- ISO-8601 format: convert to Unix timestamp
                    CAST((julianday(timestamp) - julianday('1970-01-01 00:00:00')) * 86400 AS INTEGER)
                  WHEN timestamp LIKE '% %' THEN
                    -- Legacy format with space: convert to Unix timestamp  
                    CAST((julianday(REPLACE(timestamp, ' ', 'T')) - julianday('1970-01-01 00:00:00')) * 86400 AS INTEGER)
                  ELSE timestamp
                END
              ELSE timestamp
            END
          )
          WHERE typeof(timestamp) = 'text';
        ''');

        // Verify conversion
        debugPrint('🔍 Verifying conversion results...');
        final afterConversion = await _database.customSelect(
          "SELECT COUNT(*) AS cnt FROM sync_event_log WHERE typeof(timestamp) = 'text'",
        ).getSingle();
        debugPrint('🕑 Rows with TEXT timestamps after conversion: ${afterConversion.data['cnt']}');
        
        // Show some converted data
        final convertedSamples = await _database.customSelect(
          'SELECT event_id, timestamp, typeof(timestamp) as type FROM sync_event_log LIMIT 5'
        ).get();
        
        for (int i = 0; i < convertedSamples.length; i++) {
          final row = convertedSamples[i];
          debugPrint('🔍 Converted row $i: event_id=${row.data['event_id']}, timestamp=${row.data['timestamp']}, type=${row.data['type']}');
        }
      }

      debugPrint('✅ Legacy timestamp migration completed');
    } catch (e, stackTrace) {
      debugPrint('❌ Legacy timestamp migration failed: $e');
      debugPrint('📍 Migration stack trace: $stackTrace');
      
      // If the migration fails, try to delete problematic rows as a last resort
      try {
        debugPrint('🧹 Attempting to clean up problematic rows...');
        final countBefore = await _database.customSelect(
          "SELECT COUNT(*) AS cnt FROM sync_event_log WHERE typeof(timestamp) = 'text'"
        ).getSingle();
        debugPrint('🧹 Rows to delete: ${SafeParsing.parseInt(countBefore.data['cnt'])}');
        
        await _database.customStatement('''
          DELETE FROM sync_event_log WHERE typeof(timestamp) = 'text';
        ''');
        
        final countAfter = await _database.customSelect(
          "SELECT COUNT(*) AS cnt FROM sync_event_log"
        ).getSingle();
        debugPrint('🧹 Total rows remaining after cleanup: ${SafeParsing.parseInt(countAfter.data['cnt'])}');
      } catch (cleanupError, cleanupStackTrace) {
        debugPrint('❌ Cleanup also failed: $cleanupError');
        debugPrint('📍 Cleanup stack trace: $cleanupStackTrace');
      }
    }
  }

  /// Scan the event log and print any timestamps that **still** fail to parse, just before upload.
  Future<void> _detectInvalidTimestamps() async {
    try {
      debugPrint('🔍 Scanning for invalid timestamps in sync_event_log…');
      final rows = await _database.customSelect(
        'SELECT event_id, timestamp FROM sync_event_log',
      ).get();

      for (final row in rows) {
        final ts = row.data['timestamp'];
        if (ts is String) {
          try {
            DateTime.parse(ts);
          } catch (_) {
            debugPrint('❌ Cannot parse timestamp for eventId=${row.data['event_id']} – value="$ts"');
          }
        }
      }
    } catch (e) {
      debugPrint('ℹ️ Timestamp scan failed: $e');
    }
  }

  Future<List<SyncEventLogData>> _getUnsyncedEvents() async {
    try {
      debugPrint('🔍 Querying sync_event_log for unsynced events...');
      
      final query = _database.select(_database.syncEventLogTable)
        ..where((t) => t.isSynced.equals(false))
        ..orderBy([(t) => OrderingTerm.asc(t.sequenceNumber)]);
      
      debugPrint('🔍 Executing database query...');
      final result = await query.get();
      
      debugPrint('🔍 Query returned ${result.length} rows');
      return result;
    } catch (e, stackTrace) {
      debugPrint('❌ ERROR in _getUnsyncedEvents database query: $e');
      debugPrint('📍 Stack trace: $stackTrace');
      
      // Try to get raw data to see what's in the table
      try {
        debugPrint('🔍 Attempting raw query to inspect table contents...');
        final rawRows = await _database.customSelect(
          'SELECT event_id, timestamp, sequence_number FROM sync_event_log WHERE is_synced = 0 LIMIT 5'
        ).get();
        
        for (int i = 0; i < rawRows.length; i++) {
          final row = rawRows[i];
          debugPrint('🔍 Raw row $i: event_id=${row.data['event_id']}, timestamp="${row.data['timestamp']}", sequence_number=${row.data['sequence_number']}');
        }
      } catch (rawError) {
        debugPrint('❌ Raw query also failed: $rawError');
      }
      
      rethrow;
    }
  }

  /// Cache authentication status locally for faster startup
  Future<void> _cacheAuthenticationStatus(bool isSignedIn, String? userEmail) async {
    await _prefs.setBool(_authStatusKey, isSignedIn);
    await _prefs.setString(_userEmailKey, userEmail ?? '');
    await _prefs.setInt(_lastAuthCheckKey, DateTime.now().millisecondsSinceEpoch);
    debugPrint('🔬 Cached auth status: signed-in=$isSignedIn, email=$userEmail');
  }

  /// Get cached authentication status with expiry check
  (bool isSignedIn, String? userEmail)? _getCachedAuthenticationStatus() {
    try {
      final lastCheck = _prefs.getInt(_lastAuthCheckKey) ?? 0;
      final isRecent = DateTime.now().millisecondsSinceEpoch - lastCheck < 300000; // 5 minutes
      
      if (isRecent) {
        final isSignedIn = _prefs.getBool(_authStatusKey) ?? false;
        final userEmail = _prefs.getString(_userEmailKey);
        final email = (userEmail?.isEmpty ?? true) ? null : userEmail;
        debugPrint('🔬 Using cached auth status: signed-in=$isSignedIn, email=$email');
        return (isSignedIn, email);
      }
      
      debugPrint('🔬 Cached auth status expired, will check fresh');
      return null;
    } catch (e) {
      debugPrint('🔬 Error reading cached auth status: $e');
      return null;
    }
  }

  /// Clear cached authentication status
  Future<void> _clearAuthenticationCache() async {
    await _prefs.remove(_authStatusKey);
    await _prefs.remove(_userEmailKey);
    await _prefs.remove(_lastAuthCheckKey);
    debugPrint('🔬 Cleared auth status cache');
  }

  /// Diagnostic method to verify sync system is working
  Future<Map<String, dynamic>> getSyncDiagnostics() async {
    try {
      // Check database triggers exist
      final triggerQuery = await _database.customSelect('''
        SELECT name FROM sqlite_master 
        WHERE type = 'trigger' AND name LIKE '%_sync_event%'
      ''').get();
      
      // Count sync events
      final eventCount = await _database.customSelect('''
        SELECT COUNT(*) as count FROM sync_event_log
      ''').getSingle();
      
      // Count unsynced events
      final unsyncedCount = await _database.customSelect('''
        SELECT COUNT(*) as count FROM sync_event_log WHERE is_synced = false
      ''').getSingle();
      
      // Check authentication status
      final isSignedIn = await this.isSignedIn();
      final userEmail = await getCurrentUserEmail();
      
      final diagnostics = {
        'triggers_found': triggerQuery.length,
        'trigger_names': triggerQuery.map((row) => row.data['name']).toList(),
        'total_sync_events': SafeParsing.parseInt(eventCount.data['count']),
        'unsynced_events': SafeParsing.parseInt(unsyncedCount.data['count']),
        'is_signed_in': isSignedIn,
        'user_email': userEmail,
        'device_id': _deviceId,
        'sync_status': 'functional',
      };
      
      debugPrint('🔬 Sync Diagnostics: $diagnostics');
      return diagnostics;
    } catch (e) {
      debugPrint('❌ Error getting sync diagnostics: $e');
      return {
        'error': e.toString(),
        'sync_status': 'error',
      };
    }
  }

  /// Enhanced diagnostic method for troubleshooting full sync issues
  Future<Map<String, dynamic>> getFullSyncDiagnostics() async {
    try {
      debugPrint('🔬 Running full sync diagnostics...');
      
      final account = _googleSignIn.currentUser;
      final isSignedIn = account != null;
      
      Map<String, dynamic> cloudDiagnostics = {};
      
      if (isSignedIn) {
        try {
          final authHeaders = await account!.authHeaders;
          final client = authenticatedClient(
            http.Client(),
            AccessCredentials(
              AccessToken(
                  'Bearer',
                  authHeaders['Authorization']?.split(' ')[1] ?? '',
                  DateTime.now().toUtc().add(const Duration(hours: 1))),
              null,
              _scopes,
            ),
          );

          final driveApi = drive.DriveApi(client);
          final syncFolderId = await _ensureFolderExists(
              driveApi, GoogleDriveSyncService.SYNC_FOLDER);
          
          // Get all files in sync folder
          final allFiles = await driveApi.files.list(
            q: "'$syncFolderId' in parents and trashed=false",
            fields: 'files(id,name,createdTime,modifiedTime,size)',
          );
          
          // Get event files specifically
          final eventFiles = await driveApi.files.list(
            q: "name contains 'events_' and name contains '.json' and '$syncFolderId' in parents and trashed=false",
            fields: 'files(id,name,createdTime,modifiedTime,size)',
          );
          
          cloudDiagnostics = {
            'cloud_folder_id': syncFolderId,
            'total_files_in_folder': allFiles.files?.length ?? 0,
            'event_files_found': eventFiles.files?.length ?? 0,
            'event_file_names': eventFiles.files?.map((f) => f.name).toList() ?? [],
            'all_file_names': allFiles.files?.map((f) => f.name).toList() ?? [],
          };
          
          client.close();
        } catch (cloudError) {
          cloudDiagnostics = {
            'cloud_error': cloudError.toString(),
          };
        }
      }

      // Check database triggers exist
      final triggerQuery = await _database.customSelect('''
        SELECT name FROM sqlite_master 
        WHERE type = 'trigger' AND name LIKE '%_sync_event%'
      ''').get();
      
      // Count sync events
      final eventCount = await _database.customSelect('''
        SELECT COUNT(*) as count FROM sync_event_log
      ''').getSingle();
      
      // Count unsynced events
      final unsyncedCount = await _database.customSelect('''
        SELECT COUNT(*) as count FROM sync_event_log WHERE is_synced = false
      ''').getSingle();
      
      final diagnostics = {
        // Authentication info
        'is_signed_in': isSignedIn,
        'user_email': account?.email,
        'device_id': _deviceId,
        
        // Local database state
        'triggers_found': triggerQuery.length,
        'trigger_names': triggerQuery.map((row) => row.data['name']).toList(),
        'total_sync_events': SafeParsing.parseInt(eventCount.data['count']),
        'unsynced_events': SafeParsing.parseInt(unsyncedCount.data['count']),
        
        // Cloud state
        ...cloudDiagnostics,
        
        // Sync state
        'is_syncing': _isSyncing,
        'sync_status': 'diagnostic_complete',
        
        // Timestamps
        'diagnostic_timestamp': DateTime.now().toIso8601String(),
      };
      
      debugPrint('🔬 Full sync diagnostics: $diagnostics');
      return diagnostics;
    } catch (e) {
      debugPrint('❌ Error getting full sync diagnostics: $e');
      return {
        'error': e.toString(),
        'sync_status': 'diagnostic_error',
        'diagnostic_timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  Future<String> _ensureFolderExists(
      drive.DriveApi driveApi, String folderPath) async {
    final pathParts = folderPath.split('/');
    String currentParent = 'appDataFolder';

    for (final folderName in pathParts) {
      final existingFolders = await driveApi.files.list(
        q: "name='$folderName' and '$currentParent' in parents and mimeType='application/vnd.google-apps.folder' and trashed=false",
      );

      if (existingFolders.files?.isNotEmpty == true) {
        currentParent = existingFolders.files!.first.id!;
      } else {
        // Create new folder
        final newFolder = await driveApi.files.create(
          drive.File()
            ..name = folderName
            ..mimeType = 'application/vnd.google-apps.folder'
            ..parents = [currentParent],
        );
        currentParent = newFolder.id!;
      }
    }

    return currentParent;
  }

  Future<void> _uploadEventBatch(
    drive.DriveApi driveApi,
    String folderId,
    String fileName,
    SyncEventBatch eventBatch,
  ) async {
    final content = jsonEncode(eventBatch.toJson());
    final bytes = utf8.encode(content);

    await driveApi.files.create(
      drive.File()
        ..name = fileName
        ..parents = [folderId],
      uploadMedia: drive.Media(Stream.value(bytes), bytes.length),
    );
  }

  Future<void> _markEventsAsSynced(List<SyncEventLogData> events) async {
    if (events.isEmpty) return;

    try {
      // ✅ PHASE 4.4: Enhanced batch operation using event IDs for better control
      final eventIds = events.map((e) => e.eventId).toList();
      final placeholders = eventIds.map((_) => '?').join(', ');

      await _database.customStatement(
        'UPDATE sync_event_log SET is_synced = true WHERE event_id IN ($placeholders)',
        eventIds,
      );

      print('✅ PHASE 4.4: Batch marked ${events.length} events as synced');
    } catch (e) {
      // ✅ PHASE 4.4: Enhanced fallback strategy with detailed error handling
      print('Warning: Batch update failed, trying individual updates: $e');

      int successCount = 0;
      for (final event in events) {
        try {
          final rowsAffected =
              await (_database.update(_database.syncEventLogTable)
                    ..where((t) => t.eventId.equals(event.eventId)))
                  .write(const SyncEventLogTableCompanion(
            isSynced: Value(true),
          ));

          if (rowsAffected > 0) {
            successCount++;
          }
        } catch (individualError) {
          print(
              'Failed to mark event ${event.eventId} as synced: $individualError');
        }
      }

      print(
          '✅ PHASE 4.4: Individual fallback completed: $successCount/${events.length} events marked');
    }
  }

  Future<void> _updateSyncState() async {
    try {
      debugPrint('🔄 Updating sync state for device: $_deviceId');
      
      final now = DateTime.now();
      final lastSequence = await _getLastSequenceNumber();
      
      debugPrint('🔄 Last sequence number: $lastSequence');
      
      // Check if device already exists in sync_state
      final existingState = await (_database.select(_database.syncStateTable)
            ..where((tbl) => tbl.deviceId.equals(_deviceId!)))
          .getSingleOrNull();
      
      if (existingState != null) {
        debugPrint('🔄 Updating existing sync state record (id: ${existingState.id})');
        // Update existing record
        await (_database.update(_database.syncStateTable)
              ..where((tbl) => tbl.deviceId.equals(_deviceId!)))
            .write(SyncStateTableCompanion(
          lastSyncTime: Value(now),
          lastSequenceNumber: Value(lastSequence),
          status: const Value('idle'),
        ));
      } else {
        debugPrint('🔄 Creating new sync state record');
        // Insert new record
        await _database.into(_database.syncStateTable).insert(
              SyncStateTableCompanion.insert(
                deviceId: _deviceId!,
                lastSyncTime: now,
                lastSequenceNumber: Value(lastSequence),
                status: const Value('idle'),
              ),
            );
      }
      
      debugPrint('✅ Sync state updated successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ Error updating sync state: $e');
      debugPrint('📍 Sync state stack trace: $stackTrace');
      
      // Try to see what's in the table
      try {
        final allStates = await _database.select(_database.syncStateTable).get();
        debugPrint('🔍 Current sync_state table contents:');
        for (int i = 0; i < allStates.length; i++) {
          final state = allStates[i];
          debugPrint('🔍   Row $i: id=${state.id}, deviceId=${state.deviceId}, lastSyncTime=${state.lastSyncTime}');
        }
      } catch (inspectError) {
        debugPrint('❌ Could not inspect sync_state table: $inspectError');
      }
      
      rethrow;
    }
  }

  Future<int> _getLastSequenceNumber() async {
    final query = _database.select(_database.syncEventLogTable)
      ..where((t) => t.deviceId.equals(_deviceId!))
      ..orderBy([(t) => OrderingTerm.desc(t.sequenceNumber)])
      ..limit(1);

    final result = await query.getSingleOrNull();
    return result?.sequenceNumber ?? 0;
  }

  Future<List<drive.File>> _getEventFilesFromOtherDevices(
    drive.DriveApi driveApi,
    String syncFolderId,
  ) async {
    debugPrint('🔍 _getEventFilesFromOtherDevices: Starting file discovery...');
    debugPrint('🔍 Current device ID: $_deviceId');
    debugPrint('🔍 Sync folder ID: $syncFolderId');
    
    try {
      // First, list ALL files in the sync folder for debugging
      debugPrint('🔍 Listing ALL files in sync folder...');
      final allFiles = await driveApi.files.list(
        q: "'$syncFolderId' in parents and trashed=false",
        fields: 'files(id,name,createdTime,modifiedTime,size)',
      );
      
      debugPrint('🔍 Total files in sync folder: ${allFiles.files?.length ?? 0}');
      if (allFiles.files != null && allFiles.files!.isNotEmpty) {
        for (int i = 0; i < allFiles.files!.length; i++) {
          final file = allFiles.files![i];
          debugPrint('🔍 File $i: "${file.name}" (created: ${file.createdTime}, size: ${file.size})');
        }
      } else {
        debugPrint('🔍 No files found in sync folder at all!');
      }

      // Now search for event files specifically
      debugPrint('🔍 Searching for event files...');
      final eventFiles = await driveApi.files.list(
        q: "name contains 'events_' and name contains '.json' and '$syncFolderId' in parents and trashed=false",
        fields: 'files(id,name,createdTime,modifiedTime,size)',
      );

      debugPrint('🔍 Event files found by query: ${eventFiles.files?.length ?? 0}');
      if (eventFiles.files != null && eventFiles.files!.isNotEmpty) {
        for (int i = 0; i < eventFiles.files!.length; i++) {
          final file = eventFiles.files![i];
          debugPrint('🔍 Event file $i: "${file.name}" (created: ${file.createdTime})');
        }
      }

      // Filter out our own device's files with improved logic
      debugPrint('🔍 Filtering out our own device files...');
      debugPrint('🔍 Current device ID for filtering: $_deviceId');
      debugPrint('🔍 Expected own file prefix: events_$_deviceId');
      
      final filteredFiles = eventFiles.files
              ?.where((file) {
                final fileName = file.name ?? '';
                
                // Multiple checks to be more robust
                final exactMatch = fileName.startsWith('events_$_deviceId');
                final containsDeviceId = fileName.contains(_deviceId!);
                
                debugPrint('🔍 Checking "$fileName":');
                debugPrint('   - exactMatch: $exactMatch');
                debugPrint('   - containsDeviceId: $containsDeviceId');
                
                // Only exclude if it's definitely our file
                final shouldExclude = exactMatch;
                debugPrint('   - shouldExclude: $shouldExclude');
                
                return !shouldExclude;
              })
              .toList() ??
          [];

      debugPrint('🔍 Files after filtering: ${filteredFiles.length}');
      for (int i = 0; i < filteredFiles.length; i++) {
        final file = filteredFiles[i];
        debugPrint('🔍 Filtered file $i: "${file.name}" (created: ${file.createdTime})');
      }
      
      // Additional safety check - if we have no filtered files but had event files, investigate
      if (filteredFiles.isEmpty && (eventFiles.files?.isNotEmpty ?? false)) {
        debugPrint('⚠️ WARNING: Had ${eventFiles.files!.length} event files but 0 after filtering!');
        debugPrint('⚠️ This suggests the device ID filtering may be too aggressive.');
        debugPrint('⚠️ Investigating device ID consistency...');
        
        // Show device ID analysis
        for (final file in eventFiles.files!) {
          final fileName = file.name ?? '';
          debugPrint('⚠️ File "$fileName" vs device "$_deviceId"');
          if (fileName.startsWith('events_')) {
            final parts = fileName.substring(7).split('_'); // Remove "events_" prefix
            if (parts.isNotEmpty) {
              final fileDeviceId = parts[0];
              debugPrint('⚠️   File device ID: "$fileDeviceId"');
              debugPrint('⚠️   Current device ID: "$_deviceId"');
              debugPrint('⚠️   Match: ${fileDeviceId == _deviceId}');
            }
          }
        }
      }

      return filteredFiles;
    } catch (e, stackTrace) {
      debugPrint('❌ Error in _getEventFilesFromOtherDevices: $e');
      debugPrint('📍 Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<SyncEventBatch> _downloadAndParseEventBatch(
    drive.DriveApi driveApi,
    drive.File file,
  ) async {
    final media = await driveApi.files.get(
      file.id!,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;

    final bytes = <int>[];
    await for (final chunk in media.stream) {
      bytes.addAll(chunk);
    }

    final content = utf8.decode(bytes);
    final json = jsonDecode(content);

    return SyncEventBatch.fromJson(json);
  }

  Future<int> _applyEventBatch(SyncEventBatch eventBatch) async {
    int appliedEvents = 0;

    // Group events by record to handle conflicts
    final eventsByRecord = <String, List<SyncEvent>>{};

    for (final event in eventBatch.events) {
      final key = '${event.tableName}:${event.recordId}';
      eventsByRecord.putIfAbsent(key, () => []).add(event);
    }

    // Process each record's events
    for (final entry in eventsByRecord.entries) {
      final events = entry.value;
      events.sort((a, b) => a.sequenceNumber.compareTo(b.sequenceNumber));

      // Check for conflicts
      if (events.length > 1) {
        final resolution = await _conflictResolver.resolveCRDT(events);
        final success =
            await _applyConflictResolution(events.first, resolution);
        if (success) appliedEvents += events.length;
      } else {
        final success = await _applySingleEvent(events.first);
        if (success) appliedEvents++;
      }
    }

    return appliedEvents;
  }

  Future<bool> _applySingleEvent(SyncEvent event) async {
    try {
      switch (event.operation) {
        case 'create':
          return await _handleCreateEvent(event);
        case 'update':
          return await _handleUpdateEvent(event);
        case 'delete':
          return await _handleDeleteEvent(event);
        default:
          return false;
      }
    } catch (e) {
      // Log error but don't fail the entire sync
      print('Failed to apply event ${event.eventId}: $e');
      return false;
    }
  }

  Future<bool> _applyConflictResolution(
      SyncEvent baseEvent, ConflictResolution resolution) async {
    switch (resolution.type) {
      case ConflictResolutionType.merge:
      case ConflictResolutionType.useLatest:
        if (resolution.resolvedData != null) {
          final mergedEvent =
              baseEvent.copyWith(data: resolution.resolvedData!);
          return await _handleUpdateEvent(mergedEvent);
        }
        return false;
      case ConflictResolutionType.useLocal:
        // Keep local version - no action needed
        return true;
      case ConflictResolutionType.manualResolution:
        // Log for manual review
        print(
            'Manual resolution required for ${baseEvent.tableName}:${baseEvent.recordId} - ${resolution.reason}');
        return false;
    }
  }

  Future<bool> _handleCreateEvent(SyncEvent event) async {
    switch (event.tableName) {
      case 'transactions':
        return await _createTransaction(event.data);
      case 'categories':
        return await _createCategory(event.data);
      case 'accounts':
        return await _createAccount(event.data);
      case 'budgets':
        return await _createBudget(event.data);
      case 'attachments':
        return await _createAttachment(event.data);
      default:
        return false;
    }
  }

  Future<bool> _handleUpdateEvent(SyncEvent event) async {
    switch (event.tableName) {
      case 'transactions':
        return await _updateTransaction(event.recordId, event.data);
      case 'categories':
        return await _updateCategory(event.recordId, event.data);
      case 'accounts':
        return await _updateAccount(event.recordId, event.data);
      case 'budgets':
        return await _updateBudget(event.recordId, event.data);
      case 'attachments':
        return await _updateAttachment(event.recordId, event.data);
      default:
        return false;
    }
  }

  Future<bool> _handleDeleteEvent(SyncEvent event) async {
    switch (event.tableName) {
      case 'transactions':
        return await _deleteTransaction(event.recordId);
      case 'categories':
        return await _deleteCategory(event.recordId);
      case 'accounts':
        return await _deleteAccount(event.recordId);
      case 'budgets':
        return await _deleteBudget(event.recordId);
      case 'attachments':
        return await _deleteAttachment(event.recordId);
      default:
        return false;
    }
  }

  // Create operations
  Future<bool> _createTransaction(Map<String, dynamic> data) async {
    try {
      await _database.into(_database.transactionsTable).insert(
            TransactionsTableCompanion.insert(
              title: data['title'],
              note: Value(data['note']),
              amount: data['amount'],
              categoryId: data['categoryId'],
              accountId: data['accountId'],
              date: DateTime.parse(data['date']),
              syncId: data['syncId'],
            ),
            mode: InsertMode.insertOrIgnore,
          );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _createCategory(Map<String, dynamic> data) async {
    try {
      await _database.into(_database.categoriesTable).insert(
            CategoriesTableCompanion.insert(
              name: data['name'],
              icon: data['icon'],
              color: data['color'],
              isExpense: data['isExpense'],
              syncId: data['syncId'],
            ),
            mode: InsertMode.insertOrIgnore,
          );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _createAccount(Map<String, dynamic> data) async {
    try {
      await _database.into(_database.accountsTable).insert(
            AccountsTableCompanion.insert(
              name: data['name'],
              syncId: data['syncId'],
            ),
            mode: InsertMode.insertOrIgnore,
          );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _createBudget(Map<String, dynamic> data) async {
    try {
      await _database.into(_database.budgetsTable).insert(
            BudgetsTableCompanion.insert(
              name: data['name'],
              amount: data['amount'],
              period: data['period'],
              periodAmount: Value(data['periodAmount'] ?? 1),
              startDate: DateTime.parse(data['startDate']),
              endDate: DateTime.parse(data['endDate']),
              syncId: data['syncId'],
            ),
            mode: InsertMode.insertOrIgnore,
          );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _createAttachment(Map<String, dynamic> data) async {
    try {
      await _database.into(_database.attachmentsTable).insert(
            AttachmentsTableCompanion.insert(
              transactionId: data['transactionId'],
              fileName: data['fileName'],
              type: data['type'],
              syncId: data['syncId'],
            ),
            mode: InsertMode.insertOrIgnore,
          );
      return true;
    } catch (e) {
      return false;
    }
  }

  // Update operations
  Future<bool> _updateTransaction(
      String syncId, Map<String, dynamic> data) async {
    try {
      await (_database.update(_database.transactionsTable)
            ..where((t) => t.syncId.equals(syncId)))
          .write(TransactionsTableCompanion(
        title: Value(data['title']),
        note: Value(data['note']),
        amount: Value(data['amount']),
        categoryId: Value(data['categoryId']),
        accountId: Value(data['accountId']),
        date: Value(DateTime.parse(data['date'])),
        updatedAt: Value(DateTime.now()),
      ));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _updateCategory(String syncId, Map<String, dynamic> data) async {
    try {
      await (_database.update(_database.categoriesTable)
            ..where((t) => t.syncId.equals(syncId)))
          .write(CategoriesTableCompanion(
        name: Value(data['name']),
        icon: Value(data['icon']),
        color: Value(data['color']),
        isExpense: Value(data['isExpense']),
        updatedAt: Value(DateTime.now()),
      ));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _updateAccount(String syncId, Map<String, dynamic> data) async {
    try {
      await (_database.update(_database.accountsTable)
            ..where((t) => t.syncId.equals(syncId)))
          .write(AccountsTableCompanion(
        name: Value(data['name']),
        updatedAt: Value(DateTime.now()),
      ));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _updateBudget(String syncId, Map<String, dynamic> data) async {
    try {
      await (_database.update(_database.budgetsTable)
            ..where((t) => t.syncId.equals(syncId)))
          .write(BudgetsTableCompanion(
        name: Value(data['name']),
        amount: Value(data['amount']),
        period: Value(data['period']),
        periodAmount: Value(data['periodAmount'] ?? 1),
        startDate: Value(DateTime.parse(data['startDate'])),
        endDate: Value(DateTime.parse(data['endDate'])),
        updatedAt: Value(DateTime.now()),
      ));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _updateAttachment(
      String syncId, Map<String, dynamic> data) async {
    try {
      await (_database.update(_database.attachmentsTable)
            ..where((t) => t.syncId.equals(syncId)))
          .write(AttachmentsTableCompanion(
        fileName: Value(data['fileName']),
        updatedAt: Value(DateTime.now()),
      ));
      return true;
    } catch (e) {
      return false;
    }
  }

  // Delete operations
  Future<bool> _deleteTransaction(String syncId) async {
    try {
      await (_database.delete(_database.transactionsTable)
            ..where((t) => t.syncId.equals(syncId)))
          .go();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _deleteCategory(String syncId) async {
    try {
      await (_database.delete(_database.categoriesTable)
            ..where((t) => t.syncId.equals(syncId)))
          .go();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _deleteAccount(String syncId) async {
    try {
      await (_database.delete(_database.accountsTable)
            ..where((t) => t.syncId.equals(syncId)))
          .go();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _deleteBudget(String syncId) async {
    try {
      await (_database.delete(_database.budgetsTable)
            ..where((t) => t.syncId.equals(syncId)))
          .go();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _deleteAttachment(String syncId) async {
    try {
      await (_database.delete(_database.attachmentsTable)
            ..where((t) => t.syncId.equals(syncId)))
          .go();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _cleanupProcessedEventFile(
      drive.DriveApi driveApi, drive.File file) async {
    try {
      // Move to trash instead of permanent deletion
      await driveApi.files.update(
        drive.File()..trashed = true,
        file.id!,
      );
    } catch (e) {
      // Non-critical - log but don't fail sync
      print('Failed to cleanup event file ${file.name}: $e');
    }
  }

  Future<void> _updateLastSyncTime(DateTime time) async {
    try {
      debugPrint('🕒 Updating last sync time to: ${time.toIso8601String()}');
      
      // Check if 'last_sync_time' key already exists
      final existing = await (_database.select(_database.syncMetadataTable)
            ..where((tbl) => tbl.key.equals('last_sync_time')))
          .getSingleOrNull();
      
      if (existing != null) {
        debugPrint('🕒 Updating existing last_sync_time record (id: ${existing.id})');
        // Update existing record
        await (_database.update(_database.syncMetadataTable)
              ..where((tbl) => tbl.key.equals('last_sync_time')))
            .write(SyncMetadataTableCompanion(
          value: Value(time.toIso8601String()),
          updatedAt: Value(DateTime.now()),
        ));
      } else {
        debugPrint('🕒 Creating new last_sync_time record');
        // Insert new record
        await _database.into(_database.syncMetadataTable).insert(
              SyncMetadataTableCompanion.insert(
                key: 'last_sync_time',
                value: time.toIso8601String(),
              ),
            );
      }
      
      debugPrint('✅ Last sync time updated successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ Error updating last sync time: $e');
      debugPrint('📍 Last sync time stack trace: $stackTrace');
      
      // Try to see what's in the sync_metadata table
      try {
        final allMetadata = await _database.select(_database.syncMetadataTable).get();
        debugPrint('🔍 Current sync_metadata table contents:');
        for (int i = 0; i < allMetadata.length; i++) {
          final meta = allMetadata[i];
          debugPrint('🔍   Row $i: id=${meta.id}, key=${meta.key}, value=${meta.value}');
        }
      } catch (inspectError) {
        debugPrint('❌ Could not inspect sync_metadata table: $inspectError');
      }
      
      rethrow;
    }
  }
}
