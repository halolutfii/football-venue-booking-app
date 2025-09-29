import 'package:flutter/material.dart';
import 'package:football_venue_booking_app/routes.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../../routes.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.signOut();

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFFF8F9FA),
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
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                buildProfileHeader(context, profileProvider, profile),
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // my account section
                      const Text("My Account",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      buildListTile(Icons.person, "Personal Information", onTap: () {
                        Navigator.pushNamed(context, AppRoutes.personalInformation);
                      }),
                      buildListTile(Icons.privacy_tip, "Privacy Policy", onTap: () {}),
                      buildListTile(Icons.settings, "Setting", onTap: () {}),

                      const SizedBox(height: 25),

                      // more section
                      const Text("More", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      // logout
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.logout, color: Colors.red),
                        title: const Text(
                          'Log Out',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                        ),
                        onTap: () => _logout(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

    Widget buildProfileHeader(BuildContext context, UserProvider provider, profile) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
           // Avatar + Name
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: provider.selectedImage != null
                      ? FileImage(provider.selectedImage!)
                      : (profile != null && profile.photo != null && profile.photo!.isNotEmpty
                          ? NetworkImage(profile.photo!)
                          : null) as ImageProvider<Object>?,
                  child: (provider.selectedImage == null &&
                          (profile == null || profile.photo == null || profile.photo!.isEmpty))
                      ? const Icon(Icons.person, size: 50, color: Colors.grey)
                      : null,
                ),
                const SizedBox(height: 10),
                Text(profile.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(profile.email, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildListTile(IconData icon, String title,
      {VoidCallback? onTap, Widget? trailing}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.black87),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: trailing,
      onTap: onTap,
    );
  }
}