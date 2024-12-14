import 'package:flutter/material.dart';
import '../../../common/widgets/base_screen.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      scaffoldKey: _scaffoldKey,
      title: 'Payments',
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement add payment
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 0, // TODO: Replace with actual payment count
        itemBuilder: (context, index) {
          return const Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Icon(Icons.payment),
              ),
              title: Text('Payment Amount'),
              subtitle: Text('Tenant Name - Date'),
              trailing: Icon(Icons.chevron_right),
            ),
          );
        },
      ),
    );
  }
}
