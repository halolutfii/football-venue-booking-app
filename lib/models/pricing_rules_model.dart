import 'package:flutter/material.dart';

class PricingRulesModel {
  final String? pricingRuleId;
  final String fieldId;
  final int? dayOfWeek;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final int pricePerDuration;

  PricingRulesModel({
    this.pricingRuleId,
    required this.fieldId,
    this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.pricePerDuration,
  });

  factory PricingRulesModel.fromMap(Map<String, dynamic> data) {
    return PricingRulesModel(
      pricingRuleId: data['uid'] ?? '',
      fieldId: data['field_id'] ?? '',
      dayOfWeek: data['day_of_week'] ?? 0,
      startTime:
          parseTime(data['start_time']) ?? const TimeOfDay(hour: 0, minute: 0),
      endTime:
          parseTime(data['end_time']) ?? const TimeOfDay(hour: 23, minute: 59),
      pricePerDuration: data['price_per_duration'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "uid": pricingRuleId,
    "field_id": fieldId,
    "day_of_week": dayOfWeek,
    "start_time": formatTime(startTime),
    "end_time": formatTime(endTime),
    "price_per_duration": pricePerDuration,
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
