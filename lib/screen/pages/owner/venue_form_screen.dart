import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:football_venue_booking_app/config/user_role.dart';
import 'package:football_venue_booking_app/providers/venue_provider.dart';
import 'package:football_venue_booking_app/routes.dart';
import 'package:football_venue_booking_app/widgets/text_field.dart';
import 'package:latlong2/latlong.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';

class VenueFormScreen extends StatefulWidget {
  final bool isUpdateForm;
  final String? venueId;

  const VenueFormScreen({super.key, required this.isUpdateForm, this.venueId});

  @override
  State<VenueFormScreen> createState() => _VenueFormScreenState();
}

class _VenueFormScreenState extends State<VenueFormScreen> {
  final phoneFormatter = MaskTextInputFormatter(
    mask: '+62 ###-####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void initState() {
    super.initState();
    final venueProvider = context.read<VenueProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isUpdateForm && widget.venueId != null) {
        venueProvider.loadVenueById(widget.venueId!);
      } else {
        venueProvider.resetForm();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final VenueProvider venueProvider = context.watch<VenueProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Venue Form',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            if (widget.isUpdateForm) {
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.ownerDetailVenue,
                arguments: venueProvider.venue!.venueId,
              );
            } else {
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.main,
                arguments: UserRole.owner,
              );
            }
          },
          icon: Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildVenueForm(context, venueProvider),

                      const SizedBox(height: 8),

                      // _buildFieldForm(context, venueProvider),
                    ],
                  ),
                ),
              ),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (widget.isUpdateForm && widget.venueId != null) {
                          await venueProvider.editVenue(widget.venueId!);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                "Venue updated successfully!",
                              ),
                            ),
                          );

                          Navigator.pushNamed(
                            context,
                            AppRoutes.ownerDetailVenue,
                            arguments: widget.venueId,
                          );
                        } else {
                          await venueProvider.addVenue();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                "Venue created successfully!",
                              ),
                            ),
                          );

                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.main,
                            arguments: UserRole.owner,
                          );
                        }

                        if (venueProvider.errorMessage != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(venueProvider.errorMessage!),
                            ),
                          );

                          return;
                        }
                      },
                      child: venueProvider.isLoading
                          ? const CircularProgressIndicator()
                          : widget.isUpdateForm
                          ? const Text('Update Venue')
                          : const Text('Create Venue'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildVenueForm(BuildContext context, VenueProvider venueProvider) {
  final phoneFormatter = MaskTextInputFormatter(
    mask: '+62 ###-####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  return Card(
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Venue",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          textField('Venue Name', venueProvider.nameController),
          const SizedBox(height: 16),

          textField(
            'Description',
            venueProvider.descriptionController,
            maxLines: 3,
          ),
          const SizedBox(height: 16),

          textField(
            'Contact',
            venueProvider.contactController,
            inputFormatter: phoneFormatter,
          ),
          const SizedBox(height: 16),

          textField(
            'Venue Address',
            venueProvider.addressController,
            maxLines: 2,
          ),
          const SizedBox(height: 16),

          venueProvider.latitude != null && venueProvider.longitude != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    height: 200,
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(
                          venueProvider.latitude ?? 0.0,
                          venueProvider.longitude ?? 0.0,
                        ),
                        initialZoom: 16,
                      ),

                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName:
                              'com.example.football_venue_booking_app',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(
                                venueProvider.latitude ?? 0.0,
                                venueProvider.longitude ?? 0.0,
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
                    ),
                  ),
                )
              : const Center(child: Text("Location not available")),

          Row(
            children: [
              Expanded(
                child: Text(
                  venueProvider.latitude != null &&
                          venueProvider.longitude != null
                      ? "Lat: ${venueProvider.latitude}, Lng: ${venueProvider.longitude}"
                      : "",
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  await venueProvider.getLocation(context);

                  if (venueProvider.locationPermission != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(venueProvider.locationPermission!),
                      ),
                    );
                  }
                },
                child: Text("Set Location"),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );
}
