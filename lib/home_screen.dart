import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import these in your project:
import 'models/task_item.dart';
import 'database_helper.dart';

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
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: json['id'] as String,
      title: json['title'] as String,
      priority: json['priority'] as String,
      description: json['description'] as String,
      isCompleted: json['isCompleted'] == 1,
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
  List<TaskItem> tasks = [];

  void _addNewTask(TaskItem newTask) {
    setState(() {
      tasks.insert(0, newTask);
    });
  }

  void _updateTask(TaskItem updatedTask) {
    setState(() {
      final index = tasks.indexWhere((task) => task.id == updatedTask.id);
      if (index != -1) {
        tasks[index] = updatedTask;
      }
    });
  }

  void _deleteTask(String taskId) {
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
              onPressed: () {
                Navigator.pop(context);
                _deleteTask(task.id);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Task "${task.title}" deleted'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToAddTaskForm() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTaskFormScreen(),
      ),
    );

    if (result != null && result is TaskItem) {
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
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTaskFormScreen(taskToEdit: task),
      ),
    );

    if (result != null && result is TaskItem) {
      _updateTask(result);
      
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
            child: tasks.isEmpty
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
                                    color:
                                        isDark ? Colors.grey[400] : Colors.grey[600],
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

// Add Task Form Screen
class AddTaskFormScreen extends StatefulWidget {
  final TaskItem? taskToEdit;

  const AddTaskFormScreen({Key? key, this.taskToEdit}) : super(key: key);

  @override
  State<AddTaskFormScreen> createState() => _AddTaskFormScreenState();
}

class _AddTaskFormScreenState extends State<AddTaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedPriority = 'Medium';
  bool _isCompleted = false;
  bool _isEditMode = false;

  final List<String> _priorityOptions = ['High', 'Medium', 'Low'];

  @override
  void initState() {
    super.initState();
    
    // Check if we're editing an existing task
    if (widget.taskToEdit != null) {
      _isEditMode = true;
      _titleController.text = widget.taskToEdit!.title;
      _descriptionController.text = widget.taskToEdit!.description;
      _selectedPriority = widget.taskToEdit!.priority;
      _isCompleted = widget.taskToEdit!.isCompleted;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final TaskItem resultTask;
      
      if (_isEditMode && widget.taskToEdit != null) {
        // Update existing task (keep the same ID)
        resultTask = TaskItem(
          id: widget.taskToEdit!.id,
          title: _titleController.text.trim(),
          priority: _selectedPriority,
          description: _descriptionController.text.trim(),
          isCompleted: _isCompleted,
        );
      } else {
        // Create new task with generated ID
        resultTask = TaskItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text.trim(),
          priority: _selectedPriority,
          description: _descriptionController.text.trim(),
          isCompleted: _isCompleted,
        );
      }

      // Return the task to the previous screen
      Navigator.pop(context, resultTask);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Task' : 'Add New Task'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title field
                Text(
                  'Task Title',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Enter task title',
                    prefixIcon: Icon(Icons.title),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a task title';
                    }
                    if (value.trim().length < 3) {
                      return 'Title must be at least 3 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Priority field
                Text(
                  'Priority',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedPriority,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.flag),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                  ),
                  items: _priorityOptions.map((String priority) {
                    return DropdownMenuItem<String>(
                      value: priority,
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _getPriorityColor(priority),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(priority),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPriority = value!;
                    });
                  },
                ),
                SizedBox(height: 20),

                // Description field
                Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Enter task description',
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 70),
                      child: Icon(Icons.description),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a task description';
                    }
                    if (value.trim().length < 5) {
                      return 'Description must be at least 5 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Completed checkbox
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CheckboxListTile(
                    title: Text(
                      'Mark as Completed',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text('Check if this task is already done'),
                    value: _isCompleted,
                    onChanged: (value) {
                      setState(() {
                        _isCompleted = value ?? false;
                      });
                    },
                    secondary: Icon(
                      _isCompleted ? Icons.check_circle : Icons.circle_outlined,
                      color: _isCompleted ? Colors.green : Colors.grey,
                    ),
                  ),
                ),
                SizedBox(height: 30),

                // Submit button
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_isEditMode ? Icons.save : Icons.add_task),
                      SizedBox(width: 8),
                      Text(
                        _isEditMode ? 'Save Changes' : 'Add Task',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // Cancel button
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: theme.colorScheme.primary),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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