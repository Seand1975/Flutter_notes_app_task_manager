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

  // Convert TaskItem to JSON suitable for SQLite (isCompleted as int 0/1)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'priority': priority,
      'description': description,
      // store as integer for SQLite
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  // Create TaskItem from DB map (handles int/bool)
  factory TaskItem.fromJson(Map<String, dynamic> json) {
    final dynamic rawIsCompleted = json['isCompleted'];

    bool parsedIsCompleted;
    if (rawIsCompleted is int) {
      parsedIsCompleted = rawIsCompleted == 1;
    } else if (rawIsCompleted is bool) {
      parsedIsCompleted = rawIsCompleted;
    } else if (rawIsCompleted is String) {
      parsedIsCompleted = rawIsCompleted == '1' || rawIsCompleted.toLowerCase() == 'true';
    } else {
      parsedIsCompleted = false;
    }

    return TaskItem(
      id: json['id'] as String,
      title: json['title'] as String,
      priority: json['priority'] as String,
      description: json['description'] as String,
      isCompleted: parsedIsCompleted,
    );
  }

  // CopyWith method for easy updates (useful for toggling isCompleted)
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
