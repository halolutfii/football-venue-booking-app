import 'package:flutter/material.dart';

class FieldModel {
  final String? fieldId;
  final String venueId;
  final String name;
  final int defaultPrice;
  final String specifications;
  final TimeOfDay openingTime;
  final TimeOfDay closingTime;
  final int slotDuration;
  final String? fieldPhoto;

  FieldModel({
    this.fieldId,
    required this.venueId,
    required this.name,
    required this.defaultPrice,
    required this.specifications,
    required this.openingTime,
    required this.closingTime,
    required this.slotDuration,
    this.fieldPhoto,
  });

  factory FieldModel.fromMap(Map<String, dynamic> data) => FieldModel(
    fieldId: data['uid'],
    venueId: data['venue_id'],
    name: data['name'],
    defaultPrice: (data['default_price'] as num).toInt(),
    specifications: data['specifications'],
    openingTime: parseTime(data['opening_time'])!,
    closingTime: parseTime(data['closing_time'])!,
    slotDuration: (data['slot_duration'] as num).toInt(),
    fieldPhoto: data['field_photo'],
  );

  Map<String, dynamic> toJson() => {
    "uid": fieldId,
    "venue_id": venueId,
    "name": name,
    "default_price": defaultPrice,
    "specifications": specifications,
    "opening_time": formatTime(openingTime),
    "closing_time": formatTime(closingTime),
    "slot_duration": slotDuration,
    "field_photo": fieldPhoto ?? '',
  };

  FieldModel copyWith({
    String? fieldId,
    String? venueId,
    String? name,
    int? defaultPrice,
    String? specifications,
    TimeOfDay? openingTime,
    TimeOfDay? closingTime,
    int? slotDuration,
    String? fieldPhoto,
  }) {
    return FieldModel(
      fieldId: fieldId ?? this.fieldId,
      venueId: venueId ?? this.venueId,
      name: name ?? this.name,
      defaultPrice: defaultPrice ?? this.defaultPrice,
      specifications: specifications ?? this.specifications,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      slotDuration: slotDuration ?? this.slotDuration,
      fieldPhoto: fieldPhoto ?? this.fieldPhoto,
    );
  }

  String get defaultPriceStr => defaultPrice.toString();
  String get slotDurationStr => slotDuration.toString();
  String get openingTimeStr => formatTime(openingTime);
  String get closingTimeStr => formatTime(closingTime);

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
