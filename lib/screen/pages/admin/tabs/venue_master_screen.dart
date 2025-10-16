import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:football_venue_booking_app/providers/master_provider.dart';

import '../../../../routes.dart';

class VenueMasterScreen extends StatefulWidget {
  const VenueMasterScreen({super.key});

  @override
  State<VenueMasterScreen> createState() => _VenueMasterScreenState();
}

class _VenueMasterScreenState extends State<VenueMasterScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<MasterProvider>().loadAllVenues());
  }

  @override
  Widget build(BuildContext context) {
    var venueMasterProvider = context.watch<MasterProvider>();
    var venuesMaster = venueMasterProvider.venues;

    if (venueMasterProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (venuesMaster.isEmpty) {
      return const Center(child: Text("No venues available."));
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0), 
        child: ListView.builder(
          itemCount: venuesMaster.length,
          itemBuilder: (context, index) {
            final venue = venuesMaster[index];

            return Card(
              color: Colors.white,
              elevation: 1,  
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                leading: CircleAvatar(
                  radius: 30, 
                  backgroundColor: Colors.grey[200],
                  backgroundImage: AssetImage('assets/images/logo.png'), 
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

                  Navigator.pushNamed(
                    context,
                    AppRoutes.detailAdminVenue,
                    arguments: venueId,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}