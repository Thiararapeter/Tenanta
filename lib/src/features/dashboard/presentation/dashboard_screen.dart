import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../property/presentation/property_list_screen.dart';
import '../../room/presentation/room_type_screen.dart';
import '../../room/presentation/room_list_dashboard_screen.dart';
import '../../tenants/screens/tenants_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _user = Supabase.instance.client.auth.currentUser;

  Future<void> _signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error signing out'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildDashboardCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 40),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _user?.email ?? 'User',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildDashboardCard(
              title: 'Properties',
              subtitle: 'Manage your properties',
              icon: Icons.home,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PropertyListScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            _buildDashboardCard(
              title: 'Rooms',
              subtitle: 'View and manage all rooms',
              icon: Icons.meeting_room,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RoomListDashboardScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            _buildDashboardCard(
              title: 'Room Types',
              subtitle: 'Configure room categories',
              icon: Icons.category,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RoomTypeScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            _buildDashboardCard(
              title: 'Tenants',
              subtitle: 'Manage your tenants',
              icon: Icons.people,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TenantsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            _buildDashboardCard(
              title: 'Payments',
              subtitle: 'Track rent payments',
              icon: Icons.payment,
              onTap: () {
                // TODO: Implement payment management
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Payment management coming soon!'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
