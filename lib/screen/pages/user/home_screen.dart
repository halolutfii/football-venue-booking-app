import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'venue/venue_screen.dart';

import '../../../../providers/user_provider.dart';
import '../../../providers/venue_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // row container lokasi dan avatar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Color(0xFF2E7D7B)),
                        const SizedBox(width: 6),
                        Text(
                          'Bali, Indonesia',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    // avatar
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12), 
                        image: (profile.photo != null && profile.photo!.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(profile.photo!),
                                    fit: BoxFit.cover,
                                  )
                                : null),
                      ),
                      child: (profileProvider.selectedImage == null &&
                              (profile.photo == null || profile.photo!.isEmpty))
                          ? const Icon(Icons.person, size: 28, color: Colors.grey)
                          : null,
                    )
                  ],
                ),

                const SizedBox(height: 25),

                // judul
                Text(
                  "Let's Find The Best Venue",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const Divider(
                  thickness: 1,
                  color: Colors.black,
                  height: 20,
                ),
                
                VenueListScreen(),

              ],
            ),
          );
        },
      ),
    );
  }
}