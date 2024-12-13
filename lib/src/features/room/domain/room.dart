class Room {
  final String id;
  final String propertyId;
  final String roomTypeId;
  final String roomNumber;
  final int floor;
  final double rent;
  final bool isOccupied;
  final DateTime createdAt;

  Room({
    required this.id,
    required this.propertyId,
    required this.roomTypeId,
    required this.roomNumber,
    required this.floor,
    required this.rent,
    this.isOccupied = false,
    required this.createdAt,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] as String,
      propertyId: json['property_id'] as String,
      roomTypeId: json['room_type_id'] as String,
      roomNumber: json['room_number'] as String,
      floor: json['floor'] as int,
      rent: (json['rent'] as num).toDouble(),
      isOccupied: json['is_occupied'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'property_id': propertyId,
      'room_type_id': roomTypeId,
      'room_number': roomNumber,
      'floor': floor,
      'rent': rent,
      'is_occupied': isOccupied,
    };
  }
}
