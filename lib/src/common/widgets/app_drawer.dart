import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final _supabase = Supabase.instance.client;
  int _propertyCount = 0;
  int _roomCount = 0;
  int _roomTypeCount = 0;
  int _tenantCount = 0;
  double _totalPayments = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    try {
      // Get property count
      final properties = await _supabase
          .from('properties')
          .select('id')
          .eq('user_id', _supabase.auth.currentUser?.id);
      _propertyCount = properties.length;

      // Get room count
      final rooms = await _supabase
          .from('rooms')
          .select('id')
          .eq('user_id', _supabase.auth.currentUser?.id);
      _roomCount = rooms.length;

      // Get room type count
      final roomTypes = await _supabase
          .from('room_types')
          .select('id')
          .eq('user_id', _supabase.auth.currentUser?.id);
      _roomTypeCount = roomTypes.length;

      // Get tenant count
      final tenants = await _supabase
          .from('tenants')
          .select('id')
          .eq('user_id', _supabase.auth.currentUser?.id);
      _tenantCount = tenants.length;

      // Get total payments
      final payments = await _supabase
          .from('payments')
          .select('amount')
          .eq('user_id', _supabase.auth.currentUser?.id);
      _totalPayments = (payments as List).fold<double>(
          0, (sum, payment) => sum + ((payment['amount'] as num).toDouble()));

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading counts: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _supabase.auth.currentUser;
    
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFEEEEEE),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back,',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? 'contact@thiarara.co.ke',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
          _buildMenuItem(
            context,
            icon: Icons.dashboard_outlined,
            title: 'Dashboard',
            subtitle: 'View your dashboard',
            onTap: () => Navigator.pushReplacementNamed(context, '/dashboard'),
          ),
          _buildMenuItem(
            context,
            icon: Icons.home_outlined,
            title: 'Properties',
            subtitle: 'Manage your properties',
            count: _propertyCount,
            isLoading: _isLoading,
            onTap: () => Navigator.pushReplacementNamed(context, '/properties'),
          ),
          _buildMenuItem(
            context,
            icon: Icons.door_front_door_outlined,
            title: 'Rooms',
            subtitle: 'View and manage all rooms',
            count: _roomCount,
            isLoading: _isLoading,
            onTap: () => Navigator.pushReplacementNamed(context, '/rooms'),
          ),
          _buildMenuItem(
            context,
            icon: Icons.category_outlined,
            title: 'Room Types',
            subtitle: 'Configure room categories',
            count: _roomTypeCount,
            isLoading: _isLoading,
            onTap: () => Navigator.pushReplacementNamed(context, '/room-types'),
          ),
          _buildMenuItem(
            context,
            icon: Icons.people_outline,
            title: 'Tenants',
            subtitle: 'Manage your tenants',
            count: _tenantCount,
            isLoading: _isLoading,
            onTap: () => Navigator.pushReplacementNamed(context, '/tenants'),
          ),
          _buildMenuItem(
            context,
            icon: Icons.payment_outlined,
            title: 'Payments',
            subtitle: 'Track rent payments',
            amount: _totalPayments,
            isLoading: _isLoading,
            onTap: () => Navigator.pushReplacementNamed(context, '/payments'),
          ),
          _buildLogoutItem(context),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    int? count,
    double? amount,
    bool isLoading = false,
  }) {
    Widget? trailing;
    
    if (isLoading) {
      trailing = const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      );
    } else if (count != null) {
      trailing = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          count.toString(),
          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    } else if (amount != null) {
      trailing = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '\$${amount.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    } else {
      trailing = const Icon(
        Icons.chevron_right,
        color: Color(0xFF666666),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFEEEEEE),
            width: 1,
          ),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(
          icon,
          size: 24,
          color: const Color(0xFF333333),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF333333),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF666666),
          ),
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogoutItem(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFEEEEEE),
            width: 1,
          ),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: const Icon(
          Icons.logout,
          size: 24,
          color: Color(0xFF333333),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF333333),
          ),
        ),
        onTap: () async {
          await _supabase.auth.signOut();
          if (context.mounted) {
            Navigator.pushReplacementNamed(context, '/');
          }
        },
      ),
    );
  }
}
