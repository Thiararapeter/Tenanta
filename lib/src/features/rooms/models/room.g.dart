// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Room _$RoomFromJson(Map<String, dynamic> json) => Room(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      propertyId: json['propertyId'] as String? ?? '',
      roomNumber: json['roomNumber'] as String? ?? '',
      rentAmount: (json['rentAmount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'available',
      createdAt: Room._dateFromJson(json['created_at']),
      updatedAt: Room._dateFromJson(json['updated_at']),
      property: json['property'] == null
          ? null
          : Property.fromJson(json['property'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RoomToJson(Room instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'propertyId': instance.propertyId,
      'roomNumber': instance.roomNumber,
      'rentAmount': instance.rentAmount,
      'status': instance.status,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'property': instance.property?.toJson(),
    };
