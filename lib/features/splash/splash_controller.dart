import 'package:flutter/material.dart';

import '../../services/internet_service.dart';
import '../../services/location_service.dart';
import '../../services/preferences_service.dart';

// ============================================================
// FLOW RESULT TYPE
// ============================================================

enum SplashFlowStatus {
  success,
  internetRequired,
  locationRequired,
}

// ============================================================
// FLOW RESULT
// ============================================================

class SplashFlowResult {
  final SplashFlowStatus status;

  final String? locationName;

  final bool skipNotification;

  final bool registeredUser;

  const SplashFlowResult({
    required this.status,
    this.locationName,
    this.skipNotification = false,
    this.registeredUser = false,
  });

  // ==========================================================
  // SUCCESS
  // ==========================================================

  const SplashFlowResult.success(
    String location, {
    bool skipNotification = false,
    bool registeredUser = false,
  }) : this(
          status: SplashFlowStatus.success,
          locationName: location,
          skipNotification: skipNotification,
          registeredUser: registeredUser,
        );

  // ==========================================================
  // INTERNET REQUIRED
  // ==========================================================

  const SplashFlowResult.internetRequired()
      : this(
          status: SplashFlowStatus.internetRequired,
        );

  // ==========================================================
  // LOCATION REQUIRED
  // ==========================================================

  const SplashFlowResult.locationRequired()
      : this(
          status: SplashFlowStatus.locationRequired,
        );
}

// ============================================================
// SPLASH CONTROLLER
// ============================================================

class SplashController {
  static Future<SplashFlowResult> startApp(
    BuildContext context,
  ) async {
    debugPrint(
      '🚀 SplashController started',
    );

    // ==========================================================
    // STEP 1 — INTERNET
    // ==========================================================

    debugPrint(
      '1️⃣ Checking internet...',
    );

    final bool internetReady =
        await InternetService.hasInternet();

    if (!internetReady) {
      debugPrint(
        '❌ Internet is OFF / unavailable',
      );

      return const SplashFlowResult
          .internetRequired();
    }

    debugPrint(
      '✅ Internet connected',
    );

    // ==========================================================
    // STEP 2 — LOCATION SERVICE
    // ==========================================================

    debugPrint(
      '2️⃣ Checking location service...',
    );

    final bool locationServiceEnabled =
        await LocationService
            .isLocationServiceEnabled();

    if (!locationServiceEnabled) {
      debugPrint(
        '❌ Phone Location Service is OFF',
      );

      return const SplashFlowResult
          .locationRequired();
    }

    debugPrint(
      '✅ Phone Location Service is ON',
    );

    // ==========================================================
    // STEP 3 — LOCATION PERMISSION
    // ==========================================================

    debugPrint(
      '3️⃣ Checking location permission...',
    );

    final bool locationPermission =
        await LocationService
            .checkLocationPermission();

    debugPrint(
      '📍 Location permission: '
      '$locationPermission',
    );

    if (!locationPermission) {
      debugPrint(
        '❌ Location permission is not ready',
      );

      return const SplashFlowResult
          .locationRequired();
    }

    debugPrint(
      '✅ Location permission ready',
    );

    // ==========================================================
    // STEP 4 — GPS
    // ==========================================================

    debugPrint(
      '4️⃣ Fetching current GPS location...',
    );

    final position =
        await LocationService
            .getCurrentLocation();

    if (position == null) {
      debugPrint(
        '❌ Could not get current GPS location',
      );

      return const SplashFlowResult
          .locationRequired();
    }

    debugPrint(
      '📍 Latitude: ${position.latitude}',
    );

    debugPrint(
      '📍 Longitude: ${position.longitude}',
    );

    // ==========================================================
    // STEP 5 — LOCATION NAME
    // ==========================================================

    String? locationName;

    try {
      debugPrint(
        '5️⃣ Getting location name...',
      );

      locationName =
          await LocationService
              .getLocationName(
        position,
      );
    } catch (e) {
      debugPrint(
        '⚠️ Location name error: $e',
      );
    }

    if (locationName == null ||
        locationName.trim().isEmpty) {
      locationName =
          'Current location';

      debugPrint(
        '⚠️ Using fallback location',
      );
    }

    debugPrint(
      '📍 Location Name: $locationName',
    );

    // ==========================================================
    // STEP 6 — FINAL INTERNET CHECK
    // ==========================================================

    debugPrint(
      '6️⃣ Checking internet again...',
    );

    final bool internetStillReady =
        await InternetService.hasInternet();

    if (!internetStillReady) {
      debugPrint(
        '❌ Internet was lost during location flow',
      );

      return const SplashFlowResult
          .internetRequired();
    }

    debugPrint(
      '✅ Internet still connected',
    );

    // ==========================================================
    // STEP 7 — SHARED PREFERENCES
    // ==========================================================

    debugPrint(
      '7️⃣ Checking saved onboarding state...',
    );

    final bool notificationCompleted =
        await PreferencesService
            .isNotificationCompleted();

    final bool registeredUser =
        await PreferencesService
            .isUserRegistered();

    debugPrint(
      '🔔 Notification completed: '
      '$notificationCompleted',
    );

    debugPrint(
      '👤 User registered: '
      '$registeredUser',
    );

    // ==========================================================
    // SUCCESS
    // ==========================================================

    debugPrint(
      '🎉 Splash flow successful',
    );

    return SplashFlowResult.success(
      locationName,
      skipNotification:
          notificationCompleted,
      registeredUser:
          registeredUser,
    );
  }
}