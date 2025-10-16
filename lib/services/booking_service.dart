import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:football_venue_booking_app/models/booking_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingService {
  final CollectionReference booking = FirebaseFirestore.instance.collection('bookings');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  // create booking 
  Future<String> createBooking(BookingModel booking) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User is not logged in');
      }

      final bookingRef = _firestore.collection('bookings').doc(); 

      // Prepare new booking data with status "pending"
      final newBooking = booking.copyWith(
        userId: userId,
        status: 'pending',  
        bookingId: bookingRef.id,  
      );

      // Save the new booking to Firestore
      await bookingRef.set(newBooking.toJson());
      
      return bookingRef.id;
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  Future<List<BookingModel>> getBookingsByFieldId(String fieldId) async {
    try {
      final querySnapshot = await _firestore
          .collection('bookings')
          .where('fieldId', isEqualTo: fieldId)
          .get();

      return querySnapshot.docs.map((doc) {
        return BookingModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch bookings for the field: $e');
    }
  }

   // get data all booking
  Future<List<BookingModel>> getBookings() async {
    try {
      final querySnapshot = await _firestore.collection('bookings').get();
      // Map Firestore documents to BookingModel
      return querySnapshot.docs.map((doc) {
        return BookingModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch bookings: $e');
    }
  }

  Future<List<BookingModel>> getBookingByUserId(String uid) async {
    try {
      final querySnapshot = await booking
          .where('user_id', isEqualTo: uid)
          .get(); 


      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs
            .map((doc) {
              return BookingModel.fromMap(doc.data() as Map<String, dynamic>);
            })
            .toList();
      } else {
        return [];  
      }
    } catch (e) {
      throw Exception('Failed to fetch bookings: $e');
    }
  }

  Future<BookingModel> getBookingById(String bookingId) async {
    try {
      final docSnapshot = await _firestore
          .collection('bookings')
          .doc(bookingId)
          .get(); // Fetch the booking document by its ID

      if (docSnapshot.exists) {
        // Return the booking model from the document
        return BookingModel.fromMap(docSnapshot.data() as Map<String, dynamic>);
      } else {
        throw Exception('Booking not found');
      }
    } catch (e) {
      throw Exception('Failed to fetch booking: $e');
    }
  }

   // Update booking status (e.g., "waiting")
  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    try {
      final bookingRef = _firestore.collection('bookings').doc(bookingId);

      // Update the booking status
      await bookingRef.update({
        'status': newStatus,
      });
    } catch (e) {
      throw Exception('Failed to update booking status: $e');
    }
  }

  // Upload payment receipt
  Future<String> uploadPaymentReceipt(String bookingId, File file) async {
    final fileName = 'public/$bookingId/${file.uri.pathSegments.last}';
    
    try {
      final response = await _supabase.storage
          .from('payment-photos')
          .upload(fileName, file, fileOptions: const FileOptions(upsert: true));

      final url = _supabase.storage.from('payment-photos').getPublicUrl(fileName);

      await booking.doc(bookingId).update({'payment_receipt': url});

      return url;
    } catch (e) {
      throw Exception('Failed to upload payment receipt: $e');
    }
  }

  // Fetch venues based on user_id, then field and booking data
  Future<List<Map<String, dynamic>>> getBookingsWithVenueField(String userId) async {
    try {
      // 1. Fetch venue data based on user_id
      final venueSnapshot = await _firestore
          .collection('venues')
          .where('user_id', isEqualTo: userId)
          .get();

      List<Map<String, dynamic>> bookingsWithFieldData = [];

      if (venueSnapshot.docs.isNotEmpty) {
        // 2. Loop through each venue, fetch associated field and booking data
        for (var venueDoc in venueSnapshot.docs) {
          var venueData = venueDoc.data();
          var venueId = venueData['uid'];

          // 3. Fetch field data related to this venue
          final fieldSnapshot = await _firestore
              .collection('fields')
              .where('venue_id', isEqualTo: venueId)
              .get();

          if (fieldSnapshot.docs.isNotEmpty) {
            var fieldData = fieldSnapshot.docs.first.data();
            var fieldId = fieldData['uid'];

            // 4. Fetch booking data for this field
            final bookingSnapshot = await _firestore
                .collection('bookings')
                .where('field_id', isEqualTo: fieldId)
                .get();

            if (bookingSnapshot.docs.isNotEmpty) {
              for (var bookingDoc in bookingSnapshot.docs) {
                var bookingData = bookingDoc.data();

                // Combine the booking, venue, and field data into a map
                bookingsWithFieldData.add({
                  'booking': BookingModel.fromMap(bookingData),
                  'venue': venueData,
                  'field': fieldData,
                });
              }
            }
          }
        }
      }

      return bookingsWithFieldData;
    } catch (e) {
      throw Exception('Failed to fetch bookings, venue, or field: $e');
    }
  }

   // Update owner booking status 
  Future<void> updateOwnerBookingStatus(String bookingId, String newStatus) async {
    try {
      final bookingRef = _firestore.collection('bookings').doc(bookingId);

      // Update the booking status
      await bookingRef.update({
        'status': newStatus,
      });
    } catch (e) {
      throw Exception('Failed to update booking status: $e');
    }
  }
}