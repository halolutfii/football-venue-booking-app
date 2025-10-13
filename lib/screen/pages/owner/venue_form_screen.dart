import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:football_venue_booking_app/config/user_role.dart';
import 'package:football_venue_booking_app/providers/venue_provider.dart';
import 'package:football_venue_booking_app/routes.dart';
import 'package:football_venue_booking_app/widgets/text_field.dart';
import 'package:latlong2/latlong.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class VenueFormScreen extends StatefulWidget {
  final bool isUpdateForm;
  final String? venueId;

  const VenueFormScreen({super.key, required this.isUpdateForm, this.venueId});

  @override
  State<VenueFormScreen> createState() => _VenueFormScreenState();
}

class _VenueFormScreenState extends State<VenueFormScreen> {
  final _formKey = GlobalKey<FormState>();

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
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Venue",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),

                            textField(
                              'Venue Name',
                              venueProvider.nameController,
                              validator: (v) => v == null || v.isEmpty
                                  ? "Venue name is required"
                                  : null,
                            ),
                            const SizedBox(height: 16),

                            textField(
                              'Description',
                              venueProvider.descriptionController,
                              maxLines: 3,
                              validator: (v) => v == null || v.isEmpty
                                  ? "Description is required"
                                  : v.length < 5
                                  ? "Description must be at least 5 characters"
                                  : null,
                            ),
                            const SizedBox(height: 16),

                            textField(
                              'Contact',
                              venueProvider.contactController,
                              inputFormatter: phoneFormatter,
                              validator: (v) => v == null || v.isEmpty
                                  ? "Contact is required"
                                  : v.replaceAll(RegExp(r'[^0-9]'), '').length <
                                        8
                                  ? "Enter a valid contact number"
                                  : null,
                            ),
                            const SizedBox(height: 16),

                            textField(
                              'Venue Address',
                              venueProvider.addressController,
                              maxLines: 2,
                              validator: (v) => v == null || v.isEmpty
                                  ? "Address is required"
                                  : v.length < 3
                                  ? "Addess must be at least 3 characters"
                                  : null,
                            ),
                            const SizedBox(height: 16),

                            venueProvider.latitude != null &&
                                    venueProvider.longitude != null
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
                                                  venueProvider.longitude ??
                                                      0.0,
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
                                : const Center(
                                    child: Text("Location not available"),
                                  ),

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
                                          content: Row(
                                            children: [
                                              Icon(Icons.error, color: Colors.white),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  venueProvider.locationPermission!,
                                                  style: TextStyle(color: Colors.white),
                                                  overflow: TextOverflow.visible,
                                                  softWrap: true,
                                                ),
                                              ),
                                            ],
                                          ),
                                          backgroundColor: Colors.green,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[350], 
                                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16), 
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8), 
                                    ),
                                  ),
                                  child: Text(
                                    "Set Location",
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) return;

                          if (venueProvider.errorMessage != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Icon(Icons.error, color: Colors.white),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        venueProvider.errorMessage!,
                                        style: TextStyle(color: Colors.white),
                                        overflow: TextOverflow.visible,
                                        softWrap: true,
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );

                            return;
                          }

                          if (venueProvider.latitude == null && venueProvider.longitude == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: const [
                                    Icon(Icons.check_circle, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text("Please set position latitude and longitude of your venue!"),
                                  ],
                                ),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );

                            return;
                          }

                          if (widget.isUpdateForm && widget.venueId != null) {
                            await venueProvider.editVenue(widget.venueId!);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: const [
                                    Icon(Icons.check_circle, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text("Venue updated successfully!"),
                                  ],
                                ),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                duration: const Duration(seconds: 2),
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
                                content: Row(
                                  children: const [
                                    Icon(Icons.check_circle, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text("Venue created successfully!"),
                                  ],
                                ),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );

                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.main,
                              arguments: UserRole.owner,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green, 
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), 
                          ),
                        ),
                        child: venueProvider.isLoading
                            ? const CircularProgressIndicator()
                            : widget.isUpdateForm
                                ? const Text(
                                    'Update Venue',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Create Venue',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
