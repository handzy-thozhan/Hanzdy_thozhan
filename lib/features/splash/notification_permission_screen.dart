import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/theme/app_colors.dart';
import '../../services/notification_service.dart';
import '../auth/phone_number_screen.dart';

class NotificationPermissionScreen extends StatefulWidget {
  const NotificationPermissionScreen({
    super.key,
  });

  @override
  State<NotificationPermissionScreen> createState() =>
      _NotificationPermissionScreenState();
}

class _NotificationPermissionScreenState
    extends State<NotificationPermissionScreen>
    with WidgetsBindingObserver {
  // ============================================================
  // STATE
  // ============================================================

  bool _loading = false;

  bool _notificationRequired = false;

  bool _openedSettings = false;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _startNotificationFlow();
  }

  // ============================================================
  // APP LIFECYCLE
  //
  // Notification Settings -> Back
  // Automatically check permission
  // ============================================================

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    debugPrint(
      '🔄 Notification screen lifecycle: $state',
    );

    if (state != AppLifecycleState.resumed) {
      return;
    }

    if (_openedSettings) {
      debugPrint(
        '🔔 Returned from Notification Settings',
      );

      _openedSettings = false;

      _checkAfterSettings();
    }
  }

  // ============================================================
  // START NOTIFICATION FLOW
  //
  // FIRST TIME:
  //
  // System notification popup
  //
  // ALLOW
  //   ↓
  // Next page immediately
  //
  // DON'T ALLOW
  //   ↓
  // Notification Required
  // ============================================================

  Future<void> _startNotificationFlow() async {
    if (!mounted) {
      return;
    }

    debugPrint(
      '🔔 Starting notification permission flow...',
    );

    // ==========================================================
    // CHECK CURRENT PERMISSION
    // ==========================================================

    final bool ready =
        await NotificationService.isNotificationReady();

    if (!mounted) {
      return;
    }

    // ==========================================================
    // ALREADY GRANTED
    // ==========================================================

    if (ready) {
      debugPrint(
        '✅ Notification already granted',
      );

      await _goToNextPage();

      return;
    }

    // ==========================================================
    // REQUEST SYSTEM PERMISSION
    // ==========================================================

    setState(() {
      _loading = true;
      _notificationRequired = false;
    });

    final PermissionStatus permission =
        await NotificationService.requestPermission();

    if (!mounted) {
      return;
    }

    debugPrint(
      '🔔 Notification permission result: $permission',
    );

    // ==========================================================
    // ALLOWED
    //
    // IMPORTANT:
    // DON'T SET _loading = false.
    //
    // This prevents the notification screen from
    // appearing for a few seconds before next page.
    // ==========================================================

    if (permission == PermissionStatus.granted) {
      debugPrint(
        '✅ User allowed notifications',
      );

      await _goToNextPage();

      return;
    }

    // ==========================================================
    // DON'T ALLOW
    // ==========================================================

    debugPrint(
      '❌ User did not allow notifications',
    );

    setState(() {
      _loading = false;
      _notificationRequired = true;
    });
  }

  // ============================================================
  // CHECK AFTER SETTINGS
  //
  // Settings -> ON -> Back
  // Automatically checks permission
  // ============================================================

  Future<void> _checkAfterSettings() async {
    if (!mounted) {
      return;
    }

    debugPrint(
      '🔔 Checking notification permission after settings...',
    );

    // ==========================================================
    // HIDE OLD "OPEN SETTINGS" STATE IMMEDIATELY
    // ==========================================================

    setState(() {
      _loading = true;
      _notificationRequired = false;
    });

    // ==========================================================
    // SMALL DELAY FOR ANDROID
    // ==========================================================

    await Future.delayed(
      const Duration(
        milliseconds: 300,
      ),
    );

    if (!mounted) {
      return;
    }

    // ==========================================================
    // CHECK PERMISSION
    // ==========================================================

    final bool ready =
        await NotificationService.isNotificationReady();

    if (!mounted) {
      return;
    }

    debugPrint(
      '🔔 Notification ready after settings: $ready',
    );

    // ==========================================================
    // ENABLED
    // ==========================================================

    if (ready) {
      debugPrint(
        '✅ Notification enabled from Settings',
      );

      // Keep loading state.
      // Go directly to next page.
      await _goToNextPage();

      return;
    }

    // ==========================================================
    // STILL DISABLED
    // ==========================================================

    debugPrint(
      '❌ Notification still disabled',
    );

    setState(() {
      _loading = false;
      _notificationRequired = true;
    });
  }

  // ============================================================
  // OPEN NOTIFICATION SETTINGS
  // ============================================================

  Future<void> _openNotificationSettings() async {
    if (_loading) {
      return;
    }

    debugPrint(
      '➡️ Opening Notification Settings...',
    );

    _openedSettings = true;

    await NotificationService.openNotificationSettings();
  }

  // ============================================================
  // NEXT PAGE
  //
  // Notification complete
  //      ↓
  // Phone Number Screen
  // ============================================================

  Future<void> _goToNextPage() async {
    if (!mounted) {
      return;
    }

    debugPrint(
      '🎉 Notification flow completed',
    );

    // Very small transition delay only.
    // No UI state is changed here.
    await Future.delayed(
      const Duration(
        milliseconds: 150,
      ),
    );

    if (!mounted) {
      return;
    }

    debugPrint(
      '📱 Opening phone number screen...',
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const PhoneNumberScreen(),
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),

            padding: const EdgeInsets.symmetric(
              horizontal: 28,
              vertical: 24,
            ),

            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,

              children: [
                // ==================================================
                // NOTIFICATION ICON
                // ==================================================

                Container(
                  width: 100,
                  height: 100,

                  decoration: BoxDecoration(
                    shape: BoxShape.circle,

                    color: AppColors.lightTeal,

                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondary.withValues(
                          alpha: 0.18,
                        ),

                        blurRadius: 25,

                        spreadRadius: 4,
                      ),
                    ],
                  ),

                  child: const Icon(
                    Icons.notifications_active_rounded,

                    color: AppColors.primary,

                    size: 52,
                  ),
                ),

                const SizedBox(
                  height: 28,
                ),

                // ==================================================
                // TITLE
                // ==================================================

                Text(
                  _notificationRequired
                      ? 'Notification Required'
                      : 'Allow Notifications',

                  textAlign: TextAlign.center,

                  style: const TextStyle(
                    color: AppColors.textPrimary,

                    fontSize: 24,

                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(
                  height: 14,
                ),

                // ==================================================
                // DESCRIPTION
                // ==================================================

                Text(
                  _notificationRequired
                      ? 'Turn on notifications to receive\n'
                        'new customer requests and important updates.'
                      : 'Allow notifications to receive\n'
                        'new customer requests and important updates.',

                  textAlign: TextAlign.center,

                  style: const TextStyle(
                    color: AppColors.textSecondary,

                    fontSize: 14,

                    height: 1.5,
                  ),
                ),

                const SizedBox(
                  height: 32,
                ),

                // ==================================================
                // BUTTON
                // ==================================================

                SizedBox(
                  width: double.infinity,

                  height: 54,

                  child: ElevatedButton(
                    onPressed:
                        _loading
                            ? null
                            : _notificationRequired
                                ? _openNotificationSettings
                                : _startNotificationFlow,

                    child:
                        _loading
                            ? const SizedBox(
                                width: 24,
                                height: 24,

                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 3,

                                  color:
                                      AppColors.textOnPrimary,
                                ),
                              )
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,

                                children: [
                                  Icon(
                                    _notificationRequired
                                        ? Icons.settings
                                        : Icons
                                            .notifications_active_rounded,

                                    color:
                                        AppColors.textOnPrimary,
                                  ),

                                  const SizedBox(
                                    width: 9,
                                  ),

                                  Text(
                                    _notificationRequired
                                        ? 'Open Settings'
                                        : 'Allow Notifications',

                                    style: const TextStyle(
                                      fontSize: 16,

                                      fontWeight:
                                          FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}