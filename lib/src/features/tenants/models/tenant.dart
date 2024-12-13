import 'package:flutter/material.dart';

enum PaymentStatus {
  upToDate,
  pending,
  overdue,
}

class Tenant {
  final String id;
  final String propertyId;
  final String name;
  final String email;
  final String phoneNumber;
  final double rentAmount;
  final PaymentStatus paymentStatus;
  final DateTime moveInDate;
  final DateTime? moveOutDate;
  final String? notes;
  final Map<String, dynamic>? property;

  Tenant({
    required this.id,
    required this.propertyId,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.rentAmount,
    required this.paymentStatus,
    required this.moveInDate,
    this.moveOutDate,
    this.notes,
    this.property,
  });

  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      id: json['id'],
      propertyId: json['property_id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      rentAmount: (json['rent_amount'] as num).toDouble(),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.toString().split('.').last.toLowerCase() == json['payment_status'].toString().toLowerCase(),
        orElse: () => PaymentStatus.pending,
      ),
      moveInDate: DateTime.parse(json['move_in_date']),
      moveOutDate: json['move_out_date'] != null ? DateTime.parse(json['move_out_date']) : null,
      notes: json['notes'],
      property: json['properties'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'property_id': propertyId,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'rent_amount': rentAmount,
      'payment_status': paymentStatus.toString().split('.').last.toLowerCase(),
      'move_in_date': moveInDate.toIso8601String(),
      'move_out_date': moveOutDate?.toIso8601String(),
      'notes': notes,
    };
  }

  String get propertyTitle => property?['title'] ?? 'Unknown Property';
  String get propertyAddress => property?['address'] ?? '';
}
