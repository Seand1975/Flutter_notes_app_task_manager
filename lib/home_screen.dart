import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';
import 'models/task_item.dart';
import 'form_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _isDarkMode = prefs.getBool('isDarkMode') ?? false;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading theme preference: $e');
      setState(() {
        _isDarkMode = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveThemePreference(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', value);
    } catch (e) {
      print('Error saving theme preference: $e');
    }
  }

  void _toggleTheme(bool value) {
    setState(() {
      _isDarkMode = value;
    });
    _saveThemePreference(value);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Tasks & Notes',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[900],
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: TasksNotesScreen(
        isDarkMode: _isDarkMode,
        onThemeToggle: _toggleTheme,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TasksNotesScreen extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeToggle;

  TasksNotesScreen({
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<TasksNotesScreen> createState() => _TasksNotesScreenState();
}

class _TasksNotesScreenState extends State<TasksNotesScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<TaskItem> tasks = [];
  bool _isLoadingTasks = true;

  @override
  void initState() {
    super.initState();
    _loadTasksFromDatabase();
  }

  Future<void> _loadTasksFromDatabase() async {
    setState(() {
      _isLoadingTasks = true;
    });
    try {
      final fetchedTasks = await _dbHelper.getAllTaskItems();
      setState(() {
        tasks = fetchedTasks;
      });
    } catch (e) {
      print('Error loading tasks: $e');
      // optionally show error UI/snackbar
    } finally {
      setState(() {
        _isLoadingTasks = false;
      });
    }
  }

  void _addNewTask(TaskItem newTask) {
    setState(() {
      tasks.insert(0, newTask);
    });
  }

  void _updateTaskInState(TaskItem updatedTask) {
    setState(() {
      final index = tasks.indexWhere((task) => task.id == updatedTask.id);
      if (index != -1) {
        tasks[index] = updatedTask;
      }
    });
  }

  void _deleteTaskInState(String taskId) {
    setState(() {
      tasks.removeWhere((task) => task.id == taskId);
    });
  }

  void _showTaskOptionsDialog(TaskItem task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Task Options'),
          content: Text('What would you like to do with "${task.title}"?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton.icon(
              icon: Icon(Icons.edit, color: Colors.blue),
              label: Text('Edit'),
              onPressed: () {
                Navigator.pop(context); // Close dialog
                _navigateToEditTaskForm(task);
              },
            ),
            TextButton.icon(
              icon: Icon(Icons.delete, color: Colors.red),
              label: Text('Delete'),
              onPressed: () {
                Navigator.pop(context); // Close dialog
                _confirmDeleteTask(task);
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteTask(TaskItem task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Task'),
          content: Text('Are you sure you want to delete "${task.title}"?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await _dbHelper.deleteTaskItem(task.id);
                  _deleteTaskInState(task.id);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Task "${task.title}" deleted'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                } catch (e) {
                  print('Error deleting task: $e');
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToAddTaskForm() async {
    final result = await Navigator.push<TaskItem?>(
      context,
      MaterialPageRoute(
        builder: (context) => AddTaskFormScreen(),
      ),
    );

    if (result != null) {
      // Task was inserted by the AddTaskFormScreen into DB and returned
      _addNewTask(result);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task "${result.title}" added successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _navigateToEditTaskForm(TaskItem task) async {
    final result = await Navigator.push<TaskItem?>(
      context,
      MaterialPageRoute(
        builder: (context) => AddTaskFormScreen(taskToEdit: task),
      ),
    );

    if (result != null) {
      // Task was updated in DB and returned
      _updateTaskInState(result);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task "${result.title}" updated successfully!'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks & Notes'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome message section
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'My Tasks and Notes',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // Theme toggle switch
          Card(
            margin: EdgeInsets.all(16),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile(
              title: Text(
                'Dark Theme',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                isDark ? 'Dark mode enabled' : 'Light mode enabled',
                style: TextStyle(fontSize: 14),
              ),
              value: widget.isDarkMode,
              onChanged: widget.onThemeToggle,
              secondary: Icon(
                isDark ? Icons.dark_mode : Icons.light_mode,
                color: theme.colorScheme.primary,
              ),
            ),
          ),

          // Tasks count
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${tasks.length} Tasks',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 8),

          // ListView section
          Expanded(
            child: _isLoadingTasks
                ? Center(child: CircularProgressIndicator())
                : tasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.task_alt,
                              size: 80,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No tasks yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tap + to add a new task',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return Card(
                            elevation: 2,
                            margin: EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(16),
                              onTap: () => _showTaskOptionsDialog(task),
                              leading: CircleAvatar(
                                backgroundColor: task.isCompleted
                                    ? Colors.green
                                    : _getPriorityColor(task.priority),
                                child: Icon(
                                  task.isCompleted ? Icons.check : Icons.note,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                task.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  decoration: task.isCompleted
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                ),
                              ),
                              subtitle: Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      task.description,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Priority: ${task.priority}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: _getPriorityColor(task.priority),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: isDark ? Colors.grey[600] : Colors.grey[400],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTaskForm,
        backgroundColor: theme.colorScheme.primary,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

