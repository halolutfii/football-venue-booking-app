import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:football_venue_booking_app/models/venue_model.dart';

class VenueService {
  final CollectionReference _venues = FirebaseFirestore.instance.collection(
    'venues',
  );

  Future<VenueModel?> getVenueById(String venueId) async {
    final doc = await _venues.doc(venueId).get();

    return VenueModel.fromMap(doc.data() as Map<String, dynamic>);
  }

  Future<List<VenueModel>> getVenues(String userId) async {
    final snapshot = await _venues.where("user_id", isEqualTo: userId).get();

    return snapshot.docs
        .map((doc) => VenueModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<List<VenueModel>> getAllVenues() async {
    final snapshot = await _venues.get();

    return snapshot.docs
        .map((doc) => VenueModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> createVenue(VenueModel venue) async {
    final docRef = _venues.doc();
    final newVenue = venue.copyWith(venueId: docRef.id);

    await docRef.set(newVenue.toJson());
  }

  Future<void> updateVenue(VenueModel venue) async {
    await _venues.doc(venue.venueId).update(venue.toJson());
  }

  Future<void> deleteVenue(String venueId) async {
    await _venues.doc(venueId).delete();
  }
}
