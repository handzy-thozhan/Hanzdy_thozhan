import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  // ============================================================
  // CHECK GPS / LOCATION SERVICE
  // ============================================================

  static Future<bool> isLocationServiceEnabled() async {
    final bool enabled =
        await Geolocator.isLocationServiceEnabled();

    debugPrint(
      '📍 Phone Location Service enabled: $enabled',
    );

    return enabled;
  }

  // ============================================================
  // CHECK / REQUEST LOCATION PERMISSION
  // ============================================================

  static Future<bool> checkLocationPermission() async {
    PermissionStatus status =
        await Permission.locationWhenInUse.status;

    debugPrint(
      '📍 Current location permission: $status',
    );

    // ------------------------------------------------------------
    // Already granted
    // ------------------------------------------------------------

    if (status.isGranted) {
      debugPrint(
        '✅ Location permission already granted',
      );

      return true;
    }

    // ------------------------------------------------------------
    // Permanently denied
    // ------------------------------------------------------------

    if (status.isPermanentlyDenied) {
      debugPrint(
        '❌ Location permission permanently denied',
      );

      return false;
    }

    // ------------------------------------------------------------
    // Request permission
    // ------------------------------------------------------------

    debugPrint(
      '📍 Requesting location permission...',
    );

    status =
        await Permission.locationWhenInUse.request();

    debugPrint(
      '📍 Permission after request: $status',
    );

    // ------------------------------------------------------------
    // Granted
    // ------------------------------------------------------------

    if (status.isGranted) {
      debugPrint(
        '✅ Location permission granted',
      );

      return true;
    }

    // ------------------------------------------------------------
    // Permanently denied
    // ------------------------------------------------------------

    if (status.isPermanentlyDenied) {
      debugPrint(
        '❌ Location permission became permanently denied',
      );

      return false;
    }

    // ------------------------------------------------------------
    // Still denied
    // ------------------------------------------------------------

    debugPrint(
      '❌ Location permission denied',
    );

    return false;
  }

  // ============================================================
  // CHECK PERMANENT DENIAL
  // ============================================================

  static Future<bool> isLocationPermanentlyDenied() async {
    final PermissionStatus status =
        await Permission.locationWhenInUse.status;

    debugPrint(
      '📍 Permanent denial check: $status',
    );

    return status.isPermanentlyDenied;
  }

  // ============================================================
  // OPEN APP SETTINGS
  // ============================================================

  static Future<bool> openLocationAppSettings() async {
    debugPrint(
      '➡️ Opening Handzy Thozhan App Settings',
    );

    return await openAppSettings();
  }

  // ============================================================
  // OPEN PHONE LOCATION SETTINGS
  // ============================================================

  static Future<bool> openLocationSettings() async {
    debugPrint(
      '➡️ Opening Phone Location Settings',
    );

    return await Geolocator.openLocationSettings();
  }

  // ============================================================
  // GET CURRENT GPS LOCATION
  //
  // IMPORTANT:
  // LocationAccuracy.best = highest accuracy request
  // ============================================================

  static Future<Position?> getCurrentLocation() async {
    try {
      // ----------------------------------------------------------
      // Check GPS service
      // ----------------------------------------------------------

      final bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        debugPrint(
          '❌ GPS / Location Service is OFF',
        );

        return null;
      }

      // ----------------------------------------------------------
      // Check permission
      // ----------------------------------------------------------

      final PermissionStatus permission =
          await Permission.locationWhenInUse.status;

      if (!permission.isGranted) {
        debugPrint(
          '❌ GPS requested without location permission',
        );

        return null;
      }

      debugPrint(
        '📍 Getting HIGH ACCURACY GPS position...',
      );

      // ----------------------------------------------------------
      // GET BEST GPS POSITION
      // ----------------------------------------------------------

      final Position position =
    await Geolocator.getCurrentPosition(
  locationSettings: const LocationSettings(
    accuracy: LocationAccuracy.high,
  ),
).timeout(
  const Duration(
    seconds: 20,
  ),
);

      // ----------------------------------------------------------
      // GPS DATA
      // ----------------------------------------------------------

      debugPrint(
        '📍 Latitude: ${position.latitude}',
      );

      debugPrint(
        '📍 Longitude: ${position.longitude}',
      );

      debugPrint(
        '🎯 GPS Accuracy: '
        '${position.accuracy} meters',
      );

      // ----------------------------------------------------------
      // OPTIONAL EXTRA GPS DATA
      // ----------------------------------------------------------

      debugPrint(
        '🛰️ Altitude: ${position.altitude}',
      );

      debugPrint(
        '🚗 Speed: ${position.speed}',
      );

      return position;
    } catch (e) {
      debugPrint(
        '❌ Failed to get current location: $e',
      );

      return null;
    }
  }

  // ============================================================
  // GET LOCATION NAME
  //
  // Priority:
  //
  // 1. SubLocality → Sholinganallur / Velachery etc.
  // 2. Locality     → Chennai etc.
  // 3. Administrative Area → Tamil Nadu etc.
  // ============================================================

  static Future<String?> getLocationName(
    Position position,
  ) async {
    try {
      debugPrint(
        '🏠 Reverse geocoding GPS coordinates...',
      );

      final Geocoding geocoding = Geocoding();

final List<Placemark> placemarks =
    await geocoding.placemarkFromCoordinates(
  position.latitude,
  position.longitude,
).timeout(
  const Duration(
    seconds: 10,
  ),
);

      if (placemarks.isEmpty) {
        debugPrint(
          '❌ No placemark found',
        );

        return null;
      }

      final Placemark place =
          placemarks.first;

      // ----------------------------------------------------------
      // PRINT ALL ADDRESS INFORMATION
      // ----------------------------------------------------------

      debugPrint(
        '🏠 Name: ${place.name}',
      );

      debugPrint(
        '🏘️ Street: ${place.street}',
      );

      debugPrint(
        '🏘️ SubLocality: ${place.subLocality}',
      );

      debugPrint(
        '📍 Locality: ${place.locality}',
      );

      debugPrint(
        '🏙️ AdministrativeArea: '
        '${place.administrativeArea}',
      );

      debugPrint(
        '📮 PostalCode: ${place.postalCode}',
      );

      // ----------------------------------------------------------
      // 1. SUB LOCALITY
      //
      // Example:
      // Sholinganallur
      // Velachery
      // Tambaram
      // ----------------------------------------------------------

      if (place.subLocality != null &&
          place.subLocality!
              .trim()
              .isNotEmpty) {
        return place.subLocality!
            .trim();
      }

      // ----------------------------------------------------------
      // 2. LOCALITY
      //
      // Example:
      // Chennai
      // ----------------------------------------------------------

      if (place.locality != null &&
          place.locality!
              .trim()
              .isNotEmpty) {
        return place.locality!
            .trim();
      }

      // ----------------------------------------------------------
      // 3. ADMINISTRATIVE AREA
      // ----------------------------------------------------------

      if (place.administrativeArea != null &&
          place.administrativeArea!
              .trim()
              .isNotEmpty) {
        return place.administrativeArea!
            .trim();
      }

      // ----------------------------------------------------------
      // NOTHING FOUND
      // ----------------------------------------------------------

      return null;
    } catch (e) {
      debugPrint(
        '❌ Failed to get location name: $e',
      );

      return null;
    }
  }

  // ============================================================
  // BACKGROUND LOCATION
  // ============================================================

  static Future<bool> checkBackgroundLocation() async {
    final PermissionStatus status =
        await Permission.locationAlways.status;

    debugPrint(
      '📍 Background location permission: $status',
    );

    return status.isGranted;
  }
}