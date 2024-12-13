class RoomType {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;

  RoomType({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
  });

  factory RoomType.fromJson(Map<String, dynamic> json) {
    return RoomType(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
    };
  }
}
