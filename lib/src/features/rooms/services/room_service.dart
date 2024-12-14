import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/room.dart';

class RoomService {
  final _supabase = Supabase.instance.client;

  Future<List<Room>> getRooms() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _supabase
          .from('rooms')
          .select('*, property:properties(*)')
          .eq('user_id', userId);

      if (response == null) return [];

      return (response as List<dynamic>).map((data) {
        try {
          return Room.fromJson(Map<String, dynamic>.from(data));
        } catch (e) {
          print('Error parsing room data: $e');
          print('Problematic data: $data');
          return null;
        }
      }).whereType<Room>().toList();
    } catch (e) {
      print('Error fetching rooms: $e');
      return [];
    }
  }

  Future<void> addRoom(Map<String, dynamic> roomData) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    await _supabase.from('rooms').insert({
      ...roomData,
      'user_id': userId,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
