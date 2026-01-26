import 'package:hive/hive.dart';

class SessionManager {
  static final Box _box = Hive.box('sessionBox');

  // ✅ Save session
  static Future<void> saveSession({
    required String email,
    required String department,
  }) async {
    await _box.put('email', email);
    await _box.put('department', department);
    await _box.put('isLoggedIn', true);
  }

  // ✅ Get session
  static String? getEmail() {
    return _box.get('email');
  }

  static String? getDepartment() {
    return _box.get('department');
  }

  static bool isLoggedIn() {
    return _box.get('isLoggedIn') == true;
  }

  // ✅ Clear session (logout)
  static Future<void> clearSession() async {
    await _box.clear();
  }
}
