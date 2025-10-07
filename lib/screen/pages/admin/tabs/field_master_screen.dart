import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:football_venue_booking_app/providers/master_provider.dart';
import 'package:football_venue_booking_app/routes.dart';

class FieldMasterScreen extends StatefulWidget {
  const FieldMasterScreen({super.key});

  @override
  _FieldMasterScreenState createState() => _FieldMasterScreenState();
}

class _FieldMasterScreenState extends State<FieldMasterScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<MasterProvider>().loadAllFields());
  }

  @override
  Widget build(BuildContext context) {
    var fieldMasterProvider = context.watch<MasterProvider>();
    var fieldsMaster = fieldMasterProvider.fields; 

    if (fieldMasterProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (fieldsMaster.isEmpty) {
      return const Center(child: Text("No fields available for this venue."));
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: fieldsMaster.length,
          itemBuilder: (context, index) {
            final field = fieldsMaster[index];

            return Card(
              color: Colors.white,
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                leading: field.fieldPhoto != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          field.fieldPhoto!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Container(
                        width: 50,
                        height: 50,
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
                title: Text(field.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.detailField,
                  arguments: field.fieldId,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}