import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  // ============================================================
  // CHECK CURRENT NOTIFICATION PERMISSION
  // ============================================================

  static Future<PermissionStatus> checkPermission() async {
    final PermissionStatus status =
        await Permission.notification.status;

    debugPrint(
      '🔔 Current notification permission: $status',
    );

    return status;
  }

  // ============================================================
  // REQUEST NOTIFICATION PERMISSION
  // ============================================================

  static Future<PermissionStatus> requestPermission() async {
    debugPrint(
      '🔔 Requesting notification permission...',
    );

    final PermissionStatus status =
        await Permission.notification.request();

    debugPrint(
      '🔔 Notification permission result: $status',
    );

    return status;
  }

  // ============================================================
  // CHECK WHETHER NOTIFICATION IS READY
  // ============================================================

  static Future<bool> isNotificationReady() async {
    final PermissionStatus status =
        await Permission.notification.status;

    final bool ready = status.isGranted;

    debugPrint(
      '🔔 Notification ready: $ready',
    );

    return ready;
  }

  // ============================================================
  // CHECK PERMANENT DENIAL
  // ============================================================

  static Future<bool>
      isNotificationPermanentlyDenied() async {
    final PermissionStatus status =
        await Permission.notification.status;

    debugPrint(
      '🔔 Notification permanent denial check: $status',
    );

    return status.isPermanentlyDenied;
  }

  // ============================================================
  // OPEN NOTIFICATION SETTINGS
  //
  // ANDROID:
  // Opens:
  //
  // Handzy Thozhan
  //      ↓
  // Notifications
  //
  // NOT generic App Info.
  // ============================================================

  static Future<bool>
      openNotificationSettings() async {
    debugPrint(
      '➡️ Opening Handzy Thozhan Notification Settings',
    );

    // ----------------------------------------------------------
    // ANDROID
    // ----------------------------------------------------------

    if (Platform.isAndroid) {
      try {
        const String packageName =
            'com.handzy.thozhan';

        final AndroidIntent intent =
            AndroidIntent(
          action:
              'android.settings.APP_NOTIFICATION_SETTINGS',

          arguments: <String, dynamic>{
            'android.provider.extra.APP_PACKAGE':
                packageName,
          },
        );

        await intent.launch();

        debugPrint(
          '✅ Notification settings opened',
        );

        return true;
      } catch (e) {
        debugPrint(
          '❌ Failed to open notification settings: $e',
        );

        // ------------------------------------------------------
        // FALLBACK
        // ------------------------------------------------------

        debugPrint(
          '➡️ Opening generic app settings...',
        );

        return await openAppSettings();
      }
    }

    // ----------------------------------------------------------
    // OTHER PLATFORM
    // ----------------------------------------------------------

    return await openAppSettings();
  }
}