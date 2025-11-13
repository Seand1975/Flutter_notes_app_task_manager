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

  // Convert TaskItem to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'priority': priority,
      'description': description,
      'isCompleted': isCompleted,
    };
  }

  // Create TaskItem from JSON
  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: json['id'] as String,
      title: json['title'] as String,
      priority: json['priority'] as String,
      description: json['description'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
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