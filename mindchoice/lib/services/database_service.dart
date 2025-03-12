import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/blocked_app.dart';
import '../models/health_reminder.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mindchoice.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE blocked_apps (
        packageName TEXT PRIMARY KEY,
        appName TEXT NOT NULL,
        isBlocked INTEGER NOT NULL,
        timeLimit INTEGER NOT NULL,
        blockSchedules TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE health_reminders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        type TEXT NOT NULL,
        intervalMinutes INTEGER NOT NULL,
        isEnabled INTEGER NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT NOT NULL
      )
    ''');
  }

  // Blocked Apps CRUD operations
  Future<void> insertBlockedApp(BlockedApp app) async {
    final db = await database;
    await db.insert(
      'blocked_apps',
      app.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<BlockedApp>> getBlockedApps() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('blocked_apps');
    return List.generate(maps.length, (i) => BlockedApp.fromMap(maps[i]));
  }

  Future<void> updateBlockedApp(BlockedApp app) async {
    final db = await database;
    await db.update(
      'blocked_apps',
      app.toMap(),
      where: 'packageName = ?',
      whereArgs: [app.packageName],
    );
  }

  Future<void> deleteBlockedApp(String packageName) async {
    final db = await database;
    await db.delete(
      'blocked_apps',
      where: 'packageName = ?',
      whereArgs: [packageName],
    );
  }

  // Health Reminders CRUD operations
  Future<void> insertHealthReminder(HealthReminder reminder) async {
    final db = await database;
    await db.insert(
      'health_reminders',
      reminder.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<HealthReminder>> getHealthReminders() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('health_reminders');
    return List.generate(maps.length, (i) => HealthReminder.fromMap(maps[i]));
  }

  Future<void> updateHealthReminder(HealthReminder reminder) async {
    final db = await database;
    await db.update(
      'health_reminders',
      reminder.toMap(),
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
  }

  Future<void> deleteHealthReminder(int id) async {
    final db = await database;
    await db.delete(
      'health_reminders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
} 