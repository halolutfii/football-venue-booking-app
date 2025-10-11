import 'package:flutter/material.dart';
import 'package:football_venue_booking_app/providers/user_provider.dart';
import 'package:football_venue_booking_app/providers/venue_provider.dart';
import 'package:football_venue_booking_app/routes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class OwnerHomeScreen extends StatefulWidget {
  const OwnerHomeScreen({super.key});

  @override
  State<OwnerHomeScreen> createState() => _OwnerHomeState();
}

class _OwnerHomeState extends State<OwnerHomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() => context.read<VenueProvider>().loadVenues());
  }

  @override
  Widget build(BuildContext context) {
    List<Color> tileColor = [
      Theme.of(context).colorScheme.primaryContainer,
      Theme.of(context).colorScheme.tertiaryContainer,
      Theme.of(context).colorScheme.secondaryContainer,
    ];

    List<Color> textColor = [
      Theme.of(context).colorScheme.onPrimaryContainer,
      Theme.of(context).colorScheme.onTertiaryContainer,
      Theme.of(context).colorScheme.onSecondaryContainer,
    ];

    final VenueProvider venueProvider = context.watch<VenueProvider>();
    final UserProvider profileProvider = context.read<UserProvider>();
    final profile = profileProvider.user;

    return profileProvider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : profile == null
        ? const Center(child: Text("No profile data found."))
        : Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Hello owner 👋🏼',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      // avatar
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          image: profileProvider.selectedImage != null
                              ? DecorationImage(
                                  image: FileImage(
                                    profileProvider.selectedImage!,
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : (profile.photo != null &&
                                        profile.photo!.isNotEmpty
                                    ? DecorationImage(
                                        image: NetworkImage(profile.photo!),
                                        fit: BoxFit.cover,
                                      )
                                    : null),
                        ),
                        child:
                            (profileProvider.selectedImage == null &&
                                (profile.photo == null ||
                                    profile.photo!.isEmpty))
                            ? const Icon(
                                Icons.person,
                                size: 28,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  SizedBox(
                    height: 100,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: venueProvider.venues.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final venue = venueProvider.venues[index];
                        return Card(
                          color: Colors.white,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            leading: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                image: DecorationImage(
                                  image: AssetImage('assets/images/logo.png'), 
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            title: Text(
                              venue.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Row(
                              children: [
                                const Icon(Icons.location_on, size: 16, color: Colors.red),
                                const SizedBox(width: 4),
                                Text(
                                  venue.address,
                                  style: const TextStyle(color: Colors.black87),
                                ),
                              ],
                            ),
                            onTap: () async {
                              final venueId = venue.venueId;

                              Navigator.pushNamed( context, AppRoutes.ownerDetailVenue, arguments: venue.venueId, );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.ownerForm,
                  arguments: {"isUpdateForm": false},
                );
              },
              child: Icon(Icons.add),
            ),
          );
  }
}
