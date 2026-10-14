class Task {
  const Task({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final String? description;
  final bool isCompleted;

  Task copyWith({bool? isCompleted}) {
    return Task(
      id: id,
      title: title,
      description: description,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
