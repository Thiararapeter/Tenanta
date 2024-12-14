import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/tenant.dart';

class TenantService {
  final _supabase = Supabase.instance.client;

  Future<List<Tenant>> getTenants() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase
        .from('tenants')
        .select('''
          *,
          property:properties!tenants_property_id_fkey(id, name),
          room:rooms!tenants_room_id_fkey(id, room_number)
        ''')
        .eq('user_id', userId);

    return List<Map<String, dynamic>>.from(response)
        .map((data) => Tenant.fromJson(data))
        .toList();
  }

  Future<Tenant?> getTenant(String id) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await _supabase
        .from('tenants')
        .select('''
          *,
          property:properties!tenants_property_id_fkey(id, name),
          room:rooms!tenants_room_id_fkey(id, room_number)
        ''')
        .eq('id', id)
        .eq('user_id', userId)
        .single();

    if (response == null) return null;
    return Tenant.fromJson(response);
  }

  Future<Tenant> addTenant(Map<String, dynamic> tenantData) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final response = await _supabase
        .from('tenants')
        .insert({
          ...tenantData,
          'user_id': userId,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .select('''
          *,
          property:properties!tenants_property_id_fkey(id, name),
          room:rooms!tenants_room_id_fkey(id, room_number)
        ''')
        .single();

    return Tenant.fromJson(response);
  }

  Future<void> updateTenant(String id, Map<String, dynamic> data) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _supabase
        .from('tenants')
        .update({
          ...data,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .eq('user_id', userId);
  }

  Future<void> deleteTenant(String id) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _supabase
        .from('tenants')
        .delete()
        .eq('id', id)
        .eq('user_id', userId);
  }
}
