import 'package:flutter/material.dart';

import 'package:football_venue_booking_app/models/user_model.dart';
import 'package:football_venue_booking_app/models/venue_model.dart';
import 'package:football_venue_booking_app/models/field_model.dart';
import 'package:football_venue_booking_app/services/user_service.dart';
import 'package:football_venue_booking_app/services/venue_service.dart';
import 'package:football_venue_booking_app/services/field_service.dart';

class MasterProvider extends ChangeNotifier { 
  final UserService _serviceUser = UserService();
  final VenueService _serviceVenue = VenueService();
  final FieldService _serviceField = FieldService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<UserModel> _owners = [];
  List<UserModel> get owners => _owners;
  List<UserModel> _users = [];
  List<UserModel> get users => _users;
  List<VenueModel> _venues = [];
  List<VenueModel> get venues => _venues;
  List<FieldModel> _fields = [];
  List<FieldModel> get fields => _fields;

  Map<String, double> _chartData = {};
  Map<String, double> get chartData => _chartData;
  Map<String, double> _chartDataVenueField = {};
  Map<String, double> get chartDataVenueField => _chartDataVenueField;
  
  // load all users (role = owner)
  Future<void> loadOwners() async {
    _setLoading(true);
    try {
      _owners = await _serviceUser.getOwner();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  // load all users (role = user)
  Future<void> loadUsers() async {
    _setLoading(true);
    try {
      _users = await _serviceUser.getUser();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> loadAllVenues() async {
    _errorMessage = null;
    _isLoading = true;

    notifyListeners();
    try {
      _venues = await _serviceVenue.getAllVenues();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  Future<void> loadAllFields() async {
    _errorMessage = null;
    _isLoading = true;

    notifyListeners();
    try {
      _fields = await _serviceField.getAllFields();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // load all users and owners for pie chart
  Future<void> loadUsersAndOwners() async {
    _setLoading(true);
    try {
      // Load all owners and users
      await loadOwners();
      await loadUsers();

      // Hitung jumlah owner dan user
      final ownerCount = _owners.length;
      final userCount = _users.length;

      // Update data untuk pie chart
      _chartData = {
        "Owner ($ownerCount)": ownerCount.toDouble(),
        "User ($userCount)": userCount.toDouble(),
      };

      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  // load all venues and fields for pie chart
  Future<void> loadVenuesAndFields() async {
    _setLoading(true);
    try {
      // Load all venues and fields
      await loadAllVenues();
      await loadAllFields();

      // Hitung jumlah venues dan fields
      final venueCount = _venues.length;
      final fieldCount = _fields.length;

      // Update data untuk pie chart
      _chartDataVenueField = {
        "Venue ($venueCount)": venueCount.toDouble(),
        "Field ($fieldCount)": fieldCount.toDouble(),
      };

      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

}