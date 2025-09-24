class VenueModel {
  final String? venueId;
  final String userId;
  final String name;
  final double? locationLat;
  final double? locationLong;
  final String? address;
  final String? description;
  final String? contact;

  VenueModel({
    this.venueId,
    required this.userId,
    required this.name,
    this.locationLat,
    this.locationLong,
    this.address,
    this.description,
    this.contact,
  });

  factory VenueModel.fromMap(Map<String, dynamic> data) {
    return VenueModel(
      venueId: data['uid'],
      userId: data['user_id'],
      name: data['name'],
      locationLat: data['location_lat'] != null
          ? double.tryParse(data['location_lat'])
          : null,
      locationLong: data['location_long'] != null
          ? double.tryParse(data['location_lat'])
          : null,
      address: data['address'],
      description: data['description'],
      contact: data['contact'],
    );
  }

  Map<String, dynamic> toJson() => {
    "uid": venueId,
    "user_id": userId,
    "name": name,
    "location_lat": locationLat.toString(),
    "location_long": locationLong.toString(),
    "address": address,
    "description": description,
    "contact": contact,
  };

  VenueModel copyWith({
    String? venueId,
    String? userId,
    String? name,
    double? locationLat,
    double? locationLong,
    String? address,
    String? description,
    String? contact,
  }) {
    return VenueModel(
      venueId: venueId ?? this.venueId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      locationLat: locationLat ?? this.locationLat,
      locationLong: locationLong ?? this.locationLong,
      address: address ?? this.address,
      description: description ?? this.description,
      contact: contact ?? this.contact,
    );
  }
}
