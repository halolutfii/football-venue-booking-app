class FieldModel {
  final String? fieldId;
  final String venueId;
  final String name;
  final int defaultPrice;
  final String specifications;
  final String openingTime;
  final String closingTime;
  final int slotDuration;

  FieldModel({
    this.fieldId,
    required this.venueId,
    required this.name,
    required this.defaultPrice,
    required this.specifications,
    required this.openingTime,
    required this.closingTime,
    required this.slotDuration,
  });

  factory FieldModel.fromMap(Map<String, dynamic> data) => FieldModel(
    fieldId: data['uid'],
    venueId: data['venue_id'],
    name: data['name'],
    defaultPrice: (data['default_price'] as num).toInt(),
    specifications: data['specifications'],
    openingTime: data['opening_time'],
    closingTime: data['closing_time'],
    slotDuration: (data['slot_duration'] as num).toInt(),
  );

  Map<String, dynamic> toJson() => {
    "uid": fieldId,
    "venue_id": venueId,
    "name": name,
    "default_price": defaultPrice,
    "specifications": specifications,
    "opening_time": openingTime,
    "closing_time": closingTime,
    "slot_duration": slotDuration,
  };

  FieldModel copyWith({
    String? fieldId,
    String? venueId,
    String? name,
    int? defaultPrice,
    String? specifications,
    String? openingTime,
    String? closingTime,
    int? slotDuration,
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
    );
  }
}
