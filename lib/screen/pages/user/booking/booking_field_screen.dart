import 'dart:math';

import 'package:flutter/material.dart';
import 'package:football_venue_booking_app/models/booking_model.dart';
import 'package:football_venue_booking_app/providers/booking_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../providers/field_provider.dart';
import 'package:football_venue_booking_app/utils/currency_utils.dart';
import '../../../../routes.dart';

class BookingFieldScreen extends StatefulWidget {
  final String fieldId;

  const BookingFieldScreen({super.key, required this.fieldId});

  @override
  State<BookingFieldScreen> createState() => _BookingFieldScreenState();
}

class _BookingFieldScreenState extends State<BookingFieldScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<FieldProvider>().loadFieldById(widget.fieldId);
    });

    Future.microtask(
      () => context.read<FieldProvider>().generateSchedule(widget.fieldId),
    );
  }

  // Handle "Book Now" action
  void _showConfirmationDialog() {
    final fieldProvider = context.read<FieldProvider>();
    final selectedSlotIndex = fieldProvider.selectedSlotIndex;
    final slots = fieldProvider.selectedDaySlots;

    if (fieldProvider.selectedSlotIndex != null) {
      final selectedSlot = slots[selectedSlotIndex!];
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Text(
              "Confirm Booking",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text(
              'Are you sure you want to book the slot from ${DateFormat.Hm().format(selectedSlot['start_time'])} to ${DateFormat.Hm().format(selectedSlot['end_time'])}?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  _bookSlot(selectedSlot);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Confirm",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
      date: fieldProvider.selectedDate!,
      startTime: TimeOfDay(
        hour: selectedSlot['start_time'].hour,
        minute: selectedSlot['start_time'].minute,
      ),
      endTime: TimeOfDay(
        hour: selectedSlot['end_time'].hour,
        minute: selectedSlot['start_time'].minute,
      ),
      status: 'pending',
    );

    // Call BookingProvider to create booking
    final bookingId = await context.read<BookingProvider>().createBooking(
      booking,
    );

    if (bookingId != null) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.detailBookingField,
        arguments: bookingId,
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal membuat booking')));
    }
  }

  String _generateOrderCode() {
    final now = DateTime.now();
    final dateStr =
        "${now.day.toString().padLeft(2, '0')}${now.month.toString().padLeft(2, '0')}${now.year}";
    final random = Random();
    final randomDigits = random.nextInt(9000) + 1000;
    return "$dateStr-$randomDigits";
  }

  @override
  Widget build(BuildContext context) {
    final fieldProvider = context.watch<FieldProvider>();
    final availableDates = fieldProvider.availableDates;
    final selected = fieldProvider.selectedDate;
    final slots = fieldProvider.selectedDaySlots;

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
              body: Center(
                child: Text(
                  fieldProvider.errorMessage ?? 'Error fetching data',
                ),
              ),
            )
          : SafeArea(
              child: Stack(
                children: [
                  // ===== Konten Scrollable =====
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Field Image + Card Info
                        SizedBox(
                          height: 320,
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: fieldProvider.field?.fieldPhoto != null
                                    ? Image.network(
                                        fieldProvider.field!.fieldPhoto!,
                                        width: double.infinity,
                                        height: 220,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: double.infinity,
                                        height: 220,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.image_outlined,
                                          size: 48,
                                          color: Colors.grey,
                                        ),
                                      ),
                              ),

                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Card(
                                    color: Colors.white,
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Jam Operasional
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "${fieldProvider.field?.openingTimeStr ?? '-'} - ${fieldProvider.field?.closingTimeStr ?? '-'}",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),

                                          // Harga dan Durasi
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                fieldProvider
                                                            .field
                                                            ?.defaultPrice !=
                                                        null
                                                    ? CurrencyUtil.format(
                                                        fieldProvider
                                                            .field!
                                                            .defaultPrice,
                                                      )
                                                    : '-',
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                ),
                                              ),
                                              Text(
                                                "${fieldProvider.field?.slotDurationStr ?? '-'} minutes",
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 8),
                                          const Divider(),
                                          const SizedBox(height: 8),

                                          // Spesifikasi
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Specifications',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                fieldProvider
                                                        .field
                                                        ?.specifications ??
                                                    '-',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black87,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        SizedBox(
                          height: 80,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: availableDates.length,
                            itemBuilder: (context, index) {
                              final date = availableDates[index];
                              final isSelected =
                                  selected != null &&
                                  date.year == selected.year &&
                                  date.month == selected.month &&
                                  date.day == selected.day;

                              final dayName = DateFormat(
                                'E',
                              ).format(date).toUpperCase();
                              final dayNum = DateFormat('d MMM').format(date);

                              return GestureDetector(
                                onTap: () => fieldProvider.selectDate(date),
                                child: Container(
                                  width: 70,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.grey.shade200
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        dayName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        dayNum,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        ListView.builder(
                          padding: const EdgeInsets.all(12),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: slots.length,
                          itemBuilder: (context, index) {
                            final slot = slots[index];
                            final isBooked = slot['status'] == 'booked';
                            final isSelected =
                                fieldProvider.selectedSlotIndex == index;

                            return GestureDetector(
                              onTap: isBooked
                                  ? null
                                  : () {
                                      fieldProvider.selectSlot(index);
                                    },
                              child: Card(
                                color: isBooked
                                    ? Colors.red.shade50
                                    : isSelected
                                    ? Colors.grey.shade50
                                    : Colors.white,
                                elevation: 1,
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                child: ListTile(
                                  leading: Icon(
                                    Icons.access_time,
                                    color: isBooked
                                        ? Colors.redAccent
                                        : Colors.green.shade700,
                                  ),
                                  title: Text(
                                    "${DateFormat.Hm().format(slot['start_time'])} - ${DateFormat.Hm().format(slot['end_time'])}",
                                  ),
                                  subtitle: Text(
                                    fieldProvider.field?.defaultPrice != null
                                        ? CurrencyUtil.format(
                                            fieldProvider.field!.defaultPrice,
                                          )
                                        : '-',
                                  ),
                                  trailing: Text(
                                    isBooked ? 'Booked' : 'Available',
                                    style: TextStyle(
                                      color: isBooked
                                          ? Colors.redAccent
                                          : Colors.green.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(
                          height: 100,
                        ), // ruang biar ga ketutupan tombol
                      ],
                    ),
                  ),

                  if (fieldProvider.selectedSlotIndex != null)
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: FloatingActionButton.extended(
                        onPressed: _showConfirmationDialog,
                        backgroundColor: Colors.green,
                        label: const Text(
                          "Book Now",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
