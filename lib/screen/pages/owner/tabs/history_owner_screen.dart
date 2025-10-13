import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:football_venue_booking_app/providers/booking_provider.dart';
import 'package:football_venue_booking_app/routes.dart';

class HistoryOwnerScreen extends StatefulWidget {
  const HistoryOwnerScreen({super.key});

  @override
  _HistoryOwnerScreenState createState() => _HistoryOwnerScreenState();
}

class _HistoryOwnerScreenState extends State<HistoryOwnerScreen> {
  @override
  void initState() {
    super.initState();

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      Future.microtask(() =>
          Provider.of<BookingProvider>(context, listen: false).loadBookingHistory(userId)
      );
    }
  }

  // Helper method to return status color based on booking status
  Color _getStatusColor(String status) {
    switch (status) {
      case "completed":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Helper method to return status text based on booking status
  String _getStatusText(String status) {
    switch (status) {
      case "completed":
        return "Completed";
      default:
        return "Unknown";
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingHistoryProvider = context.watch<BookingProvider>();

    if (bookingHistoryProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (bookingHistoryProvider.errorMessage != null) {
      return Scaffold(
        body: Center(child: Text(bookingHistoryProvider.errorMessage!)),
      );
    }

    if (bookingHistoryProvider.bookingsWithFieldData.isEmpty) {
      return Scaffold(
        body: const Center(child: Text('No bookings history found.')),
      );
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: bookingHistoryProvider.bookingsWithFieldData.length,
          itemBuilder: (context, index) {
            final bookingMap = bookingHistoryProvider.bookingsWithFieldData[index];
            final booking = bookingMap['booking'];
            final fieldData = bookingMap['field']; 

            return Card(
              color: Colors.white,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                leading: fieldData != null
                    ? Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          image: DecorationImage(
                            image: fieldData['field_photo'] != null
                                ? NetworkImage(fieldData['field_photo']) 
                                : const AssetImage('assets/images/logo.png') as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      )
                    : const Icon(Icons.error),
                title: Text(booking.codeOrder),  
                subtitle: Row(
                  children: [
                    // Display status of booking
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(booking.status),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getStatusText(booking.status),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                onTap: () async {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.detailBookingHistoryOwnerField,
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