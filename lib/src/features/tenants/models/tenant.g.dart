// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tenant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Tenant _$TenantFromJson(Map<String, dynamic> json) => Tenant(
      id: json['id'] as String,
      userId: json['userId'] as String,
      propertyId: json['propertyId'] as String,
      roomId: json['roomId'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String,
      rentAmount: (json['rent_amount'] as num).toDouble(),
      paymentStatus:
          $enumDecodeNullable(_$PaymentStatusEnumMap, json['payment_status']) ??
              PaymentStatus.pending,
      moveInDate: Tenant._dateFromJson(json['move_in_date']),
      moveOutDate: Tenant._dateFromJson(json['move_out_date']),
      notes: json['notes'] as String?,
      createdAt: Tenant._dateFromJson(json['created_at']),
      updatedAt: Tenant._dateFromJson(json['updated_at']),
    );

Map<String, dynamic> _$TenantToJson(Tenant instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'propertyId': instance.propertyId,
      'roomId': instance.roomId,
      'name': instance.name,
      'email': instance.email,
      'phone_number': instance.phoneNumber,
      'rent_amount': instance.rentAmount,
      'payment_status': _$PaymentStatusEnumMap[instance.paymentStatus]!,
      'move_in_date': instance.moveInDate.toIso8601String(),
      'move_out_date': instance.moveOutDate?.toIso8601String(),
      'notes': instance.notes,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$PaymentStatusEnumMap = {
  PaymentStatus.upToDate: 'upToDate',
  PaymentStatus.late: 'late',
  PaymentStatus.overdue: 'overdue',
  PaymentStatus.pending: 'pending',
};
