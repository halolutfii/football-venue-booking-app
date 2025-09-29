import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../providers/user_provider.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Consumer<UserProvider>(
        builder: (context, profileProvider, child) {
          if (profileProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final profile = profileProvider.user;
          if (profile == null) {
            return const Center(child: Text("No profile data found."));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Displaying the logo image
                Center(
                  child: Image.asset(
                    "assets/images/logo_screen.png",
                    height: 200,
                    width: double.infinity,  
                    fit: BoxFit.contain,      
                  ),
                ),

                // Welcome message
                Center(
                  child: Text(
                    "Welcome Back, Admin!",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),

                const Divider(
                  thickness: 1, 
                  color: Colors.black, 
                  height: 20, 
                ),

                const SizedBox(height: 40), 
              ],
            ),
          );
        },
      ),
    );
  }
}