import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  // =========================================================
  // KEYS
  // =========================================================

  static const String _onboardingCompletedKey =
      'onboarding_completed';

  static const String _notificationCompletedKey =
      'notification_completed';

  static const String _phoneVerifiedKey =
      'phone_verified';

  static const String _userRegisteredKey =
      'user_registered';

  static const String _userPhoneKey =
      'user_phone';

  // =========================================================
  // ONBOARDING
  // =========================================================

  static Future<void> setOnboardingCompleted(
    bool value,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setBool(
      _onboardingCompletedKey,
      value,
    );
  }

  static Future<bool> isOnboardingCompleted() async {
    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getBool(
          _onboardingCompletedKey,
        ) ??
        false;
  }

  // =========================================================
  // NOTIFICATION COMPLETED
  // =========================================================

  static Future<void> setNotificationCompleted(
    bool value,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setBool(
      _notificationCompletedKey,
      value,
    );
  }

  static Future<bool> isNotificationCompleted() async {
    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getBool(
          _notificationCompletedKey,
        ) ??
        false;
  }

  // =========================================================
  // PHONE VERIFIED
  // =========================================================

  static Future<void> setPhoneVerified(
    bool value,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setBool(
      _phoneVerifiedKey,
      value,
    );
  }

  static Future<bool> isPhoneVerified() async {
    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getBool(
          _phoneVerifiedKey,
        ) ??
        false;
  }

  // =========================================================
  // USER REGISTERED
  // =========================================================

  static Future<void> setUserRegistered(
    bool value,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setBool(
      _userRegisteredKey,
      value,
    );
  }

  static Future<bool> isUserRegistered() async {
    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getBool(
          _userRegisteredKey,
        ) ??
        false;
  }

  // =========================================================
  // PHONE NUMBER
  // =========================================================

  static Future<void> savePhoneNumber(
    String phoneNumber,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      _userPhoneKey,
      phoneNumber,
    );
  }

  static Future<String?> getPhoneNumber() async {
    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getString(
      _userPhoneKey,
    );
  }

  // =========================================================
  // CLEAR ALL
  // =========================================================

  static Future<void> clearAll() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove(
      _onboardingCompletedKey,
    );

    await prefs.remove(
      _notificationCompletedKey,
    );

    await prefs.remove(
      _phoneVerifiedKey,
    );

    await prefs.remove(
      _userRegisteredKey,
    );

    await prefs.remove(
      _userPhoneKey,
    );
  }
}