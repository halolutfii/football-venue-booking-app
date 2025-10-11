import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../providers/venue_provider.dart';
import '../../../../providers/field_provider.dart';
import 'package:football_venue_booking_app/utils/currency_utils.dart';
import 'package:football_venue_booking_app/routes.dart';

class DetailVenueScreen extends StatefulWidget {
  final String venueId; 

  const DetailVenueScreen({super.key, required this.venueId});

  @override
  _DetailVenueScreenState createState() => _DetailVenueScreenState();
}

class _DetailVenueScreenState extends State<DetailVenueScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<VenueProvider>().loadVenueById(widget.venueId); 
      context.read<FieldProvider>().loadFields(widget.venueId); 
    });
  }

  @override
  Widget build(BuildContext context) {
    final venueProvider = context.watch<VenueProvider>();
    final fieldProvider = context.watch<FieldProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          venueProvider.venue?.name ?? "Venue Details",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: venueProvider.isLoading || fieldProvider.isLoading
          ? const Center(child: CircularProgressIndicator()) 
          : venueProvider.errorMessage != null || fieldProvider.errorMessage != null
              ? Center(child: Text(venueProvider.errorMessage ?? fieldProvider.errorMessage ?? '')) 
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Venue Information Card
                        Card(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Venue Name: ${venueProvider.venue?.name ?? '-'}",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Address: ${venueProvider.venue?.address ?? '-'}",
                                  style: TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Description: ${venueProvider.venue?.description ?? '-'}",
                                  style: TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 16),
                                // Location Map
                                Text(
                                  "Location",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                _buildMap(context, venueProvider),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Fields Section
                        Text(
                          "Fields :",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        fieldProvider.fields.isEmpty
                            ? Text("No fields available for this venue.")
                            : Column(
                                children: fieldProvider.fields.map((field) {
                                  return Card(
                                    color: Colors.white,
                                    child: ListTile(
                                      leading: field.fieldPhoto != null
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: Image.network(
                                                field.fieldPhoto!,
                                                width: 100,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : Container(
                                              width: 100,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[300],
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Icon(
                                                Icons.image_outlined,
                                                size: 48,
                                                color: Colors.grey,
                                              ),
                                            ),
                                      title: Text(field.name),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(CurrencyUtil.format(field.defaultPrice)),
                                          Text("Open: ${field.openingTimeStr ?? '-'}"),
                                          Text("Close: ${field.closingTimeStr ?? '-'}"),
                                        ],
                                      ),
                                      trailing: Text("${field.slotDuration} minutes"),
                                      onTap: () => Navigator.pushNamed(
                                        context,
                                        AppRoutes.detailField,
                                        arguments: field.fieldId,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                      ],
                    ),
                  ),
                ),
            );
  }
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