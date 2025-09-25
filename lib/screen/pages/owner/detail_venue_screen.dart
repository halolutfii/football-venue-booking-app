import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:football_venue_booking_app/config/user_role.dart';
import 'package:football_venue_booking_app/models/venue_model.dart';
import 'package:football_venue_booking_app/providers/field_provider.dart';
import 'package:football_venue_booking_app/providers/venue_provider.dart';
import 'package:football_venue_booking_app/routes.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';

class DetailVenueScreen extends StatelessWidget {
  const DetailVenueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final venueProvider = context.watch<VenueProvider>();
    final fieldProvider = context.watch<FieldProvider>().fields;
    // final fieldProvider = context.watch<FieldProvider>();

    // print("screen: ${venueProvider!.name}");
    // print("screen: ${venueProvider.description}");
    // print("screen: ${venueProvider.contact}");
    // print("screen: ${venueProvider.address}");
    // print("screen: ${venueProvider.locationLat}");
    // print("screen: ${venueProvider.locationLong}");

    return venueProvider.isLoading
        ? const Scaffold(body: Center(child: CircularProgressIndicator()))
        : venueProvider.errorMessage != null
        ? Scaffold(body: Center(child: Text(venueProvider.errorMessage!)))
        : Scaffold(
            appBar: AppBar(
              title: Text(
                venueProvider.venue!.name,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              leading: IconButton(
                onPressed: () => Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.main,
                  arguments: UserRole.owner,
                ),
                icon: Icon(Icons.arrow_back_ios_new_rounded),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.ownerForm,
                      arguments: {
                        "isUpdateForm": true,
                        "venueId": venueProvider.venue!.venueId,
                      },
                    );
                  },
                  icon: Icon(Icons.more_horiz_outlined),
                ),
              ],
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDisplayText(
                                context,
                                venueProvider.venue!.description,
                                "Description",
                              ),
                              const SizedBox(height: 16),

                              _buildDisplayText(
                                context,
                                venueProvider.venue!.contact,
                                "Contact",
                              ),
                              const SizedBox(height: 16),

                              _buildDisplayText(
                                context,
                                venueProvider.venue!.address,
                                "Address",
                              ),
                              const SizedBox(height: 16),

                              Text(
                                "Location",
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              _buildMap(context, venueProvider.venue!),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        "Fields",
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      ...fieldProvider.map(
                        (field) => Card(
                          color: Colors.white,
                          child: ListTile(
                            title: Text(field.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Rp${field.defaultPrice}"),
                                Text("${field.slotDuration} minutes"),
                              ],
                            ),
                            trailing: Column(
                              children: [
                                Text("Open: ${field.openingTime}"),
                                Text("Close: ${field.closingTime}"),
                              ],
                            ),
                            isThreeLine: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}

Widget _buildDisplayText(BuildContext context, String? data, String title) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 4),
      Text(data ?? "-"),
    ],
  );
}

Widget _buildMap(BuildContext context, VenueModel venueProvider) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: SizedBox(
      height: 200,
      child:
          venueProvider.locationLat != null &&
              venueProvider.locationLong != null
          ? FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(
                  venueProvider.locationLat!,
                  venueProvider.locationLong!,
                ),
                initialZoom: 16,
              ),

              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName:
                      'com.example.football_venue_booking_app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(
                        venueProvider.locationLat!,
                        venueProvider.locationLong!,
                      ),
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        size: 40,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            )
          : const Center(child: Text("Location not available")),
    ),
  );
}
