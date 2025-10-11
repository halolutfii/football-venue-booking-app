import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:football_venue_booking_app/services/booking_service.dart';
import 'package:football_venue_booking_app/models/booking_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingProvider with ChangeNotifier {
  final BookingService _bookingService = BookingService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<BookingModel> _bookings = [];
  List<BookingModel> get bookings => _bookings;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  BookingModel? _selectedBooking;
  BookingModel? get selectedBooking => _selectedBooking;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> createBooking(BookingModel booking) async {
    _isLoading = true; 
    notifyListeners();

    try {
      await _bookingService.createBooking(booking);
      
      _errorMessage = null; 
    } catch (e) {
      _errorMessage = 'Failed to create booking: $e'; 
    } finally {
      _isLoading = false; 
      notifyListeners(); 
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
  Future<void> getBookings() async {
    _isLoading = true; // Start loading
    notifyListeners();

    try {
      _bookings = await _bookingService.getBookings();
      _errorMessage = null; 
    } catch (e) {
      _errorMessage = 'Failed to fetch bookings: $e'; 
    } finally {
      _isLoading = false; 
      notifyListeners(); 
    }
  }

  // get booking by user id
  Future<void> getBookingByUserID(String uid) async {
    _isLoading = true;
    notifyListeners();  

    try {
      final fetchedBookings = await _bookingService.getBookingByUserId(uid);
      
      _bookings = fetchedBookings;

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to fetch bookings: $e'; 
    } finally {
      _isLoading = false; 
      notifyListeners();  
    }
  }

  Future<void> getBookingDetailsById(String bookingId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _selectedBooking = await _bookingService.getBookingById(bookingId);
      _errorMessage = null; 
    } catch (e) {
      _errorMessage = 'Failed to fetch booking: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

   // Update the status of a booking
  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _bookingService.updateBookingStatus(bookingId, newStatus);

      // Update locally as well
      _selectedBooking = _selectedBooking?.copyWith(status: newStatus);

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to update status: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Upload payment receipt and change status to "waiting"
  Future<void> uploadPaymentAndUpdateStatus(String bookingId, File file) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Upload the payment receipt image and update booking status
      final receiptUrl = await _bookingService.uploadPaymentReceipt(bookingId, file);
      await _bookingService.updateBookingStatus(bookingId, 'waiting');

      // Update the booking locally
      _selectedBooking = _selectedBooking?.copyWith(paymentReceipt: receiptUrl, status: 'waiting');

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to upload payment and update status: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

}
