import 'package:flutter/material.dart';
import 'package:football_venue_booking_app/routes.dart';
import 'package:provider/provider.dart';
import 'package:football_venue_booking_app/providers/field_provider.dart';
import 'package:football_venue_booking_app/providers/booking_provider.dart';
import 'package:football_venue_booking_app/models/booking_model.dart';
import 'dart:math';

class BookingFieldScreen extends StatefulWidget {
  final String fieldId;

  const BookingFieldScreen({super.key, required this.fieldId});

  @override
  _BookingFieldScreenState createState() => _BookingFieldScreenState();
}

class _BookingFieldScreenState extends State<BookingFieldScreen> {
  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> timeSlots = [];
  int? selectedSlotIndex;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    context.read<BookingProvider>().getBookingsByFieldId(widget.fieldId).then((_) {
      _generateTimeSlots();
    });
  }

  // Generate time slots for the field
  void _generateTimeSlots() {
    final fieldProvider = context.read<FieldProvider>();
    final fieldData = fieldProvider.field;

    if (fieldData == null) return;

    final openingTime = fieldData.openingTime;
    final closingTime = fieldData.closingTime;
    final defaultPrice = fieldData.defaultPrice;

    final openingHour = openingTime.hour;
    final closingHour = closingTime.hour;

    List<Map<String, dynamic>> slots = [];
    for (int i = openingHour; i <= closingHour; i += 2) {
      final startTime = '${i.toString().padLeft(2, '0')}:00';
      final endTime = '${(i + 2).toString().padLeft(2, '0')}:00';

      final isBooked = context.read<BookingProvider>().bookings.any((booking) {
        return booking.startTime.format(context) == startTime &&
            booking.endTime.format(context) == endTime;
      });

      slots.add({
        'start_time': startTime,
        'end_time': endTime,
        'price': defaultPrice,
        'is_available': !isBooked,
      });
    }

    setState(() {
      timeSlots = slots;
      isLoading = false;
    });
  }

  // Handle "Book Now" action
  void _showConfirmationDialog() {
    if (selectedSlotIndex != null) {
      final selectedSlot = timeSlots[selectedSlotIndex!];
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Text("Confirm Booking", style: TextStyle(fontWeight: FontWeight.bold,)),
            content: Text(
              'Are you sure you want to book the slot from ${selectedSlot['start_time']} to ${selectedSlot['end_time']}?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); 
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Cancel", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,)),
              ),
              TextButton(
                onPressed: () {
                  _bookSlot(selectedSlot);
                  Navigator.of(context).pop(); 
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                child: const Text("Confirm", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,)),
              ),
            ],
          );
        },
      );
    }
  }

  // Final booking method
  Future<void> _bookSlot(Map<String, dynamic> selectedSlot) async {
    final fieldProvider = context.read<FieldProvider>();
    final fieldData = fieldProvider.field;

    if (fieldData == null) return;

    // Generate order code
    String orderCode = _generateOrderCode();

    // Create a booking model
    final booking = BookingModel(
      userId: '',  
      venueId: fieldData.venueId,
      fieldId: fieldData.fieldId!,
      codeOrder: orderCode,
      price: selectedSlot['price'],
      date: selectedDate,
      startTime: TimeOfDay(hour: int.parse(selectedSlot['start_time'].split(':')[0]), minute: 0),
      endTime: TimeOfDay(hour: int.parse(selectedSlot['end_time'].split(':')[0]), minute: 0),
      status: 'pending',
    );

    // Call BookingProvider to create booking
    await context.read<BookingProvider>().createBooking(booking);

    setState(() {
      timeSlots[selectedSlotIndex!] = {
        ...selectedSlot,
        'is_available': false, 
      };
      selectedSlotIndex = null; 
    });
  }

  String _generateOrderCode() {
    final now = DateTime.now();
    final dateStr = "${now.day.toString().padLeft(2, '0')}${now.month.toString().padLeft(2, '0')}${now.year}";
    final random = Random();
    final randomDigits = random.nextInt(9000) + 1000;  
    return "$dateStr-$randomDigits";
  }

  @override
  Widget build(BuildContext context) {
    final fieldProvider = context.watch<FieldProvider>();

    if (fieldProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (fieldProvider.errorMessage != null) {
      return Scaffold(
        body: Center(child: Text(fieldProvider.errorMessage ?? 'Error fetching data')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking Field"),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Displaying Field Photo
            fieldProvider.field != null
                ? Image.network(fieldProvider.field!.fieldPhoto ?? 'assets/images/logo.png', height: 200, fit: BoxFit.cover)
                : Container(),
            const SizedBox(height: 16.0),

            // Available Time Slots
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, 
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.6,
                      ),
                      itemCount: timeSlots.length,
                      itemBuilder: (context, index) {
                        final slot = timeSlots[index];
                        return _buildTimeSlot(
                          slot['start_time'],
                          slot['end_time'],
                          slot['price'],
                          slot['is_available'],
                          index,
                        );
                      },
                    ),
                  ),
            // Show "Book Now" button if a slot is selected
            if (selectedSlotIndex != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: ElevatedButton(
                  onPressed: _showConfirmationDialog, 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Book Now", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold,)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Widget for displaying time slots
  Widget _buildTimeSlot(String startTime, String endTime, int price, bool isAvailable, int index) {
    return GestureDetector(
      onTap: () {
        if (isAvailable) {
          setState(() {
            selectedSlotIndex = index; 
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isAvailable && selectedSlotIndex == index ? Colors.grey[150] : (isAvailable ? Colors.white : Colors.grey[300]),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text('$startTime - $endTime'),
            Text('Rp $price'),
            Text(isAvailable ? 'Available' : 'Booked', style: TextStyle(color: isAvailable ? Colors.green : Colors.red)),
          ],
        ),
      ),
    );
  }
}