import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/session_provider.dart';
import 'ai_advisor_screen.dart';
import 'dashboard_screen.dart';
import 'grants_screen.dart';
import 'performance_screen.dart';
import 'simulator_screen.dart';
import 'upload_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _index = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final sid = context.watch<SessionProvider>().smeId;
    final pages = <Widget>[
      DashboardScreen(key: ValueKey('dash_$sid')),
      const SimulatorScreen(),
      const AiAdvisorScreen(),
      const GrantsScreen(),
      PerformanceScreen(key: ValueKey('perf_$sid')),
    ];

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('SME Advisor'),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Session', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              Text('Current SME ID: $sid', style: TextStyle(color: Colors.grey.shade700)),
              const SizedBox(height: 16),
              const Text('Quick select (seed data)'),
              ListTile(
                title: const Text('SME 1 — Kopi Maju'),
                onTap: () async {
                  await context.read<SessionProvider>().setSmeId(1);
                  if (context.mounted) Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('SME 2 — Harapan Agro'),
                onTap: () async {
                  await context.read<SessionProvider>().setSmeId(2);
                  if (context.mounted) Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('SME 3 — Urban Digital'),
                onTap: () async {
                  await context.read<SessionProvider>().setSmeId(3);
                  if (context.mounted) Navigator.pop(context);
                },
              ),
              const Divider(height: 32),
              ListTile(
                leading: const Icon(Icons.upload_file),
                title: const Text('Upload CSV'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const UploadScreen()));
                },
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.grid_view_outlined), label: 'Health'),
          NavigationDestination(icon: Icon(Icons.calculate_outlined), label: 'Simulate'),
          NavigationDestination(icon: Icon(Icons.psychology_outlined), label: 'AI Advisor'),
          NavigationDestination(icon: Icon(Icons.account_balance_outlined), label: 'Grants'),
          NavigationDestination(icon: Icon(Icons.show_chart), label: 'Performance'),
        ],
      ),
    );
  }
}
