import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import this in your project:
// import 'models/task_item.dart';

// TaskItem model class (normally in separate file)
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
      'isCompleted': isCompleted,
    };
  }

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: json['id'] as String,
      title: json['title'] as String,
      priority: json['priority'] as String,
      description: json['description'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
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

  // Load theme preference from SharedPreferences
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _isDarkMode = prefs.getBool('isDarkMode') ?? false;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading theme preference: $e');
      // Fallback to default theme if there's an error
      setState(() {
        _isDarkMode = false;
        _isLoading = false;
      });
    }
  }

  // Save theme preference to SharedPreferences
  Future<void> _saveThemePreference(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', value);
    } catch (e) {
      print('Error saving theme preference: $e');
      // Show error to user if needed
      // You can add a SnackBar here to inform the user
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

class TasksNotesScreen extends StatelessWidget {
  final bool isDarkMode;
  final Function(bool) onThemeToggle;

  TasksNotesScreen({
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  // Hardcoded sample tasks using TaskItem model
  final List<TaskItem> tasks = [
    TaskItem(
      id: '1',
      title: 'Complete Flutter project',
      priority: 'High',
      description: 'Finish building the tasks and notes app',
      isCompleted: false,
    ),
    TaskItem(
      id: '2',
      title: 'Buy groceries',
      priority: 'Medium',
      description: 'Milk, eggs, bread, and vegetables',
      isCompleted: false,
    ),
    TaskItem(
      id: '3',
      title: 'Schedule dentist appointment',
      priority: 'Low',
      description: 'Call the clinic before 5 PM',
      isCompleted: true,
    ),
  ];

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
              value: isDarkMode,
              onChanged: onThemeToggle,
              secondary: Icon(
                isDark ? Icons.dark_mode : Icons.light_mode,
                color: theme.colorScheme.primary,
              ),
            ),
          ),

          // ListView section
          Expanded(
            child: ListView.builder(
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
        onPressed: () {
          // Add new task functionality
        },
        backgroundColor: theme.colorScheme.primary,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Helper method to get color based on priority
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

/*
 * SETUP INSTRUCTIONS:
 * 
 * 1. Add shared_preferences to pubspec.yaml:
 *    dependencies:
 *      flutter:
 *        sdk: flutter
 *      shared_preferences: ^2.2.2
 * 
 * 2. Run: flutter pub get
 * 
 * 3. The app will now:
 *    - Save theme preference when toggled
 *    - Load saved theme on app restart
 *    - Apply theme automatically
 */