import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tasks & Notes',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: TasksNotesScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TasksNotesScreen extends StatelessWidget {
  // Hardcoded sample tasks
  final List<Map<String, String>> tasks = [
    {
      'title': 'Complete Flutter project',
      'description': 'Finish building the tasks and notes app',
    },
    {
      'title': 'Buy groceries',
      'description': 'Milk, eggs, bread, and vegetables',
    },
    {
      'title': 'Schedule dentist appointment',
      'description': 'Call the clinic before 5 PM',
    },
  ];

  TasksNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks & Notes'),
        backgroundColor: Colors.blueAccent,
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
              color: Colors.blueAccent,
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
          
          // ListView section
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 2,
                  margin: EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Icon(
                        Icons.note,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      tasks[index]['title']!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        tasks[index]['description']!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey[400],
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
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.add),
      ),
    );
  }
}