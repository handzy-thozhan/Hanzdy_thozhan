import 'package:flutter/material.dart';

import '../../services/internet_service.dart';
import '../../services/location_service.dart';

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

  const SplashFlowResult({
    required this.status,
    this.locationName,
  });

  // ==========================================================
  // SUCCESS
  // ==========================================================

  const SplashFlowResult.success(
    String location,
  ) : this(
          status:
              SplashFlowStatus.success,
          locationName: location,
        );

  // ==========================================================
  // INTERNET REQUIRED
  // ==========================================================

  const SplashFlowResult.internetRequired()
      : this(
          status:
              SplashFlowStatus.internetRequired,
        );

  // ==========================================================
  // LOCATION REQUIRED
  // ==========================================================

  const SplashFlowResult.locationRequired()
      : this(
          status:
              SplashFlowStatus.locationRequired,
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
    // STEP 1
    // INTERNET FIRST
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
      '✅ Internet Connected',
    );

    // ==========================================================
    // STEP 2
    // CHECK PHONE LOCATION SERVICE
    // ==========================================================

    debugPrint(
      '2️⃣ Checking phone Location Service...',
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
    // STEP 3
    // LOCATION PERMISSION
    // ==========================================================

    debugPrint(
      '3️⃣ Checking location permission...',
    );

    final bool locationPermission =
        await LocationService
            .checkLocationPermission();

    debugPrint(
      '3️⃣ Location permission result: '
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
    // STEP 4
    // GPS LOCATION
    // ==========================================================

    debugPrint(
      '4️⃣ Getting current GPS location...',
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
    // STEP 5
    // LOCATION NAME
    // ==========================================================

    debugPrint(
      '5️⃣ Getting location name...',
    );

    String? locationName;

    try {
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
        '⚠️ Using fallback location name',
      );
    }

    debugPrint(
      '📍 Location Name: $locationName',
    );

    // ==========================================================
    // FINAL INTERNET CHECK
    //
    // Check again before completing the flow.
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
    // SUCCESS
    // ==========================================================

    debugPrint(
      '🎉 Complete location flow successful',
    );

    return SplashFlowResult.success(
      locationName,
    );
  }
}