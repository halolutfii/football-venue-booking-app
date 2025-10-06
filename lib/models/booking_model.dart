import 'package:flutter/material.dart';

class BookingModel {
  final String? bookingId;
  final String venueId;
  final String fieldId;
  final String codeOrder;
  final int price;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String status;

  BookingModel({
    this.bookingId,
    required this.venueId,
    required this.fieldId,
    required this.codeOrder,
    required this.price,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  factory BookingModel.fromMap(Map<String, dynamic> data) {
    return BookingModel(
      bookingId: (data['uid'] ?? '').toString(),
      venueId: (data['venue_id'] ?? '').toString(),
      fieldId: (data['field_id'] ?? '').toString(),
      codeOrder: (data['code_order'] ?? data['codeOrder'] ?? '').toString(),
      price: data['price'] is int
          ? data['price']
          : int.tryParse('${data['price']}') ?? 0,
      date: _parseDate(data['date']),
      startTime:
          parseTime(data['start_time']?.toString()) ??
          const TimeOfDay(hour: 0, minute: 0),
      endTime:
          parseTime(data['end_time']?.toString()) ??
          const TimeOfDay(hour: 0, minute: 0),
      status: (data['status'] ?? 'pending').toString(),
    );
  }

  static DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is DateTime) return date;
    return DateTime.tryParse(date.toString()) ?? DateTime.now();
  }

  Map<String, dynamic> toJson() => {
    "uid": bookingId,
    "venue_id": venueId,
    "field_id": fieldId,
    "code_order": codeOrder,
    "price": price,
    "date": date.toIso8601String(),
    "start_time": formatTime(startTime),
    "end_time": formatTime(endTime),
    "status": status,
  };

  static TimeOfDay? parseTime(String? time) {
    if (time == null || time.isEmpty) return null;

    final parts = time.split(":");

    if (parts.length == 2) {
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    return null;
  }

  static String formatTime(TimeOfDay? time) {
    if (time == null) return "-";
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    return "$hour:$minute";
  }
}
