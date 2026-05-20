import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/user_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validators.dart';

class AuthService {
  final SharedPreferences _prefs;

  AuthService(this._prefs);

  Future<UserModel?> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    final emailError = AppValidators.validateEmail(email);
    if (emailError != null) throw Exception(emailError);

    final passwordError = AppValidators.validatePassword(password);
    if (passwordError != null) throw Exception(passwordError);

    final user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email.trim(),
      username: email.split('@').first,
      createdAt: DateTime.now(),
    );

    await _saveUser(user);
    return user;
  }

  Future<UserModel> register(
    String email,
    String password,
    String username,
  ) async {
    await Future.delayed(const Duration(seconds: 1));

    final emailError = AppValidators.validateEmail(email);
    if (emailError != null) throw Exception(emailError);

    final passwordError = AppValidators.validatePassword(password);
    if (passwordError != null) throw Exception(passwordError);

    final usernameError = AppValidators.validateUsername(username);
    if (usernameError != null) throw Exception(usernameError);

    final user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email.trim(),
      username: username.trim(),
      createdAt: DateTime.now(),
    );

    await _saveUser(user);
    return user;
  }

  Future<void> logout() async {
    await _prefs.remove(AppConstants.storageUserKey);
  }

  Future<UserModel?> getCurrentUser() async {
    final userJson = _prefs.getString(AppConstants.storageUserKey);

    if (userJson == null || userJson.isEmpty) return null;

    try {
      return UserModel.fromJson(jsonDecode(userJson));
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveUser(UserModel user) async {
    await _prefs.setString(
      AppConstants.storageUserKey,
      jsonEncode(user.toJson()),
    );
  }
}
