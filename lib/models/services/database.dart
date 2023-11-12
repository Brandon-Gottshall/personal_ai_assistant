import 'package:postgres/postgres.dart';
import 'logger.dart';

class DatabaseService {
  static final DatabaseService _singleton = DatabaseService._internal();
  static late PostgreSQLConnection _connection;

  factory DatabaseService() {
    return _singleton;
  }

  DatabaseService._internal();

  Future initialize() async {
    await connect(
      databaseName: 'my_ai_assistant',
      username: 'postgres',
      password: 'password',
    );
    await createDatabase('my_ai_assistant');
    await createThreadsTable();
  }

  Future<void> connect({
    String host = 'localhost',
    int port = 5432,
    required String databaseName,
    required String username,
    required String password,
  }) async {
    _connection = PostgreSQLConnection(
      host,
      port,
      databaseName,
      username: username,
      password: password,
    );
    try {
      await _connection.open();
    } catch (e) {
      LoggerService.log('An error occurred while connecting to the database: $e'); 
    }
  }

  Future<List<List<dynamic>>> query(String sql, [Map<String, dynamic>? values]) async {
    try {
      return await _connection.query(sql, substitutionValues: values);
    } catch (e) {
      print('An error occurred while executing the query: $e');
      return [];
    }
  }

  Future<void> close() async {
    await _connection.close();
  }

  // Check if database exists (create if not)
  Future<void> createDatabase(String databaseName) async {
    await _connection.query('CREATE DATABASE IF NOT EXISTS $databaseName');
  }

  // Check if thread table exists (create if not)
  Future<void> createThreadsTable() async {
    await _connection.query('''
      CREATE TABLE IF NOT EXISTS threads (
        id SERIAL PRIMARY KEY,
        thread_id VARCHAR(255) NOT NULL,
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  // Insert a new threadID into the threads table
  Future<int> insertThreadID(String threadId) async {
    final results = await _connection.query('''
      INSERT INTO threads VALUES @threadId
    ''', substitutionValues: {
      'threadId': threadId
    });
    return results[0][0] as int;
  }

  // Get all threadIDs from the threads table
  Future<List<List<dynamic>>> getThreadIDs() async {
    final results = await _connection.query('''
      SELECT thread_id FROM threads
    ''');
    return results;
  }

}
