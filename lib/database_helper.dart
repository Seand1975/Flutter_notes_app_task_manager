import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
// import 'models/task_item.dart'; // Import your TaskItem model

// TaskItem model (normally in separate file - models/task_item.dart)
class TaskItem {
  final String id;
  final String title;
  final String priority;
  final String description;
  final bool isCompleted;

  TaskItem({
    required this.id,
    required this.title,
    required this.priority,
    required this.description,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'priority': priority,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0, // SQLite uses 0 and 1 for boolean
    };
  }

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: json['id'] as String,
      title: json['title'] as String,
      priority: json['priority'] as String,
      description: json['description'] as String,
      isCompleted: json['isCompleted'] == 1, // Convert 1 to true, 0 to false
    );
  }

  TaskItem copyWith({
    String? id,
    String? title,
    String? priority,
    String? description,
    bool? isCompleted,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      priority: priority ?? this.priority,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class DatabaseHelper {
  // Singleton pattern
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  // Database configuration
  static const String _databaseName = 'tasks_database.db';
  static const int _databaseVersion = 1;
  static const String tableTaskItems = 'task_items';

  // Column names
  static const String columnId = 'id';
  static const String columnTitle = 'title';
  static const String columnPriority = 'priority';
  static const String columnDescription = 'description';
  static const String columnIsCompleted = 'isCompleted';

  // Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDatabase() async {
    try {
      // Get the database path
      String path = join(await getDatabasesPath(), _databaseName);
      
      print('Database path: $path');

      // Open/create the database
      return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    }
  }

  // Create the database table
  Future<void> _onCreate(Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE $tableTaskItems (
          $columnId TEXT PRIMARY KEY,
          $columnTitle TEXT NOT NULL,
          $columnPriority TEXT NOT NULL,
          $columnDescription TEXT NOT NULL,
          $columnIsCompleted INTEGER NOT NULL DEFAULT 0
        )
      ''');
      print('Table $tableTaskItems created successfully');
    } catch (e) {
      print('Error creating table: $e');
      rethrow;
    }
  }

  // Handle database upgrades (for future versions)
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database schema upgrades here when needed
    print('Upgrading database from version $oldVersion to $newVersion');
  }

  // Insert a new TaskItem
  Future<int> insertTaskItem(TaskItem task) async {
    try {
      final db = await database;
      int result = await db.insert(
        tableTaskItems,
        task.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Task inserted successfully: ${task.title}');
      return result;
    } catch (e) {
      print('Error inserting task: $e');
      rethrow;
    }
  }

  // Retrieve all TaskItems
  Future<List<TaskItem>> getAllTaskItems() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableTaskItems,
        orderBy: '$columnIsCompleted ASC, $columnId DESC',
      );

      print('Retrieved ${maps.length} tasks from database');

      // Convert the List<Map<String, dynamic>> into a List<TaskItem>
      return List.generate(maps.length, (i) {
        return TaskItem.fromJson(maps[i]);
      });
    } catch (e) {
      print('Error retrieving tasks: $e');
      rethrow;
    }
  }

  // Update a TaskItem
  Future<int> updateTaskItem(TaskItem task) async {
    try {
      final db = await database;
      int result = await db.update(
        tableTaskItems,
        task.toJson(),
        where: '$columnId = ?',
        whereArgs: [task.id],
      );
      print('Task updated successfully: ${task.title}');
      return result;
    } catch (e) {
      print('Error updating task: $e');
      rethrow;
    }
  }

  // Delete a TaskItem
  Future<int> deleteTaskItem(String id) async {
    try {
      final db = await database;
      int result = await db.delete(
        tableTaskItems,
        where: '$columnId = ?',
        whereArgs: [id],
      );
      print('Task deleted successfully: $id');
      return result;
    } catch (e) {
      print('Error deleting task: $e');
      rethrow;
    }
  }

  // Delete all TaskItems
  Future<int> deleteAllTaskItems() async {
    try {
      final db = await database;
      int result = await db.delete(tableTaskItems);
      print('All tasks deleted successfully');
      return result;
    } catch (e) {
      print('Error deleting all tasks: $e');
      rethrow;
    }
  }

  // Get a single TaskItem by ID
  Future<TaskItem?> getTaskItemById(String id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableTaskItems,
        where: '$columnId = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isEmpty) {
        return null;
      }

      return TaskItem.fromJson(maps.first);
    } catch (e) {
      print('Error retrieving task by id: $e');
      rethrow;
    }
  }

  // Get tasks by completion status
  Future<List<TaskItem>> getTasksByCompletionStatus(bool isCompleted) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableTaskItems,
        where: '$columnIsCompleted = ?',
        whereArgs: [isCompleted ? 1 : 0],
        orderBy: '$columnId DESC',
      );

      return List.generate(maps.length, (i) {
        return TaskItem.fromJson(maps[i]);
      });
    } catch (e) {
      print('Error retrieving tasks by completion status: $e');
      rethrow;
    }
  }

  // Close the database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}