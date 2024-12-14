import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'src/features/auth/presentation/login_screen.dart';
import 'src/features/dashboard/screens/dashboard_screen.dart';
import 'src/features/tenants/screens/tenants_screen.dart';
import 'src/features/properties/screens/properties_screen.dart';
import 'src/features/payments/screens/payments_screen.dart';
import 'src/features/rooms/screens/rooms_screen.dart';
import 'src/features/room_types/screens/room_types_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy(); // Use path URL strategy for web

  await Supabase.initialize(
    url: 'https://qesdjjifnvcmhqvexsew.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFlc2RqamlmbnZjbWhxdmV4c2V3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQwNzM4MzYsImV4cCI6MjA0OTY0OTgzNn0.1fCdUEiS1FxglvivYviRfOZYck89fovhj27Y4b-wRQ0',
    debug: false,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tenanta',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/tenants': (context) => const TenantsScreen(),
        '/properties': (context) => const PropertiesScreen(),
        '/payments': (context) => const PaymentsScreen(),
        '/rooms': (context) => const RoomsScreen(),
        '/room-types': (context) => const RoomTypesScreen(),
      },
    );
  }
}
