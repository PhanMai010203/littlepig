# Attachment Caching System

## Implementation Status: ✅ COMPLETE

This document describes the efficient attachment caching system implemented for the finance app. The system intelligently caches images captured from the camera locally for 30 days while excluding gallery images and documents from local caching. All attachments are uploaded to Google Drive for cloud storage.

## System Architecture

### Core Components

1. **Database Layer (`AttachmentsTable`)**
   - ✅ Added `isCapturedFromCamera` (boolean) - identifies camera-captured images
   - ✅ Added `localCacheExpiry` (DateTime?) - tracks cache expiration for camera images
   - ✅ Database migration implemented (version 2)

2. **Domain Layer (`Attachment` entity)**
   - ✅ Updated entity with new cache fields
   - ✅ Added helper getters: `isLocalCacheExpired`, `shouldUseLocalCache`
   - ✅ Enhanced `copyWith` method for cache management

3. **Repository Layer (`AttachmentRepository`)**
   - ✅ Extended interface with cache management methods
   - ✅ Implemented cache cleanup functionality
   - ✅ Added smart file path resolution (local → Google Drive → error)

4. **Service Layer**
   - ✅ **FilePickerService**: Enhanced with camera detection and view path resolution
   - ✅ **CacheManagementService**: New service for periodic cache cleanup
   - ✅ **GoogleDriveSyncService**: Updated to sync attachment metadata

### Caching Logic

#### Camera Images (Cached)
- Images captured using the app's camera are cached locally for 30 days
- Cache expiry is automatically set upon capture
- Files are compressed and stored in the app's private directory
- After 30 days, local files are automatically cleaned up

#### Gallery/Document Files (Not Cached)
- Gallery images and documents are uploaded directly to Google Drive
- No local cache expiry is set (`localCacheExpiry = null`)
- Only metadata is stored locally

#### File Access Priority
1. **Local Cache** (if available and not expired)
2. **Google Drive** (download if needed)
3. **Error Handling** (if neither source is available)

## Key Features

### ✅ Implemented Features

1. **Intelligent Caching**
   - Camera images: 30-day local cache
   - Gallery/documents: Direct cloud storage
   - Automatic cache expiry management

2. **Storage Optimization**
   - Image compression for camera captures
   - Selective caching to save storage space
   - Automatic cleanup of expired cache

3. **Seamless Access**
   - Transparent file access (local → cloud)
   - Fallback mechanisms for offline access
   - Error handling for missing files

4. **Google Drive Integration**
   - Automatic upload to Google Drive
   - Metadata synchronization
   - Conflict resolution during sync

5. **Cache Management**
   - Manual cache cleanup methods
   - Periodic background cleanup
   - Cache statistics and monitoring

## Usage

### For Developers

#### Adding Attachments
```dart
// Camera image (will be cached)
final attachment = await filePickerService.compressAndStoreFile(
  file, 
  isCapturedFromCamera: true  // This enables 30-day caching
);

// Gallery image (direct to cloud)
final attachment = await filePickerService.compressAndStoreFile(
  file, 
  isCapturedFromCamera: false  // No local caching
);
```

#### Accessing Attachments
```dart
// Get the best available path (local or Google Drive)
final filePath = await filePickerService.getAttachmentViewPath(attachmentId);
if (filePath != null) {
  // Display the file
  displayFile(filePath);
} else {
  // Handle error - file not available
  showErrorMessage();
}
```

#### Cache Management
```dart
// Manual cache cleanup
await filePickerService.cleanExpiredCache();

// Using CacheManagementService
final cacheService = getIt<CacheManagementService>();
await cacheService.cleanExpiredCache();
final stats = await cacheService.getCacheStats();
```

### For Users

The caching system works transparently in the background:

1. **Taking Photos**: Images are automatically cached for 30 days for quick access
2. **Importing Files**: Gallery images and documents go directly to cloud storage
3. **Viewing Attachments**: The app automatically shows the best available version
4. **Storage Management**: Old cache files are automatically removed after 30 days

## Database Schema

### AttachmentsTable (Version 2)
```dart
class AttachmentsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get fileName => text()();
  TextColumn get filePath => text()();
  TextColumn get mimeType => text()();
  IntColumn get fileSize => integer()();
  DateTimeColumn get uploadDate => dateTime()();
  TextColumn get syncId => text().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  
  // New caching fields
  BoolColumn get isCapturedFromCamera => boolean().withDefault(const Constant(false))();
  DateTimeColumn get localCacheExpiry => dateTime().nullable()();
}
```

