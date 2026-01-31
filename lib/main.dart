import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'pages/login_pages.dart';
import 'pages/dashboard_page.dart';
import 'blocs/kasir_cubit.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://pzqolftigafqskbhklvh.supabase.co',
    anonKey: 'sb_publishable_lfiZuKW8ZHtLq4_MYX-p0Q_cY-tAnRM',
  );



  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => KasirCubit(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,

        // ✅ THEME GLOBAL DI SINI
theme: ThemeData(
  useMaterial3: false,

  primaryColor: const Color(0xFF5B6CFF),

  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    elevation: 0,
  ),

  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: Color(0xFF5B6CFF),
    unselectedItemColor: Colors.grey,
    selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF5B6CFF),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14),
    ),
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF5B6CFF),
    foregroundColor: Colors.white,
  ),

  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),

  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Colors.black87),
  ),
),



        home: const AuthGate(),
      ),
    );
  }
}


/// 🔐 AUTH CHECK GLOBAL
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return const LoginPage();
    }

    return const DashboardPage(); // atau KasirPage
  }
}
