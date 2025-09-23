import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_model.dart';
import '../services/user_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final UserService _userService = UserService();

  // Sign in with Email & Password
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Login failed";
    }
  }

  // Register with Email & Password
  Future<User?> registerWithEmail(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // buat profile default di Fitestore
      final user = credential.user;
      if (user != null) {
        final profile = UserModel(
          uid: user.uid, 
          name: user.email!.split('@')[0], 
          email: user.email!, 
          role: 'user',
        );
        await _userService.createUserProfile(profile);
      }

      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Register failed";
    }
  }

  // Login dengan Google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      User? user = userCredential.user;

      final exist = await _userService.checkUserExists(user!.uid);
      if (!exist) {
        final profile = UserModel(
          uid: user.uid, 
          name: user.displayName ?? "No Name", 
          email: user.email!, 
          role: "user",
          photo: user.photoURL,
          );
          await _userService.createUserProfile(profile);
      }

      return userCredential.user;
    } catch (e) {
      print('Google Sign-In error: $e');
      rethrow;
    }
  } 

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  // Get current user
  User? get currentUser => _auth.currentUser;
}