import 'package:flutter/material.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/tenants/screens/tenants_screen.dart';
import 'features/properties/screens/properties_screen.dart';
import 'features/payments/screens/payments_screen.dart';
import 'features/leases/screens/leases_screen.dart';
import 'features/reports/screens/reports_screen.dart';
import 'features/settings/screens/settings_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tenanta',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const DashboardScreen(),
        '/tenants': (context) => const TenantsScreen(),
        '/properties': (context) => const PropertiesScreen(),
        '/payments': (context) => const PaymentsScreen(),
        '/leases': (context) => const LeasesScreen(),
        '/reports': (context) => const ReportsScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
