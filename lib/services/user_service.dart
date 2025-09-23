import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserService {
  final CollectionReference user =
      FirebaseFirestore.instance.collection('users');
  // final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> createUserProfile(UserModel profile) async {
    await user.doc(profile.uid).set(profile.toMap());
  }

  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await user.doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> updateUserProfile(UserModel profile) async {
    await user.doc(profile.uid).update(profile.toMap());
  }

  Future<bool> checkUserExists(String uid) async {
    final doc = await user.doc(uid).get();
    return doc.exists;
  }

  Future<List<UserModel>> getOwner() async {
    final snapshot = await user.where("role", isEqualTo: "owner").get();

    return snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<UserModel> createOwner({
    required String email,
    required String password,
    required String name,
    String role = "owner",
  }) async {
    final credential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    final profile = UserModel(
      uid: credential.user!.uid,
      name: name,
      email: email,
      role: role,
    );

    await user.doc(profile.uid).set(profile.toMap());

    return profile;
  }

  Future<void> deleteUser(String uid) async {
    await user.doc(uid).delete();
  }

  // Future<String> uploadProfilePhoto(String uid, File file) async {
  //   final fileName = 'public/$uid/${file.uri.pathSegments.last}';

  //   final response = await _supabase.storage
  //       .from('profile-photos')
  //       .upload(fileName, file, fileOptions: const FileOptions(upsert: true));

  //   final url = _supabase.storage.from('profile-photos').getPublicUrl(fileName);

  //   await employees.doc(uid).update({'photo': url});

  //   return url;
  // }
}