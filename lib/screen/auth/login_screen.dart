import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../main.dart';

import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';

import '../../routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool loading = false;

  Widget buildTextField(String label, TextEditingController controller, {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: GoogleFonts.poppins(),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.grey[700]),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Image.asset("assets/images/solecode.png", height: 180,),
            const SizedBox(height: 20),

            // Card Login
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // EMAIL INPUT
                    buildTextField("Email", _emailController),
                    const SizedBox(height: 12),

                    // PASSWORD INPUT
                    buildTextField("Password", _passwordController, obscure: true),
                    const SizedBox(height: 20),

                    // LOGIN BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                            onPressed: loading ? null :() async { 
                            setState(() => loading = true); 

                            final email = _emailController.text.trim();
                            final password = _passwordController.text.trim();
                            final profileProvider = Provider.of<UserProvider>(context, listen: false);
                            final success =
                                await authProvider.signInWithEmail(email, password, profileProvider);

                            if (success && profileProvider.user != null) {
                              if (profileProvider.user!.role == "admin") {
                                Navigator.pushReplacementNamed(context, AppRoutes.main);
                              } else {
                                Navigator.pushReplacementNamed(context, AppRoutes.main);
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        authProvider.errorMessage ?? "Login failed")),
                              );
                            }

                            setState(() => loading = false);
                          },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E3A59),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                "Login",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.register);
                      },
                      child: Text(
                        "Belum punya akun? Register",
                        style: GoogleFonts.poppins(color: const Color(0xFF2E3A59)),
                      ),
                    ),
            // Footer(),
          ],
        ),
      ),
    );
  }
}