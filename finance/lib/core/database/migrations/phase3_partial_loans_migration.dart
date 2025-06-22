import '../app_database.dart';

/// Phase 3: Partial Loan Payments Migration
/// Adds remainingAmount and parentTransactionId fields to support partial loan collection/settlement
class Phase3PartialLoansMigration {
  final AppDatabase _database;

  Phase3PartialLoansMigration(this._database);

  /// Execute the Phase 3 migration (schema version 8 → 9)
  Future<void> executePhase3Migration() async {
    print('🏦 Starting Phase 3: Partial Loan Payments Migration...');

    try {
      // Add the new columns to transactions table
      await _addPartialLoanFields();

      // Initialize existing loan transactions
      await _initializeExistingLoans();

      // Update schema version
      await _updateSchemaVersion();

      print('✅ Phase 3 migration completed successfully!');
    } catch (e) {
      print('❌ Phase 3 migration failed: $e');
      rethrow;
    }
  }

  /// Add remainingAmount and parentTransactionId columns to transactions table
  Future<void> _addPartialLoanFields() async {
    print('🔧 Adding partial loan payment fields...');

    // Check if columns already exist
    final tableInfo =
        await _database.customSelect("PRAGMA table_info(transactions)").get();
    final columnNames =
        tableInfo.map((row) => row.data['name'] as String).toList();

    // Add remainingAmount column if it doesn't exist
    if (!columnNames.contains('remaining_amount')) {
      await _database.customStatement('''
        ALTER TABLE transactions 
        ADD COLUMN remaining_amount REAL
      ''');
      print('✅ remaining_amount column added');
    } else {
      print('ℹ️ remaining_amount column already exists');
    }

    // Add parentTransactionId column if it doesn't exist
    if (!columnNames.contains('parent_transaction_id')) {
      await _database.customStatement('''
        ALTER TABLE transactions 
        ADD COLUMN parent_transaction_id INTEGER 
        REFERENCES transactions(id)
      ''');
      print('✅ parent_transaction_id column added');
    } else {
      print('ℹ️ parent_transaction_id column already exists');
    }

    print('✅ Partial loan fields verified');
  }

  /// Initialize existing loan transactions with remainingAmount
  Future<void> _initializeExistingLoans() async {
    print('🔧 Initializing existing loan transactions...');

    // Set remainingAmount = abs(amount) for existing credit/debt transactions
    await _database.customStatement('''
      UPDATE transactions 
      SET remaining_amount = ABS(amount) 
      WHERE special_type IN ('credit', 'debt') 
      AND remaining_amount IS NULL
    ''');

    // Set loan transactions that are not fully paid to actionRequired state
    await _database.customStatement('''
      UPDATE transactions 
      SET transaction_state = 'actionRequired'
      WHERE special_type IN ('credit', 'debt') 
      AND paid = FALSE
      AND transaction_state = 'completed'
    ''');

    print('✅ Existing loan transactions initialized');
  }

  /// Update schema version to 9
  Future<void> _updateSchemaVersion() async {
    // This would typically be handled by Drift's migration system
    // For now, we'll add a simple version tracking
    await _database.customStatement('''
      CREATE TABLE IF NOT EXISTS schema_version (
        version INTEGER PRIMARY KEY
      )
    ''');

    await _database.customStatement('''
      INSERT OR REPLACE INTO schema_version (version) VALUES (9)
    ''');

    print('✅ Schema version updated to 9');
  }
}
