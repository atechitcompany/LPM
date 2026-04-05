import 'package:hive/hive.dart';

class SessionManager {
  static final Box _box = Hive.box('sessionBox');

  // SAVE SESSION (Updated to include userName)
  static Future<void> saveSession({
    required String email,
    required String department,
    required bool rememberMe,
    String? userName, // 🚀 Naya feature: User ka naam bhi save karega
  }) async {
    await _box.put('email', email);
    await _box.put('department', department);
    await _box.put('isLoggedIn', true);
    await _box.put('rememberMe', rememberMe);

    // Agar login ke waqt naam mile, toh use bhi save kar lo
    if (userName != null && userName.isNotEmpty) {
      await _box.put('userName', userName);
    }
  }

  // 🚀 SAVE ONLY USERNAME (Agar baad mein naam update karna ho)
  static Future<void> saveUserName(String userName) async {
    await _box.put('userName', userName);
  }

  // 🚀 YAHI HAI WO FUNCTION JO MISSING THA - GET USER NAME
  static String? getUserName() {
    return _box.get('userName');
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