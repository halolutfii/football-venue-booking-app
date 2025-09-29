import 'dart:io';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();

  UserModel? _user;
  UserModel? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  File? _selectedImage;
  File? get selectedImage => _selectedImage;

  List<UserModel> _owners = [];
  List<UserModel> get owners => _owners;
  List<UserModel> _users = [];
  List<UserModel> get users => _users;

  Map<String, double> _chartData = {};
  Map<String, double> get chartData => _chartData;

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

  Future<void> createOwner(String email, String password, String name) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newOwner = await _userService.createOwner(
        email: email,
        password: password,
        name: name,
      );
      users.add(newOwner);
      await loadOwners(); 
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // load profile dari Firestore
  Future<void> loadProfile(String uid) async {
    _setLoading(true);
    try {
      _user = await _userService.getUserProfile(uid);

      if (_user != null) {
        nameController.text = _user!.name ?? '';
        phoneController.text = _user!.phone ?? '';
        addressController.text = _user!.address ?? '';
      }
      notifyListeners();
    } finally {
      _setLoading(false);
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

  // load all users (role = owner)
  Future<void> loadOwners() async {
    _setLoading(true); 
    try {
      _owners = await _userService.getOwner(); 
      _errorMessage = null; 
    } catch (e) {
      _errorMessage = e.toString(); 
    } finally {
      _setLoading(false); 
      notifyListeners();
    }
  }

  // Fetch the specific owner by uid
  Future<void> loadUserById(String uid) async {
    _setLoading(true);
    try {
      _user = await _userService.getUserProfile(uid);  
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
      _users = await _userService.getUser(); 
      _errorMessage = null; 
    } catch (e) {
      _errorMessage = e.toString(); 
    } finally {
      _setLoading(false); 
      notifyListeners();
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

  Future<void> deleteOwner(String uid) async {
    _errorMessage = null;
    _isLoading = true;

    notifyListeners();
    try {
      await _userService.deleteUser(uid);

      await loadOwners();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  Future<void> deleteUser(String uid) async {
    _errorMessage = null;
    _isLoading = true;

    notifyListeners();
    try {
      await _userService.deleteUser(uid);

      await loadUsers();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  Future<bool> resetPassword(String userId) async {
    _setLoading(true);
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (userDoc.exists) {
        String userEmail = userDoc['email'];  

        await FirebaseAuth.instance.sendPasswordResetEmail(email: userEmail);

        return true;
      } else {
        _errorMessage = "User not found in the database.";
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
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
    professionController.dispose();
    phoneController.dispose();
    addressController.dispose();
    bioController.dispose();
    super.dispose();
  }
}