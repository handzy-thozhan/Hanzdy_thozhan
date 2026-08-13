import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../services/location_service.dart';
import '../../services/preferences_service.dart';

import 'splash_controller.dart';
import 'worker_ready_animation.dart';
import 'notification_permission_screen.dart';

import '../auth/phone_number_screen.dart';

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
  // GPS PING
  // ==========================================================

  late AnimationController _loaderController;

  // ==========================================================
  // WORKER READY
  // ==========================================================

  bool _workerReady = false;

  bool _showLocationReady = false;

  bool _showArea = false;

  bool _showReady = false;

  // ==========================================================
  // WORKER CONTROL
  // ==========================================================

  bool _gpsSuccess = false;

  bool _workerAnimationStarted = false;

  // ==========================================================
  // REGISTERED USER
  // ==========================================================

  bool _registeredUser = false;

  // ==========================================================
  // WORKER ANIMATION KEY
  // ==========================================================

  final GlobalKey<WorkerReadyAnimationState>
      _workerAnimationKey =
      GlobalKey<WorkerReadyAnimationState>();

  // ==========================================================
  // INIT
  // ==========================================================

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
    // LOCATION CONTENT
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
    // GPS PING
    //
    // THIS IS YOUR ORIGINAL PING/BLINK ANIMATION.
    // ========================================================

    _loaderController =
        AnimationController(
      vsync: this,
      duration:
          const Duration(
        milliseconds: 1300,
      ),
    )..repeat();

    // ========================================================
    // START FLOWS
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

    // 0 → 0.5 sec
    await _brandController.forward();

    if (!mounted) {
      return;
    }

    // 0.5 → 1.5 sec
    await Future.delayed(
      const Duration(
        milliseconds: 1000,
      ),
    );

    if (!mounted) {
      return;
    }

    // 1.5 → 2 sec
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

    // ========================================================
    // LOCATION CONTENT
    // ========================================================

    await _locationContentController
        .forward();

    if (!mounted) {
      return;
    }

    // ========================================================
    // IF GPS IS ALREADY READY
    // START WORKER IMMEDIATELY
    // ========================================================

    await _tryStartWorkerAnimation();
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

    // ========================================================
    // LOCATION SETTINGS
    // ========================================================

    if (_openedLocationSettings &&
        !loading) {
      debugPrint(
        '📍 Returned from Location Settings',
      );

      _openedLocationSettings = false;

      _startApp();

      return;
    }

    // ========================================================
    // APP SETTINGS
    // ========================================================

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
  // START LOCATION FLOW
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

    _workerAnimationStarted = false;

    setState(() {
      loading = true;

      internetRequired = false;

      locationRequired = false;

      locationName = null;

      _workerReady = false;

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
    // SPLASH CONTROLLER
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

    // ========================================================
    // IMPORTANT
    //
    // Location name is stored immediately.
    // It will be visible in worker section.
    // ========================================================

    setState(() {
      loading = false;

      internetRequired = false;

      locationRequired = false;

      locationName =
          result.locationName;

      status =
          'Location found';

      _gpsSuccess = true;

      // VERY IMPORTANT:
      // Controller tells us registered status.
      _registeredUser =
          result.registeredUser;
    });

    // ========================================================
    // SHOW WORKER SECTION
    // ========================================================

    await _playWorkerReadyAnimation();

    if (!mounted) {
      return;
    }

    // ========================================================
    // TRY WORKER ANIMATION
    //
    // If logo still running:
    //     wait.
    //
    // If logo already finished:
    //     start immediately.
    // ========================================================

    await _tryStartWorkerAnimation();
  }

  // ============================================================
  // SHOW WORKER SECTION
  // ============================================================

  Future<void>
      _playWorkerReadyAnimation() async {
    if (!mounted) {
      return;
    }

    debugPrint(
      '👷 Preparing worker animation section...',
    );

    setState(() {
      _workerReady = true;

      _showLocationReady = false;

      _showArea = false;

      _showReady = false;
    });

    debugPrint(
      '👷 Worker animation section displayed',
    );
  }

  // ============================================================
  // START WORKER VIDEO
  // ============================================================

  Future<void>
      _tryStartWorkerAnimation() async {
    if (!mounted) {
      return;
    }

    // ========================================================
    // GPS MUST BE READY
    // ========================================================

    if (!_gpsSuccess) {
      debugPrint(
        '⏳ Waiting for GPS success...',
      );

      return;
    }

    // ========================================================
    // LOGO MUST BE FINISHED
    // ========================================================

    if (_showBrandIntro) {
      debugPrint(
        '⏳ GPS done, waiting for logo...',
      );

      return;
    }

    // ========================================================
    // PREVENT DUPLICATE PLAY
    // ========================================================

    if (_workerAnimationStarted) {
      return;
    }

    // ========================================================
    // WORKER WIDGET MUST EXIST
    // ========================================================

    if (!_workerReady) {
      debugPrint(
        '⏳ Worker section not displayed...',
      );

      return;
    }

    // ========================================================
    // WAIT ONE FRAME
    // ========================================================

    await WidgetsBinding.instance
        .endOfFrame;

    if (!mounted) {
      return;
    }

    WorkerReadyAnimationState?
        workerState =
        _workerAnimationKey.currentState;

    // ========================================================
    // WAIT FOR VIDEO WIDGET
    // ========================================================

    if (workerState == null) {
      debugPrint(
        '⏳ Waiting for worker video widget...',
      );

      await Future.delayed(
        const Duration(
          milliseconds: 100,
        ),
      );

      if (!mounted) {
        return;
      }

      workerState =
          _workerAnimationKey.currentState;
    }

    if (workerState == null) {
      debugPrint(
        '❌ Worker animation state unavailable',
      );

      return;
    }

    // ========================================================
    // MARK STARTED
    // ========================================================

    _workerAnimationStarted = true;

    debugPrint(
      '👷 GPS + Logo ready → Worker animation START',
    );

    // ========================================================
    // PLAY VIDEO
    // ========================================================

    await workerState.playAnimation();
  }

  // ============================================================
  // WORKER VIDEO COMPLETED
  // ============================================================

  Future<void>
      _handleWorkerAnimationComplete() async {
    if (!mounted) {
      return;
    }

    debugPrint(
      '👷 Worker animation COMPLETED',
    );

    // ========================================================
    // LOCATION READY
    // ========================================================

    setState(() {
      _showLocationReady = true;

      status =
          'Location ready';
    });

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
      '👷 Worker is ready for work',
    );

    await Future.delayed(
      const Duration(
        milliseconds: 700,
      ),
    );

    if (!mounted) {
      return;
    }

    // ========================================================
    // REGISTERED USER
    //
    // IMPORTANT:
    // Animation completes first.
    // Then Home.
    // ========================================================

    if (_registeredUser) {
      debugPrint(
        '👤 Registered user detected',
      );

      debugPrint(
        '🏠 Going to Home',
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

    // ========================================================
    // NOTIFICATION ALREADY COMPLETED
    // ========================================================

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

    // ========================================================
    // FIRST TIME USER
    // ========================================================

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

    // ========================================================
    // CHECK LOCATION SERVICE
    // ========================================================

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

    // ========================================================
    // PERMANENT DENIAL
    // ========================================================

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

    // ========================================================
    // RETRY
    // ========================================================

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

    _loaderController.dispose();

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
                            // INTERNET REQUIRED
                            // ==================================

                            if (!loading &&
                                internetRequired)
                              _buildInternetRequiredSection(),

                            // ==================================
                            // GPS PING
                            // ==================================

                            if (loading)
                              _buildGpsFetchingSection(),

                            // ==================================
                            // WORKER READY
                            // ==================================

                            if (!loading &&
                                !internetRequired &&
                                !locationRequired &&
                                _workerReady)
                              _buildWorkerReadySection(),

                            // ==================================
                            // LOCATION REQUIRED
                            // ==================================

                            if (!loading &&
                                !internetRequired &&
                                locationRequired)
                              _buildLocationRequiredSection(),

                            // ==================================================
                            // IMPORTANT
                            //
                            // Footer is HIDDEN while worker flow
                            // is running.
                            //
                            // So:
                            //
                            // Ping
                            //   ↓
                            // Worker animation
                            //
                            // No "HANDZY • WORK MADE EASY"
                            // between them.
                            // ==================================================

                            if (!_workerReady)
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
  // GPS FETCHING SECTION
  //
  // THIS IS THE ORIGINAL PING UI.
  // ============================================================

  Widget _buildGpsFetchingSection() {
    return Column(
      children: [
        SizedBox(
          width:
              150,

          height:
              150,

          child:
              AnimatedBuilder(
            animation:
                _loaderController,

            builder:
                (
              BuildContext context,
              Widget? child,
            ) {
              final double progress =
                  _loaderController.value;

              return Stack(
                alignment:
                    Alignment.center,

                children: [
                  _buildLoadingPulse(
                    progress,
                    145,
                  ),

                  _buildLoadingPulse(
                    (progress + 0.45) %
                        1.0,
                    115,
                  ),

                  Container(
                    width:
                        76,

                    height:
                        76,

                    decoration:
                        BoxDecoration(
                      shape:
                          BoxShape.circle,

                      color:
                          AppColors
                              .lightTeal,

                      boxShadow: [
                        BoxShadow(
                          color:
                              AppColors
                                  .secondary
                                  .withValues(
                            alpha:
                                0.22,
                          ),

                          blurRadius:
                              24,

                          spreadRadius:
                              4,
                        ),
                      ],
                    ),

                    child:
                        const Icon(
                      Icons
                          .location_on_rounded,

                      color:
                          AppColors
                              .primary,

                      size:
                          42,
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        const SizedBox(
          height:
              20,
        ),

        const Text(
          'Finding your work area',

          textAlign:
              TextAlign.center,

          style:
              TextStyle(
            color:
                AppColors
                    .primary,

            fontSize:
                19,

            fontWeight:
                FontWeight
                    .w800,
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
                AppColors
                    .textSecondary
                    .withValues(
              alpha:
                  0.80,
            ),

            fontSize:
                13,

            fontWeight:
                FontWeight
                    .w500,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // GPS PULSE
  // ============================================================

  Widget _buildLoadingPulse(
    double progress,
    double maxSize,
  ) {
    final double safeProgress =
        progress.clamp(
      0.0,
      1.0,
    );

    final double size =
        70 +
        ((maxSize - 70) *
            safeProgress);

    final double opacity =
        (1.0 - safeProgress) *
        0.28;

    return Opacity(
      opacity:
          opacity,

      child:
          Container(
        width:
            size,

        height:
            size,

        decoration:
            BoxDecoration(
          shape:
              BoxShape.circle,

          border:
              Border.all(
            color:
                AppColors
                    .secondary,

            width:
                2,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // WORKER READY SECTION
  // ============================================================

  Widget _buildWorkerReadySection() {
    return Column(
      children: [
        // ======================================================
        // WORKER VIDEO
        // ======================================================

        WorkerReadyAnimation(
          key:
              _workerAnimationKey,

          onComplete:
              _handleWorkerAnimationComplete,
        ),

        const SizedBox(
          height:
              4,
        ),

        // ======================================================
        // LOCATION READY
        // ======================================================

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
                  Color(
                0xFF009375,
              ),

              fontSize:
                  20,

              fontWeight:
                  FontWeight
                      .w800,
            ),
          ),
        ),

        const SizedBox(
          height:
              10,
        ),

        // ======================================================
        // WORK AREA / CURRENT LOCATION
        // ======================================================

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

                style:
                    TextStyle(
                  color:
                      Color(
                    0xFF737D88,
                  ),

                  fontSize:
                      14,

                  fontWeight:
                      FontWeight
                          .w500,
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
                      Color(
                    0xFF009375,
                  ),

                  fontSize:
                      28,

                  fontWeight:
                      FontWeight
                          .w800,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(
          height:
              13,
        ),

        // ======================================================
        // READY
        // ======================================================

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

            style:
                TextStyle(
              color:
                  Color(
                0xFF17212B,
              ),

              fontSize:
                  16,

              fontWeight:
                  FontWeight
                      .w600,
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
                AppColors
                    .lightTeal,

            boxShadow: [
              BoxShadow(
                color:
                    AppColors
                        .secondary
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
            Icons
                .wifi_off_rounded,

            color:
                AppColors
                    .primary,

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
                AppColors
                    .textPrimary,

            fontSize:
                22,

            fontWeight:
                FontWeight
                    .w800,
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
                AppColors
                    .textSecondary,

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
                  MainAxisAlignment
                      .center,

              children: [
                Icon(
                  Icons
                      .wifi_rounded,

                  color:
                      AppColors
                          .textOnPrimary,
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
                        FontWeight
                            .w700,
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
                AppColors
                    .lightTeal,
          ),

          child:
              const Icon(
            Icons
                .location_off_rounded,

            color:
                AppColors
                    .primary,

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
                AppColors
                    .textPrimary,

            fontSize:
                22,

            fontWeight:
                FontWeight
                    .w800,
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
                AppColors
                    .textSecondary,

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
                    FontWeight
                        .w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// TEMPORARY HOME SCREEN
// ============================================================
//
// IMPORTANT:
// Un actual HomeScreen ready aana,
// indha class-ai actual HomeScreen-ku replace pannuvom.
// ============================================================

class WorkerHomeScreen
    extends StatelessWidget {
  const WorkerHomeScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          AppColors.background,

      body:
          const Center(
        child:
            Text(
          'Worker Home',

          style:
              TextStyle(
            fontSize:
                28,

            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),
    );
  }
}