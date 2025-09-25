import 'package:flutter/material.dart';
import 'package:football_venue_booking_app/models/field_model.dart';
import 'package:football_venue_booking_app/services/field_service.dart';

class FieldProvider extends ChangeNotifier {
  final FieldService _service = FieldService();
  final formKey = GlobalKey<FormState>();

  List<FieldModel> _fields = [];
  String? _errorMessage;
  bool _isLoading = false;

  List<FieldModel> get fields => _fields;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<void> loadFields(venueId) async {
    _errorMessage = null;
    _isLoading = true;

    notifyListeners();
    try {
      _fields = await _service.getFields(venueId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  Future<void> loadFieldById(String fieldId) async {
    _errorMessage = null;
    _isLoading = true;

    notifyListeners();
    try {
      final venue = await _service.getFieldById(fieldId);

      if (venue != null) {
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }
}
