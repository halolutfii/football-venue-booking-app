import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../providers/venue_provider.dart';

import '../../../../routes.dart';

import 'detail_venue_screen.dart';

class VenueListScreen extends StatefulWidget {
  const VenueListScreen({super.key});

  @override
  _VenueListScreenState createState() => _VenueListScreenState();
}

class _VenueListScreenState extends State<VenueListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<VenueProvider>().loadAllVenues());
  }

  @override
  Widget build(BuildContext context) {
    var venueProvider = context.watch<VenueProvider>();
    var venues = venueProvider.venues;

    print(venues);

    if (venueProvider.isLoading) {
      return const Center(child: CircularProgressIndicator( ));
    }

    if (venues.isEmpty) {
      return const Center(child: Text("No venues available."));
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: venues.length,
      itemBuilder: (context, index) {
        final venue = venues[index];

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
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            title: Text(venue.name, style: const TextStyle(fontWeight: FontWeight.bold)),
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

              print('Venue tapped xxx: ${venue.name}, Venue ID: ${venueId}');
              Navigator.pushNamed(
                                context,
                                AppRoutes.detailVenue,
                                arguments: venue.venueId,
                              );
              
            },
          ),
        );
      },
    );
  }
}