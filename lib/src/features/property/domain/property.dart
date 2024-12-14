import 'package:json_annotation/json_annotation.dart';

part 'property.g.dart';

@JsonSerializable(explicitToJson: true)
class Property {
  @JsonKey(defaultValue: '')
  final String id;
  @JsonKey(name: 'user_id', defaultValue: '')
  final String userId;
  @JsonKey(name: 'name', defaultValue: '')
  final String title;
  @JsonKey(defaultValue: '')
  final String description;
  @JsonKey(defaultValue: '')
  final String location;
  @JsonKey(defaultValue: null)
  final String? city;
  @JsonKey(defaultValue: null)
  final String? state;
  @JsonKey(name: 'images', defaultValue: [])
  final List<String> imageUrls;
  @JsonKey(name: 'created_at', fromJson: _dateFromJson)
  final DateTime createdAt;
  @JsonKey(name: 'updated_at', fromJson: _dateFromJson)
  final DateTime updatedAt;

  Property({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.location,
    this.city,
    this.state,
    required this.imageUrls,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Property.fromJson(Map<String, dynamic> json) => _$PropertyFromJson(json);

  Map<String, dynamic> toJson() => _$PropertyToJson(this);

  static DateTime _dateFromJson(String date) => DateTime.parse(date);

  Property copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? location,
    String? city,
    String? state,
    List<String>? imageUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Property(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      city: city ?? this.city,
      state: state ?? this.state,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
