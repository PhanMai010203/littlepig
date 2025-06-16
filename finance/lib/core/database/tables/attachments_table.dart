import 'package:drift/drift.dart';
import 'transactions_table.dart';

class AttachmentsTable extends Table {
  @override
  String get tableName => 'attachments';

  IntColumn get id => integer().autoIncrement()();
  
  IntColumn get transactionId => integer().references(TransactionsTable, #id)();
  TextColumn get fileName => text().withLength(min: 1, max: 255)();
  TextColumn get filePath => text().nullable()(); // Local file path
  TextColumn get googleDriveFileId => text().nullable()(); // Google Drive file ID
  TextColumn get googleDriveLink => text().nullable()(); // Google Drive shareable link
  IntColumn get type => integer()(); // AttachmentType enum as int
  TextColumn get mimeType => text().nullable()();
  IntColumn get fileSizeBytes => integer().nullable()();
  
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  
  BoolColumn get isUploaded => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  
  // Sync fields
  TextColumn get deviceId => text().withLength(min: 1, max: 50)();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();
  
  // For conflict resolution
  TextColumn get syncId => text().unique()(); // UUID for global uniqueness
  IntColumn get version => integer().withDefault(const Constant(1))();
} 