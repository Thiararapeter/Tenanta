class Property {
  final String id;
  final String ownerId;
  final String title;
  final String description;
  final double rent;
  final String? caretakerId;
  final String city;
  final String address;
  final List<String> imageUrls;
  final DateTime createdAt;
  final DateTime updatedAt;

  Property({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.rent,
    this.caretakerId,
    required this.city,
    required this.address,
    required this.imageUrls,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      rent: (json['rent'] as num).toDouble(),
      caretakerId: json['caretaker_id'] as String?,
      city: json['city'] as String,
      address: json['address'] as String,
      imageUrls: List<String>.from(json['image_urls'] as List),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'title': title,
      'description': description,
      'rent': rent,
      'caretaker_id': caretakerId,
      'city': city,
      'address': address,
      'image_urls': imageUrls,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Property copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? description,
    double? rent,
    String? caretakerId,
    String? city,
    String? address,
    List<String>? imageUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Property(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      rent: rent ?? this.rent,
      caretakerId: caretakerId ?? this.caretakerId,
      city: city ?? this.city,
      address: address ?? this.address,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
