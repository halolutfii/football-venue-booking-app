import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:football_venue_booking_app/models/booking_model.dart';
import 'package:football_venue_booking_app/models/field_model.dart';
import 'package:football_venue_booking_app/models/pricing_rules_model.dart';

class ScheduleService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Map<String, List<Map<String, dynamic>>>> generateSchedule({
    required String fieldId,
    required DateTime currentDate,
    required DateTime endDate,
  }) async {
    // ambil data Field by field id
    final fieldDoc = await _db.collection('fields').doc(fieldId).get();

    if (!fieldDoc.exists) throw Exception("Field not found");

    final field = FieldModel.fromMap(fieldDoc.data() as Map<String, dynamic>);

    // ambil data Pricing Rules
    final rulesSnap = await _db
        .collection('pricing_rules')
        .where('field_id', isEqualTo: fieldId)
        .get();

    final rules = rulesSnap.docs
        .map((doc) => PricingRulesModel.fromMap(doc.data()))
        .toList();

    // ambil data Booking
    final bookingsSnap = await _db
        .collection('bookings')
        .where('field_id', isEqualTo: fieldId)
        .get();

    final bookings = bookingsSnap.docs.map((doc) {
      return BookingModel.fromMap(doc.data());
    }).toList();

    final allSchedules = <String, List<Map<String, dynamic>>>{};
    DateTime startDate = currentDate;

    while (!startDate.isAfter(endDate)) {
      final schedule = _generateScheduleOnTheFly(
        field: field,
        rules: rules,
        bookings: bookings,
        date: startDate,
      );

      final formattedDate = _formatDate(startDate);
      allSchedules[formattedDate] = schedule;

      startDate = startDate.add(const Duration(days: 1));
    }

    return allSchedules;
  }

  // generate slot buat satu hari schedule
  List<Map<String, dynamic>> _generateScheduleOnTheFly({
    required FieldModel field,
    required List<PricingRulesModel> rules,
    required List<BookingModel> bookings,
    required DateTime date,
  }) {
    final slotDuration = field.slotDuration;
    final openingTime = _combineDateAndTime(date, field.openingTime);
    final closingTime = _combineDateAndTime(date, field.closingTime);
    final defaultPrice = field.defaultPrice;

    List<Map<String, dynamic>> schedule = [];
    DateTime slotStart = openingTime;

    final bookingsForDay = bookings
        .where(
          (b) =>
              b.date.year == date.year &&
              b.date.month == date.month &&
              b.date.day == date.day,
        )
        .toList();

    while (slotStart.isBefore(closingTime)) {
      final slotEnd = slotStart.add(Duration(minutes: slotDuration));
      // cek slot kalo lebih dari closing time
      if (slotEnd.isAfter(closingTime)) break;

      // hitung harga berdasarkan rules
      final price = _getPriceForSlot(
        rules: rules,
        dayOfWeek: date.weekday,
        slotStart: slotStart,
        slotEnd: slotEnd,
        defaultPrice: defaultPrice,
      );

      // Cek slot sudah dibooking
      final booked = bookingsForDay.any((b) {
        final bookingStart = DateTime(
          b.date.year,
          b.date.month,
          b.date.day,
          b.startTime.hour,
          b.startTime.minute,
        );

        final bookingEnd = DateTime(
          b.date.year,
          b.date.month,
          b.date.day,
          b.endTime.hour,
          b.endTime.minute,
        );

        // batas slot end sama kayak slot start (10-12 12-14)
        return bookingStart.isBefore(slotEnd) && bookingEnd.isAfter(slotStart);
      });

      schedule.add({
        'start_time': slotStart,
        'end_time': slotEnd,
        'price': price,
        'status': booked ? 'booked' : 'available',
      });

      slotStart = slotEnd;
    }

    return schedule;
  }

  String _formatDate(DateTime date) =>
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
}

DateTime _combineDateAndTime(DateTime date, TimeOfDay time) {
  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}

int _getPriceForSlot({
  required List<PricingRulesModel> rules,
  required int dayOfWeek,
  required DateTime slotStart,
  required DateTime slotEnd,
  required int defaultPrice,
}) {
  for (var rule in rules) {
    if (rule.dayOfWeek != null && rule.dayOfWeek != dayOfWeek) continue;

    final ruleStart = _combineDateAndTime(slotStart, rule.startTime);
    final ruleEnd = _combineDateAndTime(slotStart, rule.endTime);

    final bool inRange =
        (slotStart.isAtSameMomentAs(ruleStart) ||
            slotStart.isAfter(ruleStart)) &&
        slotEnd.isBefore(ruleEnd.add(const Duration(seconds: 1)));

    if (inRange) return rule.pricePerDuration;
  }

  return defaultPrice;
}
