// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'property.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Property _$PropertyFromJson(Map<String, dynamic> json) => Property(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      title: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      location: json['location'] as String? ?? '',
      city: json['city'] as String?,
      state: json['state'] as String?,
      imageUrls: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: Property._dateFromJson(json['created_at'] as String),
      updatedAt: Property._dateFromJson(json['updated_at'] as String),
    );

Map<String, dynamic> _$PropertyToJson(Property instance) => <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'name': instance.title,
      'description': instance.description,
      'location': instance.location,
      'city': instance.city,
      'state': instance.state,
      'images': instance.imageUrls,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
