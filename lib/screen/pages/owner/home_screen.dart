import 'package:flutter/material.dart';
import 'package:football_venue_booking_app/providers/venue_provider.dart';
import 'package:football_venue_booking_app/routes.dart';
import 'package:provider/provider.dart';

class OwnerHomeScreen extends StatefulWidget {
  const OwnerHomeScreen({super.key});

  @override
  State<OwnerHomeScreen> createState() => _OwnerHomeState();
}

class _OwnerHomeState extends State<OwnerHomeScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(
      () => Provider.of<VenueProvider>(context, listen: false).loadVenues(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final venueProvider = context.watch<VenueProvider>();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: venueProvider.venues.length,
          itemBuilder: (context, index) {
            final venue = venueProvider.venues[index];

            return Card(
              color: Colors.white,
              child: ListTile(
                title: Text(venue.name),
                subtitle: Text(venue.description!),
                trailing: IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Venue'),
                        content: const Text(
                          'Are you sure want to delete venue?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              venueProvider.removeVenue(venue.venueId!);

                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: const Text('Yes'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: Icon(Icons.delete),
                ),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.ownerForm,
                    arguments: {"isUpdateForm": true, "venueId": venue.venueId},
                  );
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
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
