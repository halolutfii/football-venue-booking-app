import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:football_venue_booking_app/providers/venue_provider.dart';
import 'package:football_venue_booking_app/routes.dart';
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
    if (widget.venueId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<VenueProvider>().loadVenueById(widget.venueId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final VenueProvider venueProvider = context.watch<VenueProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Form Screen'),
        automaticallyImplyLeading: false,
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
                      _buildTextField(
                        'Venue Name',
                        venueProvider.nameController,
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        'Description',
                        venueProvider.descriptionController,
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        'Contact',
                        venueProvider.contactController,
                        phoneFormatter,
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        'Venue Address',
                        venueProvider.addressController,
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              venueProvider.latitude == null &&
                                      venueProvider.longitude == null
                                  ? "Location is not found"
                                  : "Lat: ${venueProvider.latitude}, Lng: ${venueProvider.longitude}",
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              await venueProvider.getLocation(context);

                              if (venueProvider.locationPermission != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      venueProvider.locationPermission!,
                                    ),
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
              ),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.ownerHome,
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (widget.venueId != null) {
                          await venueProvider.editVenue(widget.venueId!);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                "Venue updated successfully!",
                              ),
                            ),
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
                        }

                        if (venueProvider.errorMessage != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(venueProvider.errorMessage!),
                            ),
                          );

                          return;
                        }

                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.ownerHome,
                        );
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

Widget _buildTextField(
  String label,
  TextEditingController controller, [
  TextInputFormatter? inputFormatter,
]) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[700]),
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    inputFormatters: inputFormatter != null ? [inputFormatter] : [],
  );
}
