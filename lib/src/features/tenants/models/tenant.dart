import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tenant.g.dart';

enum TenantStatus {
  active,
  inactive,
  pending,
  evicted
}

enum PaymentStatus {
  @JsonValue('upToDate')
  upToDate,
  @JsonValue('late')
  late,
  @JsonValue('overdue')
  overdue,
  @JsonValue('pending')
  pending
}

@JsonSerializable(explicitToJson: true)
class Tenant {
  final String id;
  final String userId;
  final String propertyId;
  final String roomId;
  final String name;
  final String email;
  @JsonKey(name: 'phone_number')
  final String phoneNumber;
  @JsonKey(name: 'rent_amount')
  final double rentAmount;
  @JsonKey(name: 'payment_status', defaultValue: PaymentStatus.pending)
  final PaymentStatus paymentStatus;
  @JsonKey(name: 'move_in_date', fromJson: _dateFromJson)
  final DateTime moveInDate;
  @JsonKey(name: 'move_out_date', fromJson: _dateFromJson)
  final DateTime? moveOutDate;
  final String? notes;
  @JsonKey(name: 'created_at', fromJson: _dateFromJson)
  final DateTime createdAt;
  @JsonKey(name: 'updated_at', fromJson: _dateFromJson)
  final DateTime updatedAt;

  const Tenant({
    required this.id,
    required this.userId,
    required this.propertyId,
    required this.roomId,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.rentAmount,
    required this.paymentStatus,
    required this.moveInDate,
    this.moveOutDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Tenant.fromJson(Map<String, dynamic> json) => _$TenantFromJson(json);

  Map<String, dynamic> toJson() => _$TenantToJson(this);

  static DateTime _dateFromJson(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is String) return DateTime.parse(date);
    if (date is DateTime) return date;
    throw ArgumentError('Invalid date format');
  }

  Tenant copyWith({
    String? id,
    String? userId,
    String? propertyId,
    String? roomId,
    String? name,
    String? email,
    String? phoneNumber,
    double? rentAmount,
    PaymentStatus? paymentStatus,
    DateTime? moveInDate,
    DateTime? moveOutDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Tenant(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      propertyId: propertyId ?? this.propertyId,
      roomId: roomId ?? this.roomId,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      rentAmount: rentAmount ?? this.rentAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      moveInDate: moveInDate ?? this.moveInDate,
      moveOutDate: moveOutDate ?? this.moveOutDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
