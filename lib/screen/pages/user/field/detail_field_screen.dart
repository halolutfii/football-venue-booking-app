import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/field_provider.dart';
import 'package:football_venue_booking_app/utils/currency_utils.dart';

class DetailScreen extends StatefulWidget {
  final String fieldId;

  const DetailScreen({super.key, required this.fieldId});

  @override
  _DetailFieldScreenState createState() => _DetailFieldScreenState();
}

class _DetailFieldScreenState extends State<DetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<FieldProvider>().loadFieldById(widget.fieldId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final fieldProvider = context.watch<FieldProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          fieldProvider.field?.name ?? "Field Details",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
          icon: Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: fieldProvider.isLoading
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : fieldProvider.errorMessage != null
              ? Scaffold(
                  body: Center(child: Text(fieldProvider.errorMessage ?? 'Error fetching data')))
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Field Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            fieldProvider.field?.fieldPhoto ?? 'assets/images/logo.png',
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Main Content in Horizontal Cards
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoCard("Specifications", fieldProvider.field?.specifications ?? '-'),
                            // Add more fields as necessary
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoCard("Slot Duration", "${fieldProvider.field?.slotDurationStr ?? '-'} minutes"),
                            _buildInfoCard("Default Price", "${fieldProvider.field?.defaultPrice != null
                                ? CurrencyUtil.format(fieldProvider.field!.defaultPrice)
                                : '-'}/hours"),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoCard("Opening Time", fieldProvider.field?.openingTimeStr ?? '-'),
                            _buildInfoCard("Closing Time", fieldProvider.field?.closingTimeStr ?? '-'),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Book Now Button
                        ElevatedButton(
                          onPressed: () {
                            // Add your booking functionality here
                            // For example, navigate to the booking screen
                            // Navigator.pushNamed(context, '/bookingScreen', arguments: fieldProvider.field!.fieldId);
                          },
                          child: Text("Book Now"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green, // Button color
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
    );
  }

  // Helper function to create info cards horizontally
  Widget _buildInfoCard(String title, String value) {
    return Expanded(
      child: Card(
        color: Colors.white,
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(fontSize: 14, color: Colors.black87),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}