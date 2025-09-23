import 'dart:io';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();

  UserModel? _user;
  UserModel? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

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
  final professionController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final bioController = TextEditingController();

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

  // update profile ke Firestore
  // Future<void> updateProfile() async {
  //   if (_user == null) return;
  //   if (!formKey.currentState!.validate()) return;

  //   _setLoading(true);
  //   try {
  //     final updated = Users(
  //       uid: _user!.uid,
  //       email: _user!.email,
  //       name: nameController.text,
  //       profession: professionController.text,
  //       phone: phoneController.text,
  //       address: addressController.text,
  //       bio: bioController.text,
  //       photo: _user!.photo, // nanti bisa diganti URL upload foto
  //       role: _user!.role,
  //     );

  //     await _userService.updateUserProfile(updated);
  //     _user = updated;
  //     notifyListeners();
  //   } finally {
  //     _setLoading(false);
  //   }
  // }

   // upload foto profile ke Supabase
  // Future<String> uploadProfilePhoto(File file) async {
  //   if (_user == null) throw Exception("User not loaded");
  //   final url = await _userService.uploadProfilePhoto(_user!.uid, file);
  //   _user = UserModel(
  //     uid: _user!.uid,
  //     email: _user!.email,
  //     name: _user!.name,
  
  //     phone: _user!.phone,
  //     address: _user!.address,

  //     photo: url,
  //     role: _user!.role,
  //   );
    
  //   notifyListeners();
  //   return url;
  // }

  // update profile + optional upload foto baru
  Future<void> updateProfileWithPhoto({File? newPhoto}) async {
    if (_user == null) return;
    if (!formKey.currentState!.validate()) return;

    _setLoading(true);
    try {
      String? photoUrl = _user!.photo;

      // if (newPhoto != null) {
      //   photoUrl = await uploadProfilePhoto(newPhoto); // Upload foto baru
      // }

      final updated = UserModel(
        uid: _user!.uid,
        email: _user!.email,
        name: nameController.text,
      
        phone: phoneController.text,
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
    professionController.dispose();
    phoneController.dispose();
    addressController.dispose();
    bioController.dispose();
    super.dispose();
  }
}