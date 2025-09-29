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
                          clipBehavior: Clip.antiAlias,
                          child: ListTile(
                            tileColor: index < tileColor.length
                                ? tileColor[index]
                                : Theme.of(context).colorScheme.surface,
                            leading: const Icon(Icons.business_outlined),
                            title: Text(
                              venue.name,
                              style: TextStyle(
                                color: index < textColor.length
                                    ? textColor[index]
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            subtitle: Text(
                              venue.description,
                              style: TextStyle(
                                color: index < textColor.length
                                    ? textColor[index]
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.ownerDetailVenue,
                                arguments: venue.venueId,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Indicator dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      venueProvider.venues.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentIndex == index ? 12 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentIndex == index
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
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
