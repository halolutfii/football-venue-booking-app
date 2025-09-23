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

  Future<bool> signInWithEmail(String email, String password, UserProvider profileProvider) async {
    _setLoading(true);
    try {
      _user = await _authService.signInWithEmail(email, password);

      if (user != null) {
        await profileProvider.loadProfile(_user!.uid);
        _user = user;
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

  Future<bool> registerWithEmail(String email, String password, UserProvider userProvider) async {
    _setLoading(true);
    try {
      _user = await _authService.registerWithEmail(email, password);

      // simpan ke Firestore pakai UserProvider
      await userProvider.loadProfile(user!.uid);

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