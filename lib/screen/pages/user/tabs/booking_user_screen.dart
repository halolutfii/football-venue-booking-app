import 'package:flutter/material.dart';
import 'package:football_venue_booking_app/models/field_model.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:football_venue_booking_app/providers/booking_provider.dart';
import 'package:football_venue_booking_app/providers/field_provider.dart';
import 'package:football_venue_booking_app/routes.dart';

class BookingUserScreen extends StatefulWidget {
  const BookingUserScreen({super.key});

  @override
  State<BookingUserScreen> createState() => _BookingUserScreenState();
}

class _BookingUserScreenState extends State<BookingUserScreen> {
  @override
  void initState() {
    super.initState();

    // Load bookings when screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        Provider.of<BookingProvider>(
          context,
          listen: false,
        ).getBookingByUserID(userId);
      }

      context.read<FieldProvider>().loadAllFields();
    });
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

  // Helper method to return status text based on booking status
  String _getStatusText(String status) {
    switch (status) {
      case "pending":
        return "Pending";
      case "waiting":
        return "Waiting";
      case "booked":
        return "Booked";
      case "completed":
        return "Completed";
      default:
        return "Unknown";
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final fieldProvider = context.watch<FieldProvider>();

    final orderedFields = bookingProvider.bookings.map((booking) {
      return fieldProvider.fields.firstWhere(
        (f) => f.fieldId == booking.fieldId,
        orElse: () => FieldModel.empty(),
      );
    }).toList();

    if (bookingProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (bookingProvider.errorMessage != null) {
      return Scaffold(body: Center(child: Text(bookingProvider.errorMessage!)));
    }

    // Display a message if no bookings are found
    if (bookingProvider.bookings.isEmpty) {
      return Scaffold(body: const Center(child: Text('No bookings found.')));
    }

    // Otherwise, display the bookings in a list
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: bookingProvider.bookings.length,
          itemBuilder: (context, index) {
            final booking = bookingProvider.bookings[index];
            final field = orderedFields[index];

            return Card(
              color: Colors.white,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
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
                title: Text(booking.codeOrder),
                subtitle: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(booking.status),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getStatusText(booking.status),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                onTap: () async {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.detailBookingField,
                    arguments: booking.bookingId,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
