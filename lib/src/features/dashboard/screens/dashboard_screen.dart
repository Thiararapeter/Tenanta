import 'package:flutter/material.dart';
import '../../../common/widgets/base_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      scaffoldKey: _scaffoldKey,
      title: 'Dashboard',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome back,',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'contact@thiarara.co.ke',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildMenuItem(
              context,
              icon: Icons.home_outlined,
              title: 'Properties',
              subtitle: 'Manage your properties',
              onTap: () => Navigator.pushReplacementNamed(context, '/properties'),
            ),
            _buildMenuItem(
              context,
              icon: Icons.door_front_door_outlined,
              title: 'Rooms',
              subtitle: 'View and manage all rooms',
              onTap: () => Navigator.pushReplacementNamed(context, '/rooms'),
            ),
            _buildMenuItem(
              context,
              icon: Icons.category_outlined,
              title: 'Room Types',
              subtitle: 'Configure room categories',
              onTap: () => Navigator.pushReplacementNamed(context, '/room-types'),
            ),
            _buildMenuItem(
              context,
              icon: Icons.people_outline,
              title: 'Tenants',
              subtitle: 'Manage your tenants',
              onTap: () => Navigator.pushReplacementNamed(context, '/tenants'),
            ),
            _buildMenuItem(
              context,
              icon: Icons.payment_outlined,
              title: 'Payments',
              subtitle: 'Track rent payments',
              onTap: () => Navigator.pushReplacementNamed(context, '/payments'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(icon, size: 24),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
