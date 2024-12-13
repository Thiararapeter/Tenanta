import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/tenant.dart';

class TenantService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Tenant>> getTenants() async {
    final response = await _supabase
        .from('tenants')
        .select('''
          *,
          properties:property_id (
            title,
            address
          )
        ''')
        .order('created_at');

    return (response as List).map((json) => Tenant.fromJson(json)).toList();
  }

  Future<Tenant> addTenant(Map<String, dynamic> tenantData) async {
    final response = await _supabase
        .from('tenants')
        .insert(tenantData)
        .select()
        .single();

    return Tenant.fromJson(response);
  }

  Future<Tenant> updateTenant(String id, Map<String, dynamic> tenantData) async {
    final response = await _supabase
        .from('tenants')
        .update(tenantData)
        .eq('id', id)
        .select()
        .single();

    return Tenant.fromJson(response);
  }

  Future<void> deleteTenant(String id) async {
    await _supabase
        .from('tenants')
        .delete()
        .eq('id', id);
  }

  Future<List<Map<String, dynamic>>> getProperties() async {
    final response = await _supabase
        .from('properties')
        .select('id, title')
        .order('title');

    return (response as List).cast<Map<String, dynamic>>();
  }
}
