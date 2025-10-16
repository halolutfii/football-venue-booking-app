import 'package:flutter/material.dart';

class BookingModel {
  final String? bookingId;
  final String userId;
  final String venueId;
  final String fieldId;
  final String codeOrder;
  final int price;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String status;
  final String? paymentReceipt;

  BookingModel({
    this.bookingId,
    required this.userId,
    required this.venueId,
    required this.fieldId,
    required this.codeOrder,
    required this.price,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.paymentReceipt,
  });

  BookingModel copyWith({
    String? bookingId,
    String? userId,
    String? venueId,
    String? fieldId,
    String? codeOrder,
    int? price,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? status,
    String? paymentReceipt,
  }) {
    return BookingModel(
      bookingId: bookingId ?? this.bookingId,
      userId: userId ?? this.userId,
      venueId: venueId ?? this.venueId,
      fieldId: fieldId ?? this.fieldId,
      codeOrder: codeOrder ?? this.codeOrder,
      price: price ?? this.price,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      paymentReceipt: paymentReceipt ?? this.paymentReceipt,
    );
  }

  factory BookingModel.fromMap(Map<String, dynamic> data) {
    return BookingModel(
      bookingId: data['uid']?.toString(),
      userId: data['user_id']?.toString() ?? '',
      venueId: data['venue_id']?.toString() ?? '',
      fieldId: data['field_id']?.toString() ?? '',
      codeOrder: data['code_order']?.toString() ?? '',
      price: data['price'] ?? 0,
      date:
          DateTime.tryParse(data['date'].toString())?.toLocal() ??
          DateTime.now(),
      startTime: _parseTime(data['start_time']?.toString() ?? '00:00'),
      endTime: _parseTime(data['end_time']?.toString() ?? '00:00'),
      status: data['status']?.toString() ?? 'pending',
      paymentReceipt: data['payment_receipt']?.toString(),
    );
  }

  static TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;

    return TimeOfDay(hour: hour, minute: minute);
  }

  Map<String, dynamic> toJson() {
    return {
      "uid": bookingId,
      "user_id": userId,
      "venue_id": venueId,
      "field_id": fieldId,
      "code_order": codeOrder,
      "price": price,
      "date": date.toIso8601String(),
      "start_time": _formatTime(startTime),
      "end_time": _formatTime(endTime),
      "status": status,
      "payment_receipt": paymentReceipt,
    };
  }

  static String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }
}