## Migration Guide

### From Previous Version

The system automatically migrates existing attachments:
- All existing attachments are marked as `isCapturedFromCamera = false`
- No cache expiry is set for existing files
- Google Drive sync continues to work with existing attachments

### Database Migration
```dart
// Migration is handled automatically in AppDatabase.onUpgrade
// Version 1 → Version 2 adds the new caching fields
```

## Google Drive Sync

### What Gets Synced
- ✅ Attachment metadata (filename, size, upload date, etc.)
- ✅ File content (uploaded to Google Drive)
- ❌ Local file paths (not synced - device-specific)
- ❌ Cache expiry dates (not synced - local cache management)

### Sync Behavior
- Files are uploaded to Google Drive upon creation
- Metadata is synchronized during periodic sync
- Local cache settings are preserved per device
- Conflicts are resolved by merging metadata

## Performance Considerations

### Storage Savings
- Camera images: Compressed and cached locally for 30 days
- Gallery/documents: Direct cloud storage (no local storage used)
- Automatic cleanup prevents cache bloat

### Network Usage
- Camera images: Local access for 30 days (no network needed)
- Gallery/documents: Downloaded from cloud when needed
- Smart caching reduces repeated downloads

### Memory Management
- Files are compressed before caching
- Automatic cleanup of expired cache
- Efficient file access patterns

## Error Handling

### File Access Errors
- **Local file missing**: Automatically try Google Drive
- **Google Drive error**: Show appropriate error message
- **Network unavailable**: Use cached version if available

### Cache Management Errors
- Failed cleanup operations are logged
- Partial cleanup is acceptable
- User can manually retry cleanup

## Testing

### Unit Tests
- ✅ Cache logic validation
- ✅ File access priority testing
- ✅ Migration testing

### Integration Tests
- ✅ End-to-end attachment flow
- ✅ Google Drive sync testing
- ✅ Cache cleanup verification

## Next Steps

### 🔄 Pending Tasks

1. **UI Integration**
   - Update attachment display widgets to use `getAttachmentViewPath`
   - Add cache management UI in settings
   - Show cache statistics to users

2. **Background Services** *(Completed in v2.1)*
   - Periodic cache cleanup scheduler implemented via `CacheManagementService.startPeriodicCleanup()` (internally registered with `TimerManagementService`)
   - Cache cleanup now registered during app initialization
   - `CacheStats` monitoring available through `cacheService.getCacheStats()`

3. **Advanced Features**
   - Configurable cache duration (currently fixed at 30 days)
   - Cache size limits and LRU eviction
   - Offline-first attachment access

4. **Code Quality**
   - Address remaining lint warnings (print statements, const constructors)
   - Add more comprehensive error handling
   - Implement proper logging framework

5. **Testing**
   - Add comprehensive integration tests
   - Test cache behavior under various scenarios
   - Performance testing with large attachment sets

### 📋 Configuration Options

Currently the system has these configurable aspects:
- Cache duration: 30 days (hardcoded in `AttachmentRepositoryImpl.compressAndStoreFile`)
- Compression quality: Configurable in compression logic
- Cache directory: App's private documents directory

## Troubleshooting

### Common Issues

1. **Attachments not displaying**
   - Check if Google Drive sync is working
   - Verify internet connection
   - Check file permissions

2. **Cache not cleaning up**
   - Manually call `cleanExpiredCache()`
   - Check available storage space
   - Verify cache expiry dates

3. **Sync conflicts**
   - Google Drive sync merges metadata by `syncId`
   - Local cache settings are preserved
   - Re-sync usually resolves conflicts

## Development Notes

### Code Generation
After database schema changes, run:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Static Analysis
Current status: ✅ No critical errors
- Only minor lint warnings remain (print statements, const constructors)
- All core functionality is working

### Dependencies
- `drift`: Database ORM
- `google_sign_in`: Google authentication
- `googleapis`: Google Drive API
- `path_provider`: File system access
- `flutter_image_compress`: Image compression

---

*Last updated: January 2025*
*Implementation status: ✅ Complete - Ready for UI integration and testing*
