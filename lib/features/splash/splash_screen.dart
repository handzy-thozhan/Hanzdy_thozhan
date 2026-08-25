import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../core/theme/app_colors.dart';
import '../../services/location_service.dart';
import '../../services/preferences_service.dart';

import 'splash_controller.dart';
import 'notification_permission_screen.dart';

import '../auth/phone_number_screen.dart';
import '../home/worker_home_screen.dart';

// ============================================================
// SPLASH SCREEN
// ============================================================

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
  });

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

// ============================================================
// STATE
// ============================================================

class _SplashScreenState
    extends State<SplashScreen>
    with
        TickerProviderStateMixin,
        WidgetsBindingObserver {
  // ==========================================================
  // BASIC STATE
  // ==========================================================

  String status =
      'Preparing your workspace...';

  String? locationName;

  bool loading = false;

  bool locationRequired = false;

  bool internetRequired = false;

  // ==========================================================
  // SETTINGS
  // ==========================================================

  bool _openedAppSettings = false;

  bool _openedLocationSettings = false;

  // ==========================================================
  // BRAND INTRO
  // ==========================================================

  bool _showBrandIntro = true;

  late AnimationController _brandController;

  late Animation<double> _brandScale;

  late Animation<double> _brandFade;

  // ==========================================================
  // LOCATION CONTENT ENTRANCE
  // ==========================================================

  late AnimationController
      _locationContentController;

  late Animation<double>
      _locationContentFade;

  late Animation<Offset>
      _locationContentSlide;

  // ==========================================================
  // LOCATION FOUND LOTTIE
  // ==========================================================

  late AnimationController
      _locationFoundController;

  bool _showLocationFound = false;

  bool _locationFoundStarted = false;

  // ==========================================================
  // READY CONTENT
  // ==========================================================

  bool _showLocationReady = false;

  bool _showArea = false;

  bool _showReady = false;

  bool _readyFlowStarted = false;

  // ==========================================================
  // GPS
  // ==========================================================

  bool _gpsSuccess = false;

  // ==========================================================
  // REGISTERED USER
  // ==========================================================

  bool _registeredUser = false;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(
      this,
    );

    // ========================================================
    // BRAND INTRO
    // ========================================================

    _brandController =
        AnimationController(
      vsync: this,
      duration:
          const Duration(
        milliseconds: 500,
      ),
    );

    _brandScale =
        Tween<double>(
      begin: 0.55,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent:
            _brandController,
        curve:
            Curves.easeOutBack,
      ),
    );

    _brandFade =
        Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent:
            _brandController,
        curve:
            Curves.easeOut,
      ),
    );

    // ========================================================
    // LOCATION CONTENT ANIMATION
    // ========================================================

    _locationContentController =
        AnimationController(
      vsync: this,
      duration:
          const Duration(
        milliseconds: 650,
      ),
    );

    _locationContentFade =
        Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent:
            _locationContentController,
        curve:
            Curves.easeOut,
      ),
    );

    _locationContentSlide =
        Tween<Offset>(
      begin:
          const Offset(
        0,
        0.18,
      ),
      end:
          Offset.zero,
    ).animate(
      CurvedAnimation(
        parent:
            _locationContentController,
        curve:
            Curves.easeOutCubic,
      ),
    );

    // ========================================================
    // LOCATION FOUND LOTTIE CONTROLLER
    // ========================================================

    _locationFoundController =
        AnimationController(
      vsync: this,
    );

    // ========================================================
    // START
    // ========================================================

    _startBrandIntro();

    _startApp();
  }

  // ============================================================
  // BRAND INTRO
  // ============================================================

  Future<void> _startBrandIntro() async {
    debugPrint(
      '🎬 Starting Handzy Thozhan logo intro...',
    );

    await _brandController.forward();

    if (!mounted) {
      return;
    }

    await Future.delayed(
      const Duration(
        milliseconds: 1000,
      ),
    );

    if (!mounted) {
      return;
    }

    await _brandController.reverse();

    if (!mounted) {
      return;
    }

    setState(() {
      _showBrandIntro = false;
    });

    debugPrint(
      '🎬 Logo intro completed',
    );

    await WidgetsBinding.instance
        .endOfFrame;

    if (!mounted) {
      return;
    }

    await _locationContentController
        .forward();
  }

  // ============================================================
  // APP LIFECYCLE
  // ============================================================

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    debugPrint(
      '🔄 App lifecycle: $state',
    );

    if (state !=
        AppLifecycleState.resumed) {
      return;
    }

    if (_openedLocationSettings &&
        !loading) {
      debugPrint(
        '📍 Returned from Location Settings',
      );

      _openedLocationSettings = false;

      _startApp();

      return;
    }

    if (_openedAppSettings &&
        !loading) {
      debugPrint(
        '📍 Returned from App Settings',
      );

      _openedAppSettings = false;

      _startApp();

      return;
    }
  }

  // ============================================================
  // START APP
  // ============================================================

  Future<void> _startApp() async {
    if (loading) {
      debugPrint(
        '⚠️ Location flow already running',
      );

      return;
    }

    if (!mounted) {
      return;
    }

    // ========================================================
    // RESET
    // ========================================================

    _gpsSuccess = false;

    _locationFoundStarted = false;

    _readyFlowStarted = false;

    _locationFoundController.reset();

    setState(() {
      loading = true;

      internetRequired = false;

      locationRequired = false;

      locationName = null;

      _showLocationFound = false;

      _showLocationReady = false;

      _showArea = false;

      _showReady = false;

      _registeredUser = false;

      status =
          'Checking your connection...';
    });

    debugPrint(
      '🚀 Starting internet + location flow...',
    );

    // ========================================================
    // EXISTING SPLASH CONTROLLER
    // ========================================================

    final SplashFlowResult result =
        await SplashController.startApp(
      context,
    );

    if (!mounted) {
      return;
    }

    // ========================================================
    // INTERNET REQUIRED
    // ========================================================

    if (result.status ==
        SplashFlowStatus.internetRequired) {
      debugPrint(
        '❌ Internet is required',
      );

      setState(() {
        loading = false;

        internetRequired = true;

        locationRequired = false;

        status =
            'Internet connection is required';
      });

      return;
    }

    // ========================================================
    // LOCATION REQUIRED
    // ========================================================

    if (result.status ==
        SplashFlowStatus.locationRequired) {
      debugPrint(
        '❌ Location is required',
      );

      setState(() {
        loading = false;

        internetRequired = false;

        locationRequired = true;

        status =
            'Location is required';
      });

      return;
    }

    // ========================================================
    // GPS SUCCESS
    // ========================================================

    debugPrint(
      '✅ GPS LOCATION SUCCESS',
    );

    debugPrint(
      '📍 Location: ${result.locationName}',
    );

    setState(() {
      loading = false;

      internetRequired = false;

      locationRequired = false;

      locationName =
          result.locationName;

      status =
          'Location found';

      _gpsSuccess = true;

      _registeredUser =
          result.registeredUser;

      _showLocationFound = true;
    });

    // ========================================================
    // LOCATION FOUND ANIMATION
    // ========================================================

    await _playLocationFoundAnimation();

    if (!mounted) {
      return;
    }

    // ========================================================
    // READY CONTENT
    // ========================================================

    await _showReadyContent();

    if (!mounted) {
      return;
    }

    // ========================================================
    // CONTINUE
    // ========================================================

    await _continueAfterReady();
  }

  // ============================================================
  // LOCATION FOUND ANIMATION
  // ============================================================

  Future<void> _playLocationFoundAnimation() async {
    if (!mounted) {
      return;
    }

    debugPrint(
      '📍 Location Found animation starting...',
    );

    debugPrint(
      '📍 Location Found animation flow released',
    );
  }

  // ============================================================
  // READY CONTENT
  // ============================================================

  Future<void>
      _showReadyContent() async {
    if (!mounted) {
      return;
    }

    if (_readyFlowStarted) {
      return;
    }

    _readyFlowStarted = true;

    // ========================================================
    // LOCATION READY
    // ========================================================

    setState(() {
      _showLocationReady = true;

      status =
          'Location ready';
    });

    debugPrint(
      '📍 Location ready',
    );

    await Future.delayed(
      const Duration(
        milliseconds: 400,
      ),
    );

    if (!mounted) {
      return;
    }

    // ========================================================
    // WORK AREA
    // ========================================================

    setState(() {
      _showArea = true;
    });

    debugPrint(
      '📍 Work area shown: $locationName',
    );

    await Future.delayed(
      const Duration(
        milliseconds: 650,
      ),
    );

    if (!mounted) {
      return;
    }

    // ========================================================
    // READY TO WORK
    // ========================================================

    setState(() {
      _showReady = true;

      status =
          'Ready to work';
    });

    debugPrint(
      '🚀 Worker is ready to work',
    );
  }

  // ============================================================
  // CONTINUE AFTER READY
  // ============================================================

  Future<void>
      _continueAfterReady() async {
    if (!mounted) {
      return;
    }

    await Future.delayed(
      const Duration(
        milliseconds: 700,
      ),
    );

    if (!mounted) {
      return;
    }

    // ========================================================
    // REGISTERED USER → REAL HOME
    // ========================================================

    if (_registeredUser) {
      debugPrint(
        '👤 Registered user detected',
      );

      debugPrint(
        '🏠 Going to REAL HOME',
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (BuildContext context) =>
                  const WorkerHomeScreen(),
        ),
      );

      return;
    }

    // ========================================================
    // NEW USER
    // ========================================================

    final bool notificationCompleted =
        await _isNotificationCompleted();

    if (!mounted) {
      return;
    }

    if (notificationCompleted) {
      debugPrint(
        '🔔 Notification already completed',
      );

      debugPrint(
        '📱 Going to Phone Number',
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (BuildContext context) =>
                  const PhoneNumberScreen(),
        ),
      );

      return;
    }

    debugPrint(
      '🔔 Opening Notification Permission',
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (BuildContext context) =>
                const NotificationPermissionScreen(),
      ),
    );
  }

  // ============================================================
  // NOTIFICATION COMPLETED
  // ============================================================

  Future<bool>
      _isNotificationCompleted() async {
    return PreferencesService
        .isNotificationCompleted();
  }

  // ============================================================
  // INTERNET BUTTON
  // ============================================================

  Future<void>
      _handleInternetButton() async {
    if (loading) {
      return;
    }

    debugPrint(
      '🌐 Check Internet button pressed',
    );

    await _startApp();
  }

  // ============================================================
  // LOCATION BUTTON
  // ============================================================

  Future<void>
      _handleLocationButton() async {
    if (loading) {
      return;
    }

    debugPrint(
      '📍 Allow Location button pressed',
    );

    final bool locationServiceEnabled =
        await LocationService
            .isLocationServiceEnabled();

    if (!mounted) {
      return;
    }

    if (!locationServiceEnabled) {
      debugPrint(
        '❌ GPS is OFF',
      );

      _openedLocationSettings = true;

      await LocationService
          .openLocationSettings();

      return;
    }

    final bool permanentlyDenied =
        await LocationService
            .isLocationPermanentlyDenied();

    if (!mounted) {
      return;
    }

    if (permanentlyDenied) {
      debugPrint(
        '❌ Location permission permanently denied',
      );

      _openedAppSettings = true;

      await LocationService
          .openLocationAppSettings();

      return;
    }

    debugPrint(
      '📍 Requesting location normally...',
    );

    await _startApp();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    WidgetsBinding.instance
        .removeObserver(this);

    _brandController.dispose();

    _locationContentController
        .dispose();

    _locationFoundController.dispose();

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
      backgroundColor:
          AppColors.background,

      body:
          SafeArea(
        child:
            Stack(
          children: [
            // ==================================================
            // BRAND INTRO
            // ==================================================

            if (_showBrandIntro)
              Center(
                child:
                    FadeTransition(
                  opacity:
                      _brandFade,

                  child:
                      ScaleTransition(
                    scale:
                        _brandScale,

                    child:
                        Container(
                      width:
                          125,

                      height:
                          125,

                      padding:
                          const EdgeInsets
                              .all(
                        10,
                      ),

                      decoration:
                          BoxDecoration(
                        shape:
                            BoxShape.circle,

                        color:
                            Colors.white,

                        boxShadow: [
                          BoxShadow(
                            color:
                                AppColors
                                    .secondary
                                    .withValues(
                              alpha:
                                  0.24,
                            ),

                            blurRadius:
                                35,

                            spreadRadius:
                                5,
                          ),
                        ],
                      ),

                      child:
                          Image.asset(
                        'assets/image/'
                        'handzy_thozhan_logo.png',

                        fit:
                            BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),

            // ==================================================
            // MAIN CONTENT
            // ==================================================

            if (!_showBrandIntro)
              FadeTransition(
                opacity:
                    _locationContentFade,

                child:
                    SlideTransition(
                  position:
                      _locationContentSlide,

                  child:
                      Center(
                    child:
                        SingleChildScrollView(
                      physics:
                          const BouncingScrollPhysics(),

                      child:
                          Padding(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal:
                              28,

                          vertical:
                              20,
                        ),

                        child:
                            Column(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,

                          children: [
                            // ==================================
                            // FETCHING LOCATION
                            // ==================================

                            if (loading)
                              _buildGpsFetchingSection(),

                            // ==================================
                            // LOCATION FOUND
                            // ==================================

                            if (!loading &&
                                !internetRequired &&
                                !locationRequired &&
                                _showLocationFound)
                              _buildLocationFoundSection(),

                            // ==================================
                            // INTERNET REQUIRED
                            // ==================================

                            if (!loading &&
                                internetRequired)
                              _buildInternetRequiredSection(),

                            // ==================================
                            // LOCATION REQUIRED
                            // ==================================

                            if (!loading &&
                                locationRequired)
                              _buildLocationRequiredSection(),

                            // ==================================
                            // FOOTER
                            // ==================================

                            if (!_showLocationFound &&
                                !_gpsSuccess)
                              const Column(
                                children: [
                                  SizedBox(
                                    height:
                                        70,
                                  ),

                                  Text(
                                    'HANDZY • WORK MADE EASY',

                                    textAlign:
                                        TextAlign.center,

                                    style:
                                        TextStyle(
                                      color:
                                          AppColors
                                              .primary,

                                      fontSize:
                                          12,

                                      fontWeight:
                                          FontWeight
                                              .w700,

                                      letterSpacing:
                                          1.2,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // FETCHING LOCATION
  // ============================================================

  Widget _buildGpsFetchingSection() {
    return Column(
      mainAxisSize:
          MainAxisSize.min,

      children: [
        SizedBox(
          width:
              300,

          height:
              300,

          child:
              Lottie.asset(
            'assets/animations/'
            'handzy_fetching_location.json',

            repeat:
                true,

            fit:
                BoxFit.contain,
          ),
        ),

        const SizedBox(
          height:
              10,
        ),

        const Text(
          'Finding your work area',

          textAlign:
              TextAlign.center,

          style:
              TextStyle(
            color:
                AppColors.primary,

            fontSize:
                19,

            fontWeight:
                FontWeight.w800,
          ),
        ),

        const SizedBox(
          height:
              8,
        ),

        Text(
          'Fetching your current location...',

          textAlign:
              TextAlign.center,

          style:
              TextStyle(
            color:
                AppColors.textSecondary
                    .withValues(
              alpha:
                  0.80,
            ),

            fontSize:
                13,

            fontWeight:
                FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // LOCATION FOUND
  // ============================================================

  Widget _buildLocationFoundSection() {
    return Column(
      mainAxisSize:
          MainAxisSize.min,

      children: [
        SizedBox(
          width:
              300,

          height:
              300,

          child:
              Lottie.asset(
            'assets/animations/'
            'handzy_location_found.json',

            controller:
                _locationFoundController,

            repeat:
                false,

            fit:
                BoxFit.contain,

            onLoaded: (
              LottieComposition composition,
            ) {
              _locationFoundController
                  .duration =
                  composition.duration;

              if (!_locationFoundStarted) {
                _locationFoundStarted = true;

                debugPrint(
                  '📍 Location Found Lottie started',
                );

                _locationFoundController
                    .forward();
              }
            },
          ),
        ),

        AnimatedOpacity(
          duration:
              const Duration(
            milliseconds:
                350,
          ),

          opacity:
              _showLocationReady
                  ? 1.0
                  : 0.0,

          child:
              const Text(
            'Location ready',

            textAlign:
                TextAlign.center,

            style:
                TextStyle(
              color:
                  AppColors.primary,

              fontSize:
                  20,

              fontWeight:
                  FontWeight.w800,
            ),
          ),
        ),

        const SizedBox(
          height:
              10,
        ),

        AnimatedOpacity(
          duration:
              const Duration(
            milliseconds:
                500,
          ),

          opacity:
              _showArea
                  ? 1.0
                  : 0.0,

          child:
              Column(
            children: [
              const Text(
                'Your work area',

                textAlign:
                    TextAlign.center,

                style:
                    TextStyle(
                  color:
                      AppColors.textSecondary,

                  fontSize:
                      14,

                  fontWeight:
                      FontWeight.w500,
                ),
              ),

              const SizedBox(
                height:
                    5,
              ),

              Text(
                locationName ??
                    'Current location',

                textAlign:
                    TextAlign.center,

                style:
                    const TextStyle(
                  color:
                      AppColors.primary,

                  fontSize:
                      28,

                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(
          height:
              13,
        ),

        AnimatedOpacity(
          duration:
              const Duration(
            milliseconds:
                500,
          ),

          opacity:
              _showReady
                  ? 1.0
                  : 0.0,

          child:
              const Text(
            'Ready to work 🚀',

            textAlign:
                TextAlign.center,

            style:
                TextStyle(
              color:
                  AppColors.textPrimary,

              fontSize:
                  16,

              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // INTERNET REQUIRED
  // ============================================================

  Widget
      _buildInternetRequiredSection() {
    return Column(
      children: [
        Container(
          width:
              78,

          height:
              78,

          decoration:
              BoxDecoration(
            shape:
                BoxShape.circle,

            color:
                AppColors.lightTeal,

            boxShadow: [
              BoxShadow(
                color:
                    AppColors.secondary
                        .withValues(
                  alpha:
                      0.18,
                ),

                blurRadius:
                    25,

                spreadRadius:
                    4,
              ),
            ],
          ),

          child:
              const Icon(
            Icons.wifi_off_rounded,

            color:
                AppColors.primary,

            size:
                40,
          ),
        ),

        const SizedBox(
          height:
              22,
        ),

        const Text(
          'Internet Required',

          textAlign:
              TextAlign.center,

          style:
              TextStyle(
            color:
                AppColors.textPrimary,

            fontSize:
                22,

            fontWeight:
                FontWeight.w800,
          ),
        ),

        const SizedBox(
          height:
              12,
        ),

        const Text(
          'Turn on your internet connection to continue\n'
          'and find nearby customer requests.',

          textAlign:
              TextAlign.center,

          style:
              TextStyle(
            color:
                AppColors.textSecondary,

            fontSize:
                14,

            height:
                1.5,
          ),
        ),

        const SizedBox(
          height:
              26,
        ),

        SizedBox(
          width:
              double.infinity,

          height:
              54,

          child:
              ElevatedButton(
            onPressed:
                _handleInternetButton,

            child:
                const Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,

              children: [
                Icon(
                  Icons.wifi_rounded,

                  color:
                      AppColors.textOnPrimary,
                ),

                SizedBox(
                  width:
                      9,
                ),

                Text(
                  'Check Internet Again',

                  style:
                      TextStyle(
                    fontSize:
                        16,

                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // LOCATION REQUIRED
  // ============================================================

  Widget
      _buildLocationRequiredSection() {
    return Column(
      children: [
        Container(
          width:
              68,

          height:
              68,

          decoration:
              BoxDecoration(
            shape:
                BoxShape.circle,

            color:
                AppColors.lightTeal,
          ),

          child:
              const Icon(
            Icons.location_off_rounded,

            color:
                AppColors.primary,

            size:
                34,
          ),
        ),

        const SizedBox(
          height:
              20,
        ),

        const Text(
          'Location Required',

          textAlign:
              TextAlign.center,

          style:
              TextStyle(
            color:
                AppColors.textPrimary,

            fontSize:
                22,

            fontWeight:
                FontWeight.w800,
          ),
        ),

        const SizedBox(
          height:
              12,
        ),

        const Text(
          'Turn on location to continue\n'
          'and receive nearby jobs.',

          textAlign:
              TextAlign.center,

          style:
              TextStyle(
            color:
                AppColors.textSecondary,

            fontSize:
                14,

            height:
                1.5,
          ),
        ),

        const SizedBox(
          height:
              25,
        ),

        SizedBox(
          width:
              double.infinity,

          height:
              54,

          child:
              ElevatedButton(
            onPressed:
                _handleLocationButton,

            child:
                const Text(
              'Turn On Location',

              style:
                  TextStyle(
                fontSize:
                    16,

                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}