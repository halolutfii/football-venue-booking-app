import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:football_venue_booking_app/models/venue_model.dart';
import 'package:football_venue_booking_app/providers/auth_provider.dart';
import 'package:football_venue_booking_app/services/venue_service.dart';
import 'package:geolocator/geolocator.dart';

class VenueProvider extends ChangeNotifier {
  final VenueService _service;
  final AuthProvider _authProvider;
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final descriptionController = TextEditingController();
  final contactController = TextEditingController();

  List<VenueModel> _venues = [];
  String? _errorMessage;
  bool _isLoading = false;
  String? _locationPermission;
  double? _latitude;
  double? _longitude;

  List<VenueModel> get venues => _venues;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  String? get locationPermission => _locationPermission;
  double? get latitude => _latitude;
  double? get longitude => _longitude;

  VenueProvider({
    required AuthProvider authProvider,
    required VenueService service,
  }) : _authProvider = authProvider,
       _service = service;

  Future<void> loadVenues() async {
    final user = _authProvider.user;
    _errorMessage = null;
    _isLoading = true;

    notifyListeners();
    try {
      _venues = await _service.getVenues(user!.uid);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  Future<void> loadVenueById(String venueId) async {
    _errorMessage = null;
    _isLoading = true;

    notifyListeners();
    try {
      final venue = await _service.getVenueById(venueId);

      if (venue != null) {
        nameController.text = venue.name;
        descriptionController.text = venue.description ?? '';
        contactController.text = venue.contact ?? '';
        addressController.text = venue.address ?? '';
        _latitude = venue.locationLat ?? 0.0;
        _longitude = venue.locationLong ?? 0.0;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  Future<void> addVenue() async {
    final user = _authProvider.user;
    _errorMessage = null;

    notifyListeners();
    try {
      final VenueModel venue = VenueModel(
        userId: user!.uid,
        name: nameController.text,
        locationLat: latitude ?? 0.0,
        locationLong: longitude ?? 0.0,
        address: addressController.text,
        description: descriptionController.text,
        contact: contactController.text,
      );

      await _service.createVenue(venue);
      _venues.add(venue);

      resetForm();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<void> editVenue(String venueId) async {
    final user = _authProvider.user;
    _errorMessage = null;
    _isLoading = true;

    notifyListeners();
    try {
      final VenueModel venue = VenueModel(
        venueId: venueId,
        userId: user!.uid,
        name: nameController.text,
        locationLat: latitude ?? 0.0,
        locationLong: longitude ?? 0.0,
        address: addressController.text,
        description: descriptionController.text,
        contact: contactController.text,
      );

      await _service.updateVenue(venue);

      resetForm();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  Future<void> removeVenue(String venueId) async {
    _errorMessage = null;
    _isLoading = true;

    notifyListeners();
    try {
      await _service.deleteVenue(venueId);

      await loadVenues();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  bool validateForm() {
    return formKey.currentState!.validate();
  }

  Future<void> _checkPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    permission = await Geolocator.checkPermission();

    if (!serviceEnabled) {
      _locationPermission = "Location services are disabled.";

      notifyListeners();

      return;
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        _locationPermission = "Location permission denied.";

        notifyListeners();

        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _locationPermission = "Location permission permanently denied.";

      notifyListeners();

      return;
    }

    _locationPermission = "Location permission granted";

    notifyListeners();
  }

  Future<void> getLocation(BuildContext context) async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();
    try {
      await _checkPermission();

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      GeoPoint? point = await showSimplePickerLocation(
        context: context,
        title: "Select your venue",
        textConfirmPicker: "Save",
        initPosition: GeoPoint(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      );

      setLatLng(point!);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  void setLatLng(GeoPoint point) {
    _latitude = point.latitude;
    _longitude = point.longitude;

    notifyListeners();
  }

  void resetForm() {
    nameController.clear();
    addressController.clear();
    descriptionController.clear();
    contactController.clear();

    _latitude = null;
    _longitude = null;

    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    descriptionController.dispose();
    contactController.dispose();
    super.dispose();
  }
}
