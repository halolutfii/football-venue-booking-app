import 'dart:io';
import 'package:flutter/material.dart';
import 'package:football_venue_booking_app/services/schedule_service.dart';
import 'package:football_venue_booking_app/models/user_model.dart';
import 'package:football_venue_booking_app/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();
  final ScheduleService _scheduleService = ScheduleService();

  UserModel? _user;
  UserModel? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  File? _selectedImage;
  File? get selectedImage => _selectedImage;

  void setSelectedImage(File? file) {
    _selectedImage = file;
    notifyListeners();
  }

  // form key
  final formKey = GlobalKey<FormState>();

  // controllers
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final genderController = TextEditingController();
  final addressController = TextEditingController();

  // load profile dari Firestore
  Future<void> loadProfile(String uid) async {
    _setLoading(true);
    try {
      _user = await _userService.getUserProfile(uid);

      if (_user != null) {
        nameController.text = _user!.name;
        phoneController.text = _user!.phone ?? '';
        addressController.text = _user!.address ?? '';
      }
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // upload foto profile ke Supabase
  Future<String> uploadProfilePhoto(File file) async {
    if (_user == null) throw Exception("User not loaded");
    final url = await _userService.uploadProfilePhoto(_user!.uid, file);
    _user = UserModel(
      uid: _user!.uid,
      email: _user!.email,
      name: _user!.name,
      phone: _user!.phone,
      gender: _user!.gender,
      address: _user!.address,
      photo: url,
      role: _user!.role,
    );

    notifyListeners();
    return url;
  }

  // update profile + optional upload foto baru
  Future<void> updateProfileWithPhoto({File? newPhoto}) async {
    if (_user == null) return;
    if (!formKey.currentState!.validate()) return;

    _setLoading(true);
    try {
      String? photoUrl = _user!.photo;

      if (newPhoto != null) {
        photoUrl = await uploadProfilePhoto(newPhoto); // Upload foto baru
      }

      final updated = UserModel(
        uid: _user!.uid,
        email: _user!.email,
        name: nameController.text,
        phone: phoneController.text,
        gender: genderController.text,
        address: addressController.text,
        photo: photoUrl,
        role: _user!.role,
      );

      await _userService.updateUserProfile(updated);
      _user = updated;
      notifyListeners();
    } catch (e) {
      print('Error updating profile with photo: $e');
      rethrow; // Rethrow untuk penanganan lebih lanjut di UI
    } finally {
      _setLoading(false);
    }
  }

  // update profile tanpa foto (lama)
  Future<void> updateProfile() async {
    if (_user == null) return;
    if (!formKey.currentState!.validate()) return;

    _setLoading(true);
    try {
      final updated = UserModel(
        uid: _user!.uid,
        email: _user!.email,
        name: nameController.text,

        phone: phoneController.text,
        address: addressController.text,

        photo: _user!.photo,
        role: _user!.role,
      );

      await _userService.updateUserProfile(updated);
      _user = updated;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  void generateSchedule() async {
    _setLoading(true);

    try {
      final now = DateTime.now();
      final twoMonthsLater = DateTime(now.year, now.month + 1, now.day);

      final schedules = await _scheduleService.generateSchedule(
        fieldId: '4Dm6tgHPqZdOUsDq0HU6',
        currentDate: now,
        endDate: twoMonthsLater,
      );

      schedules.forEach((date, slots) {
        print('Date: $date');
        for (var slot in slots) {
          print(
            '${slot['start_time']} - ${slot['end_time']} | Rp${slot['price']} | ${slot['status']}',
          );
        }
      });

      print("Total hari digenerate: ${schedules.length}");
      print("Jadwal: ${schedules.keys}");
      print("Jadwal hari pertama: ${schedules.keys.first}");
      print("Jadwal hari terakhir: ${schedules.keys.last}");
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);

      notifyListeners();
    }
  }

  void clearProfile() {
    _user = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    genderController.dispose();
    addressController.dispose();
    super.dispose();
  }
}
