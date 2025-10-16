import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:football_venue_booking_app/providers/booking_provider.dart';
import 'package:football_venue_booking_app/providers/field_provider.dart';
import 'package:football_venue_booking_app/providers/venue_provider.dart';
import 'package:football_venue_booking_app/routes.dart';

class BookingDetailOwnerScreen extends StatefulWidget {
  final String bookingId;

  const BookingDetailOwnerScreen({super.key, required this.bookingId});

  @override
  State<BookingDetailOwnerScreen> createState() =>
      _BookingDetailOwnerScreenState();
}

class _BookingDetailOwnerScreenState extends State<BookingDetailOwnerScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BookingProvider>().getBookingDetailsById(widget.bookingId);

    Future.microtask(() {
      final booking = context.read<BookingProvider>().selectedBooking;
      if (booking != null) {
        context.read<FieldProvider>().loadFieldById(booking.fieldId);
        context.read<VenueProvider>().loadVenueById(booking.venueId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final fieldProvider = context.watch<FieldProvider>();
    final venueProvider = context.watch<VenueProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          bookingProvider.selectedBooking?.codeOrder ?? "Booking Details",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body:
          bookingProvider.isLoading ||
              fieldProvider.isLoading ||
              venueProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : bookingProvider.errorMessage != null
          ? Center(child: Text(bookingProvider.errorMessage!))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Stack for displaying field image and status label
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            fieldProvider.field?.fieldPhoto ??
                                'assets/images/logo.png',
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Status label on top of the image
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            color: _getStatusColor(
                              bookingProvider.selectedBooking!.status,
                            ),
                            child: Text(
                              bookingProvider.selectedBooking!.status
                                  .toUpperCase(),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Main Content in Horizontal Cards for Booking Details
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoCard(
                          "Venue Name",
                          venueProvider.venue?.name ?? '-',
                        ),
                        _buildInfoCard(
                          "Field Name",
                          fieldProvider.field?.name ?? '-',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoCard(
                          "Date",
                          bookingProvider.selectedBooking!.date
                              .toLocal()
                              .toString()
                              .split(' ')[0],
                        ),
                        _buildInfoCard(
                          "Price",
                          'Rp ${bookingProvider.selectedBooking!.price}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoCard(
                          "Start Time",
                          bookingProvider.selectedBooking!.startTime.format(
                            context,
                          ),
                        ),
                        _buildInfoCard(
                          "End Time",
                          bookingProvider.selectedBooking!.endTime.format(
                            context,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            bookingProvider.selectedBooking!.paymentReceipt ??
                                'assets/images/logo.png',
                            width: double.infinity,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Add text overlay in the center of the image
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.center, // Center the text
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              color: Colors.black.withOpacity(
                                0.5,
                              ), // Semi-transparent background
                              child: Text(
                                "Payment Receipt", // Display text over the image
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.actionBooking,
                          arguments: bookingProvider.selectedBooking!.bookingId,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Action",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // Helper method to create a row for displaying detail text inside a card
  Widget _buildInfoCard(String title, String value) {
    return Expanded(
      child: Card(
        color: Colors.white,
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

  // Helper method to return status color based on booking status
  Color _getStatusColor(String status) {
    switch (status) {
      case "pending":
        return Colors.orange;
      case "waiting":
        return Colors.blue;
      case "booked":
        return Colors.green;
      case "completed":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
