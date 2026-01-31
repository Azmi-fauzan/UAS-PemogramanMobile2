import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'kasir_page.dart';
import 'timer_page.dart';
import 'finance/finance_page.dart';
import 'login_pages.dart';
import 'dashboard_content_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;
  int balance = 0;
  final supabase = Supabase.instance.client;
  final pages = const [
    DashboardContent(),
    KasirPage(),
    TimerPage(),
    FinancePage(),
  ];

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }
  



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DailyNeeds'),
        actions: [
       
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
         
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Kasir',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'Timer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance),
            label: 'Keuangan',
          ),
        ],
      ),
    );
  }
}
