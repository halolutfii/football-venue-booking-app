import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:football_venue_booking_app/config/user_role.dart';
import 'package:football_venue_booking_app/providers/field_provider.dart';
import 'package:football_venue_booking_app/providers/venue_provider.dart';
import 'package:football_venue_booking_app/routes.dart';
import 'package:football_venue_booking_app/utils/currency_utils.dart';
import 'package:football_venue_booking_app/widgets/text_display.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';

class VenueDetailScreen extends StatefulWidget {
  final String venueId;

  const VenueDetailScreen({super.key, required this.venueId});

  @override
  State<VenueDetailScreen> createState() => _VenueDetailScreenState();
}

class _VenueDetailScreenState extends State<VenueDetailScreen> {
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

    return venueProvider.isLoading || fieldProvider.isLoading
        ? const Scaffold(body: Center(child: CircularProgressIndicator()))
        : venueProvider.errorMessage != null ||
              fieldProvider.errorMessage != null
        ? Scaffold(
            body: Center(
              child: Text(
                venueProvider.errorMessage ?? fieldProvider.errorMessage ?? '',
              ),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text(
                venueProvider.venue?.name ?? "Venue",
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
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      builder: (context) {
                        return SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                title: const Text("Edit venue"),
                                onTap: () {
                                  Navigator.pop(context);

                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.ownerForm,
                                    arguments: {
                                      "isUpdateForm": true,
                                      "venueId": venueProvider.venue!.venueId,
                                    },
                                  );
                                },
                              ),
                              ListTile(
                                title: const Text("Delete venue"),
                                onTap: () {
                                  Navigator.pop(context);

                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text("Confirm Delete"),
                                      content: const Text(
                                        "Are you sure want to delete venue?",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            venueProvider.removeVenue(
                                              widget.venueId,
                                            );

                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: const Text(
                                                  "Field deleted successfully!",
                                                ),
                                              ),
                                            );

                                            Navigator.pushReplacementNamed(
                                              context,
                                              AppRoutes.main,
                                              arguments: UserRole.owner,
                                            );
                                          },
                                          child: const Text(
                                            "Delete",
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
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
                              displayText(
                                context,
                                "Description",
                                venueProvider.venue?.description ?? '-',
                              ),
                              const SizedBox(height: 16),

                              displayText(
                                context,
                                "Contact",
                                venueProvider.venue?.contact ?? '-',
                              ),
                              const SizedBox(height: 16),

                              displayText(
                                context,
                                "Address",
                                venueProvider.venue?.address ?? '-',
                              ),
                              const SizedBox(height: 16),

                              Text(
                                "Location",
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              _buildMap(context, venueProvider),
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
                      ...fieldProvider.fields.map(
                        (field) => Card(
                          color: Colors.white,
                          child: ListTile(
                            title: Text(field.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(CurrencyUtil.format(field.defaultPrice)),
                                Text("${field.slotDuration} minutes"),
                              ],
                            ),
                            trailing: Column(
                              children: [
                                Text("Open: ${field.openingTimeStr}"),
                                Text("Close: ${field.closingTimeStr}"),
                              ],
                            ),
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.ownerDetailField,
                              arguments: field.fieldId,
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
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(
                context,
                AppRoutes.ownerFormField,
                arguments: {"isUpdateForm": false, "venueId": widget.venueId},
              ),
              label: const Text('Add new field'),
              icon: const Icon(Icons.add),
            ),
          );
  }
}

Widget _buildMap(BuildContext context, VenueProvider venueProvider) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: SizedBox(
      height: 200,
      child:
          venueProvider.venue?.locationLat != null &&
              venueProvider.venue?.locationLong != null
          ? FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(
                  venueProvider.venue!.locationLat!,
                  venueProvider.venue!.locationLong!,
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
                        venueProvider.venue!.locationLat!,
                        venueProvider.venue!.locationLong!,
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
