import 'package:json_annotation/json_annotation.dart';
import '../../property/domain/property.dart';

part 'room.g.dart';

@JsonSerializable(explicitToJson: true)
class Room {
  @JsonKey(defaultValue: '')
  final String id;
  @JsonKey(defaultValue: '')
  final String userId;
  @JsonKey(defaultValue: '')
  final String propertyId;
  @JsonKey(defaultValue: '')
  final String roomNumber;
  @JsonKey(defaultValue: 0.0)
  final double rentAmount;
  @JsonKey(defaultValue: 'available')
  final String status;
  @JsonKey(name: 'created_at', fromJson: _dateFromJson, defaultValue: null)
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at', fromJson: _dateFromJson, defaultValue: null)
  final DateTime? updatedAt;
  @JsonKey(name: 'property')
  final Property? property;

  Room({
    required this.id,
    required this.userId,
    required this.propertyId,
    required this.roomNumber,
    required this.rentAmount,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.property,
  });

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);

  Map<String, dynamic> toJson() => _$RoomToJson(this);

  static DateTime? _dateFromJson(dynamic date) {
    if (date == null) return null;
    if (date is String) return DateTime.parse(date);
    if (date is DateTime) return date;
    return null;
  }

  Room copyWith({
    String? id,
    String? userId,
    String? propertyId,
    String? roomNumber,
    double? rentAmount,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    Property? property,
  }) {
    return Room(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      propertyId: propertyId ?? this.propertyId,
      roomNumber: roomNumber ?? this.roomNumber,
      rentAmount: rentAmount ?? this.rentAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      property: property ?? this.property,
    );
  }
}
