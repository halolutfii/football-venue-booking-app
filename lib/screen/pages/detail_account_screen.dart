import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/user_provider.dart';
import '../../../routes.dart';

class DetailAccountScreen extends StatefulWidget {
  const DetailAccountScreen({super.key});

  @override
  _DetailAccountScreenState createState() => _DetailAccountScreenState();
}

class _DetailAccountScreenState extends State<DetailAccountScreen> {

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (context, userProvider, child) {
      if (userProvider.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      final user = userProvider.user; 
      if (user == null) {
        return const Center(child: Text("No user data found."));
      }

      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Personal Information',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () {
              Navigator.pop(context);  
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              buildProfileHeader(context, user),
              const SizedBox(height: 20),
              buildAccountInformation(context, user),
              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E3A59),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.updateAccount);
                },
                child: const Text("Update Account", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold,)),
              ),
            ],
          ),
        ),
      );
    });
  }

  // Display the profile header with avatar and name
  Widget buildProfileHeader(BuildContext context, user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[200],
              backgroundImage: user.photo != null && user.photo!.isNotEmpty
                  ? NetworkImage(user.photo!) 
                  : null,
              child: (user.photo == null || user.photo!.isEmpty)
                  ? const Icon(Icons.person, size: 50, color: Colors.grey)  
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  // Display the Account Information box
  Widget buildAccountInformation(BuildContext context, user) {
    return Container(
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
          const Text("Account Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          
          // Only display ListTile if the field is not null
          if (user.name != null && user.name!.isNotEmpty) 
            buildListTile(Icons.person, user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          if (user.email != null && user.email!.isNotEmpty)
            buildListTile(Icons.email, user.email, style: const TextStyle(fontWeight: FontWeight.bold)),
          if (user.phone != null && user.phone!.isNotEmpty)
            buildListTile(Icons.phone, user.phone ?? "Not Available", style: const TextStyle(fontWeight: FontWeight.bold)),
          if (user.gender != null && user.gender!.isNotEmpty) 
            buildListTile(
              user.gender!.toLowerCase() == 'male' ? Icons.male_rounded : Icons.female_rounded, 
              user.gender ?? "Not Available", 
              style: const TextStyle(fontWeight: FontWeight.bold)
            ),
          if (user.address != null && user.address!.isNotEmpty)
            buildListTile(Icons.location_on, user.address ?? "Not Available", style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Build list tile for sections like email, phone, address, etc.
  Widget buildListTile(IconData icon, String title, {TextStyle? style, Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.black87),
      title: Text(title, style: style ?? const TextStyle(fontSize: 16)),
      trailing: trailing,
      onTap: onTap,
    );
  }
}