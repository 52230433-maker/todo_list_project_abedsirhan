class Task {
  int? id;
  String title;
  String description;
  String priority;
  bool isDone;

  Task({
    this.id,
    required this.title,
    required this.description,
    this.priority = 'Medium',
    this.isDone = false,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: int.parse(json['id'].toString()),
      title: json['title'],
      description: json['description'],
      priority: json['priority'],
      isDone: json['is_done'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority,
      'is_done': isDone ? 1 : 0,
    };
  }
}