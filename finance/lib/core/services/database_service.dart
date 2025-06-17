import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import '../database/app_database.dart';

class DatabaseService {
  late final AppDatabase _database;
  
  DatabaseService() {
    _database = AppDatabase();
  }
  
  // Constructor for testing with in-memory database
  DatabaseService.forTesting() {
    _database = AppDatabase.forTesting(NativeDatabase.memory());
  }
  
  AppDatabase get database => _database;
  
  Future<void> close() async {
    await _database.close();
  }
}
