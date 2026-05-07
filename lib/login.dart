import 'package:battle_dogs/BattleDogsMainPage.dart';
import 'package:battle_dogs/Register.dart';
import 'package:battle_dogs/auth/auth_serviece.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required String title});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final authServiece = AuthServiece();
  final _supabase = Supabase.instance.client;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _logAuthEvent(String userId, String email) async {
    // כתיבה לטבלת auth_logs — מסד נתונים מנורמל עם טבלה נפרדת
    try {
      await _supabase.from('auth_logs').insert({
        'user_id': userId,
        'email': email,
        'action': 'login',
        'logged_at': DateTime.now().toIso8601String(),
        'platform': 'mobile',
      });
    } catch (e) {
      debugPrint('auth_logs insert error: $e');
    }
  }

  Future<void> login() async {
    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      await authServiece.signIn(email, password);

      // Log the login event to auth_logs table
      final user = _supabase.auth.currentUser;
      if (user != null) {
        await _logAuthEvent(user.id, email);
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BattleDogsMainPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: const Color(0xFFE74C3C),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E3C72), Color(0xFF2980B9), Color(0xFF6DD5FA)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Logo
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B35), Color(0xFFF7931E)]),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: const Color(0xFFF7931E), width: 4),
                      boxShadow: const [
                        BoxShadow(color: Color(0x99F7931E), blurRadius: 20, spreadRadius: 3),
                      ],
                    ),
                    child: const Text('🦴 BATTLE DOGS 🦴',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900,
                            color: Colors.white, letterSpacing: 1)),
                  ),
                  const SizedBox(height: 32),

                  // Login Card
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.97),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(color: Color(0x44000000), blurRadius: 20, offset: Offset(0, 8)),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Icon(Icons.lock_person_rounded, size: 60, color: Color(0xFF2980B9)),
                          const SizedBox(height: 12),
                          const Text('Welcome Back',
                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E3C72)),
                              textAlign: TextAlign.center),
                          const SizedBox(height: 4),
                          const Text('Sign in to continue',
                              style: TextStyle(fontSize: 13, color: Colors.grey),
                              textAlign: TextAlign.center),
                          const SizedBox(height: 28),

                          // Email
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF2980B9)),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: Color(0xFF2980B9), width: 2),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || !value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF2980B9)),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                    color: Colors.grey),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: Color(0xFF2980B9), width: 2),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 28),

                          // Sign In Button
                          GestureDetector(
                            onTap: () {
                              if (_formKey.currentState!.validate() && !_isLoading) {
                                login();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                    colors: [Color(0xFF2980B9), Color(0xFF1E3C72)]),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: const [
                                  BoxShadow(color: Color(0x442980B9), blurRadius: 10, offset: Offset(0, 4)),
                                ],
                              ),
                              child: Center(
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 22, width: 22,
                                        child: CircularProgressIndicator(
                                            color: Colors.white, strokeWidth: 2.5))
                                    : const Text('Sign In',
                                        style: TextStyle(color: Colors.white,
                                            fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Divider
                          Row(children: [
                            const Expanded(child: Divider()),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('or', style: TextStyle(color: Colors.grey)),
                            ),
                            const Expanded(child: Divider()),
                          ]),
                          const SizedBox(height: 20),

                          // Register
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don't have an account? ",
                                  style: TextStyle(color: Colors.grey)),
                              GestureDetector(
                                onTap: () => Navigator.push(context,
                                    MaterialPageRoute(
                                        builder: (context) => const RegisterPage(title: 'Register'))),
                                child: const Text('Sign Up',
                                    style: TextStyle(color: Color(0xFF2980B9),
                                        fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}