import 'package:drift/drift.dart';
import 'transactions_table.dart';

class AttachmentsTable extends Table {
  @override
  String get tableName => 'attachments';

  IntColumn get id => integer().autoIncrement()();

  IntColumn get transactionId => integer().references(TransactionsTable, #id)();
  TextColumn get fileName => text().withLength(min: 1, max: 255)();
  TextColumn get filePath => text().nullable()(); // Local file path
  TextColumn get googleDriveFileId =>
      text().nullable()(); // Google Drive file ID
  TextColumn get googleDriveLink =>
      text().nullable()(); // Google Drive shareable link
  IntColumn get type => integer()(); // AttachmentType enum as int
  TextColumn get mimeType => text().nullable()();
  IntColumn get fileSizeBytes => integer().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  BoolColumn get isUploaded => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  // Caching fields for local file management
  BoolColumn get isCapturedFromCamera => boolean().withDefault(
      const Constant(false))(); // Only cache camera-captured images
  DateTimeColumn get localCacheExpiry => dateTime()
      .nullable()(); // When local cache should expire (30 days for camera images)

  // ✅ PHASE 4: Only essential sync field (event sourcing handles the rest)
  TextColumn get syncId => text().unique()(); // UUID for global uniqueness
}
