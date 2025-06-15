import '../database/app_database.dart';

class DatabaseService {
  late final AppDatabase _database;
  
  DatabaseService() {
    _database = AppDatabase();
  }
  
  AppDatabase get database => _database;
  
  Future<void> close() async {
    await _database.close();
  }
}
