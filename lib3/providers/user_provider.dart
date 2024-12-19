import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';

class UserProvider extends ChangeNotifier {
  UserRepository repository;
  User? _user;
  bool _isLoading = false;
  String? _error;

  UserProvider({required this.repository});

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  Future<bool> login(String email, String password, String? deviceToken) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _user = await repository.login(email, password, deviceToken);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final success = await repository.register(name, email, password);
      
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOtp(String email, String otp) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final success = await repository.verifyOtp(email, otp);
      
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendVerificationCode(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final success = await repository.sendVerificationCode(email);
      
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final success = await repository.forgotPassword(email);
      
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(String email, String newPassword, String otp) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final success = await repository.resetPassword(email, newPassword, otp);
      
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> checkInitialLogin() async {
    try {
      final email = await repository.getStoredEmail();
      if (email != null && email.isNotEmpty) {
        return await repository.checkLogin(email);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  void logout() async {
    await repository.clearStoredData();
    _user = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
