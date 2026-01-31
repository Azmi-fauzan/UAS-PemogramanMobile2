import 'package:dailyneeds/main.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


import 'register_page.dart';
import '../widgets/soft_input.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final supabase = Supabase.instance.client;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email dan password wajib diisi'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthGate()),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: SafeArea(
        child: Stack(
          children: [
            // ===== GRADIENT BACKGROUND =====
            Container(
              height: 300,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
   Color(0xFF6C63FF),
  Color(0xFF8F88FF),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(100),
                  bottomRight: Radius.circular(100),
                ),
              ),
            ),

            // ===== CONTENT =====
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26),
                child: Column(
                  children: [
                    const SizedBox(height: 180),

                    // ===== LOGIN CARD =====
                    Container(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF1C1E2A),
                            Color(0xFF161824),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.6),
                            blurRadius: 40,
                            offset: const Offset(0, 25),
                          ),
                          BoxShadow(
                            color: Colors.white.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(-5, -5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Welcome Back",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Masuk untuk melanjutkan ke DailyNeeds",
                            style: TextStyle(color: Colors.white54),
                          ),

                          const SizedBox(height: 30),

                          SoftInput(
                            controller: emailController,
                            hint: "Email",
                          ),
                          const SizedBox(height: 18),

                          SoftInput(
                            controller: passwordController,
                            hint: "Password",
                            obscure: true,
                          ),

                          const SizedBox(height: 34),

                          // ===== LOGIN BUTTON =====
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child:ElevatedButton(
  onPressed: isLoading ? null : handleLogin,
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.transparent,
    shadowColor: Colors.transparent,
    padding: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  ),
  child: Ink(
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [
          Color(0xFF6C63FF),
          Color(0xFF9A94FF),
        ],
      ),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Center(
      child: isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text(
              "Login",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
    ),
  ),
),

                          ),

                          const SizedBox(height: 24),

                          // ===== SIGN UP =====
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const RegisterPage(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Belum punya akun? Sign up",
                                style: TextStyle(
                                  color: Color(0xFF8F88FF),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
