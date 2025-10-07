import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../providers/venue_provider.dart';
import 'package:football_venue_booking_app/routes.dart';

class DetailVenueAdminScreen extends StatefulWidget {
  final String venueId; 

  const DetailVenueAdminScreen({super.key, required this.venueId});

  @override
  _DetailVenueAdminScreenState createState() => _DetailVenueAdminScreenState();
}

class _DetailVenueAdminScreenState extends State<DetailVenueAdminScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<VenueProvider>().loadVenueById(widget.venueId); 
    });
  }

  @override
  Widget build(BuildContext context) {
    final venueProvider = context.watch<VenueProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          venueProvider.venue?.name ?? "Venue Details",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: venueProvider.isLoading
          ? const Center(child: CircularProgressIndicator()) 
          : venueProvider.errorMessage != null
              ? Center(child: Text(venueProvider.errorMessage ?? ''))
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Map Section in a Card
                        Card(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                _buildMap(context, venueProvider),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Venue Information in a separate Card
                        Card(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildVenueInformation(context, venueProvider),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            );
  }

  // Build venue information section (address, contact, description)
  Widget _buildVenueInformation(BuildContext context, VenueProvider venueProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Venue Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        if (venueProvider.venue?.address != null)
          _buildListTile(Icons.location_on, "${venueProvider.venue?.address ?? 'Not Available'}"),
        if (venueProvider.venue?.contact != null)
          _buildListTile(Icons.phone, "${venueProvider.venue?.contact ?? 'Not Available'}"),
        if (venueProvider.venue?.description != null)
          _buildListTile(Icons.description, "${venueProvider.venue?.description ?? 'Not Available'}"),
      ],
    );
  }

  // Build list tile for venue sections like address, contact, description, etc.
  Widget _buildListTile(IconData icon, String title) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.black87),
      title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  // Map Widget to show venue location on map
  Widget _buildMap(BuildContext context, VenueProvider venueProvider) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: 200,
        child: venueProvider.venue?.locationLat != null && venueProvider.venue?.locationLong != null
            ? FlutterMap(
                options: MapOptions(
                  center: LatLng(
                    venueProvider.venue!.locationLat,
                    venueProvider.venue!.locationLong,
                  ),
                  zoom: 16,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.football_venue_booking_app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(
                          venueProvider.venue!.locationLat,
                          venueProvider.venue!.locationLong,
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
}