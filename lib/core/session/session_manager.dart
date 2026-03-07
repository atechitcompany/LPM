import 'package:hive/hive.dart';

class SessionManager {
  static final Box _box = Hive.box('sessionBox');

  // SAVE SESSION
  static Future<void> saveSession({
    required String email,
    required String department,
    required bool rememberMe,
  }) async {
    await _box.put('email', email);
    await _box.put('department', department);
    await _box.put('isLoggedIn', true);
    await _box.put('rememberMe', rememberMe);
  }

  // CHECK LOGIN
  static bool isLoggedIn() {
    return _box.get('isLoggedIn') == true;
  }

  // GET EMAIL
  static String? getEmail() {
    return _box.get('email');
  }

  // GET DEPARTMENT
  static String? getDepartment() {
    return _box.get('department');
  }

  // REMEMBER ME
  static bool isRememberMe() {
    return _box.get('rememberMe') == true;
  }

  // CLEAR SESSION
  static Future<void> clearSession() async {
    await _box.clear();
  }
}