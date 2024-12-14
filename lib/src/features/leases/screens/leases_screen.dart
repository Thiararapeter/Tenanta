import 'package:flutter/material.dart';
import '../../../common/widgets/base_screen.dart';

class LeasesScreen extends StatefulWidget {
  const LeasesScreen({super.key});

  @override
  State<LeasesScreen> createState() => _LeasesScreenState();
}

class _LeasesScreenState extends State<LeasesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      scaffoldKey: _scaffoldKey,
      title: 'Leases',
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement add lease
        },
        child: const Icon(Icons.add),
      ),
      body: const Center(
        child: Text('Leases Screen'),
      ),
    );
  }
}
