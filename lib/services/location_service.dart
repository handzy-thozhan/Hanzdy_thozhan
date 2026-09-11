import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  // ============================================================
  // CHECK PHONE LOCATION SERVICE
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

    if (status.isGranted) {
      debugPrint(
        '✅ Location permission already granted',
      );

      return true;
    }

    if (status.isPermanentlyDenied) {
      debugPrint(
        '❌ Location permission permanently denied',
      );

      return false;
    }

    debugPrint(
      '📍 Requesting location permission...',
    );

    status =
        await Permission.locationWhenInUse.request();

    debugPrint(
      '📍 Permission after request: $status',
    );

    if (status.isGranted) {
      debugPrint(
        '✅ Location permission granted',
      );

      return true;
    }

    if (status.isPermanentlyDenied) {
      debugPrint(
        '❌ Location permission became permanently denied',
      );

      return false;
    }

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
  // ============================================================

  static Future<Position?> getCurrentLocation() async {
    try {
      // --------------------------------------------------------
      // CHECK GPS SERVICE
      // --------------------------------------------------------

      final bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        debugPrint(
          '❌ GPS / Location Service is OFF',
        );

        return null;
      }

      // --------------------------------------------------------
      // CHECK PERMISSION
      // --------------------------------------------------------

      final PermissionStatus permission =
          await Permission.locationWhenInUse.status;

      if (!permission.isGranted) {
        debugPrint(
          '❌ GPS requested without location permission',
        );

        return null;
      }

      debugPrint(
        '📍 Getting high accuracy GPS position...',
      );

      // --------------------------------------------------------
      // GET GPS POSITION
      // --------------------------------------------------------

      final Position position =
          await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(
        const Duration(seconds: 20),
      );

      // --------------------------------------------------------
      // PRINT GPS DATA
      // --------------------------------------------------------

      debugPrint(
        '📍 Latitude: ${position.latitude}',
      );

      debugPrint(
        '📍 Longitude: ${position.longitude}',
      );

      debugPrint(
        '🎯 GPS Accuracy: ${position.accuracy} meters',
      );

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
  // ============================================================

  static Future<String?> getLocationName(
    Position position,
  ) async {
    try {
      debugPrint(
        '🏠 Reverse geocoding GPS coordinates...',
      );

      final Geocoding geocodingService =
          Geocoding();

      final List<Placemark> placemarks =
          await geocodingService
              .placemarkFromCoordinates(
                position.latitude,
                position.longitude,
              )
              .timeout(
                const Duration(seconds: 10),
              );

      if (placemarks.isEmpty) {
        debugPrint(
          '❌ No placemark found',
        );

        return null;
      }

      final Placemark place =
          placemarks.first;

      // --------------------------------------------------------
      // PRINT COMPLETE ADDRESS DATA
      // --------------------------------------------------------

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
        '🏙️ SubAdministrativeArea: '
        '${place.subAdministrativeArea}',
      );

      debugPrint(
        '🏙️ AdministrativeArea: '
        '${place.administrativeArea}',
      );

      debugPrint(
        '📮 PostalCode: ${place.postalCode}',
      );

      debugPrint(
        '🌍 Country: ${place.country}',
      );

      // --------------------------------------------------------
      // PRIORITY 1 - SUB LOCALITY
      //
      // Example:
      // Karapakkam
      // Sholinganallur
      // Velachery
      // Thoraipakkam
      // --------------------------------------------------------

      final String? subLocality =
          _cleanLocationValue(
        place.subLocality,
      );

      if (subLocality != null) {
        debugPrint(
          '✅ Selected SubLocality: $subLocality',
        );

        return subLocality;
      }

      // --------------------------------------------------------
      // PRIORITY 2 - LOCALITY
      //
      // Example:
      // Chennai
      // Tambaram
      // --------------------------------------------------------

      final String? locality =
          _cleanLocationValue(
        place.locality,
      );

      if (locality != null) {
        debugPrint(
          '📍 Selected Locality: $locality',
        );

        return locality;
      }

      // --------------------------------------------------------
      // PRIORITY 3 - SUB ADMINISTRATIVE AREA
      //
      // Example:
      // Chennai
      // Chengalpattu
      // Kanchipuram
      // --------------------------------------------------------

      final String? subAdministrativeArea =
          _cleanLocationValue(
        place.subAdministrativeArea,
      );

      if (subAdministrativeArea != null) {
        debugPrint(
          '📍 Selected SubAdministrativeArea: '
          '$subAdministrativeArea',
        );

        return subAdministrativeArea;
      }

      // --------------------------------------------------------
      // PRIORITY 4 - ADMINISTRATIVE AREA
      //
      // Example:
      // Tamil Nadu
      // --------------------------------------------------------

      final String? administrativeArea =
          _cleanLocationValue(
        place.administrativeArea,
      );

      if (administrativeArea != null) {
        debugPrint(
          '📍 Selected AdministrativeArea: '
          '$administrativeArea',
        );

        return administrativeArea;
      }

      // --------------------------------------------------------
      // NOTHING FOUND
      // --------------------------------------------------------

      debugPrint(
        '❌ No valid location name found',
      );

      return null;
    } catch (e) {
      debugPrint(
        '❌ Failed to get location name: $e',
      );

      return null;
    }
  }

  // ============================================================
  // CLEAN LOCATION VALUE
  // ============================================================

  static String? _cleanLocationValue(
    String? value,
  ) {
    if (value == null) {
      return null;
    }

    final String cleanedValue =
        value.trim();

    if (cleanedValue.isEmpty) {
      return null;
    }

    if (_isCommonCityOrState(
      cleanedValue,
    )) {
      return null;
    }

    return cleanedValue;
  }

  // ============================================================
  // IGNORE COMMON CITY / STATE / COUNTRY NAMES
  // ============================================================

  static bool _isCommonCityOrState(
    String value,
  ) {
    final String text =
        value.trim().toLowerCase();

    const List<String> blockedNames = [
      'chennai',
      'tamil nadu',
      'tamilnadu',
      'india',
      'indian union',
      'bharat',
      'भारत',
    ];

    return blockedNames.contains(text);
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