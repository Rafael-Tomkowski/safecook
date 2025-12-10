class ChecklistItem {
  final String id;
  String title;
  String description;

  ChecklistItem({
    required this.id,
    required this.title,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
    };
  }

  factory ChecklistItem.fromMap(Map<String, dynamic> map) {
    return ChecklistItem(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
    );
  }
}
