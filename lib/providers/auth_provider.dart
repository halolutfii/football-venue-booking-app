import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'user_provider.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  String? _errorMessage;
  bool _isLoading = false;

  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

   // fungsi untuk sign-in dengan email dan password
  Future<bool> signInWithEmail(
    String email,
    String password,
    UserProvider userProvider,
  ) async {
    _setLoading(true);
    try {
      _user = await _authService.signInWithEmail(email, password);

      if (_user != null) {
        //mengecek apakah email sudah diverifikasi
        if (!_user!.emailVerified) {
          _errorMessage = "Please verify your email before logging in.";
          _user = null; // set user to null karena login gagal
          notifyListeners();
          return false;
        }

        // Jika email sudah diverifikasi, load profile pengguna
        await userProvider.loadProfile(user!.uid);
      }

      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // fungsi untuk registrasi dengan email dan password
  Future<bool> registerWithEmail(
    String email,
    String password,
    String name,
    UserProvider userProvider,
  ) async {
    _setLoading(true);
    try {
      _user = await _authService.registerWithEmail(email, name, password);

      // simpan profile pengguna ke Firestore
      await userProvider.loadProfile(user!.uid);

      // cek apakah email telah diverifikasi
      if (_user != null && !_user!.emailVerified) {
        // jika email belum diverifikasi, beri tahu pengguna
        _errorMessage = "Verification email sent. Please check your inbox.";
      } else {
        _errorMessage = null;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // fungsi untuk mengecek status verifikasi email
  Future<bool> checkEmailVerification() async {
    User? user = FirebaseAuth.instance.currentUser;
    await user?.reload(); // pastikan data terbaru
    return user?.emailVerified ?? false;
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    try {
      _user = await _authService.signInWithGoogle();
      _errorMessage = null;
      notifyListeners();
      return _user != null;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
