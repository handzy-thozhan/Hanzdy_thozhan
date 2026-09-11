import 'package:flutter/material.dart';

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

  late AnimationController _searchingController;
  late Animation<double> _searchingScale;
  late Animation<double> _searchingRipple;

  // ==========================================================
  // LOCATION STATE
  // ==========================================================

  bool _showLocationFound = false;

  // ==========================================================
  // READY STATE
  // ==========================================================

  bool _showLocationReady = false;

  bool _showArea = false;

  bool _showReady = false;

  bool _readyFlowStarted = false;

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
        milliseconds: 500,
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
        0.08,
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

    _searchingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _searchingScale = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _searchingController, curve: Curves.easeInOut),
    );

    _searchingRipple = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _searchingController, curve: Curves.easeOut),
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

    _readyFlowStarted = false;

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

    setState(() {
      loading = false;

      internetRequired = false;

      locationRequired = false;

      locationName =
          result.locationName;

      status =
          'Location found';

      _registeredUser =
          result.registeredUser;

      _showLocationFound = true;
    });

    // ========================================================
    // SHOW READY CONTENT
    // ========================================================

    await _showReadyContent();

    if (!mounted) {
      return;
    }

    // ========================================================
    // AUTOMATIC NEXT PAGE
    // ========================================================

    await _continueAfterReady();
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
        milliseconds: 500,
      ),
    );

    if (!mounted) {
      return;
    }

    // ========================================================
    // AREA
    // ========================================================

    setState(() {
      _showArea = true;
    });

    debugPrint(
      '📍 Work area shown: $locationName',
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
    // READY
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
  // AUTOMATIC NEXT PAGE
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
    // REGISTERED USER → HOME
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

    // ========================================================
    // NOTIFICATION COMPLETED
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
    // NOTIFICATION NOT COMPLETED
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

    _searchingController.dispose();

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
            // OLD APP LOGO ANIMATION
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
                          const BoxDecoration(
                        shape:
                            BoxShape.circle,

                        color:
                            Colors.white,
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
            // LOCATION CONTENT
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
                            // SEARCHING
                            // ==================================

                            if (loading)
                              _buildSearchingView(),

                            // ==================================
                            // FOUND
                            // ==================================

                            if (!loading &&
                                !internetRequired &&
                                !locationRequired &&
                                _showLocationFound)
                              _buildLocationFoundView(),

                            // ==================================
                            // INTERNET
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
  // SEARCHING
  // ============================================================

  Widget _buildSearchingView() {
    return AnimatedBuilder(
      animation: _searchingController,
      builder: (context, child) {
        final ripple = _searchingRipple.value;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 130,
              height: 130,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 130 * ripple,
                    height: 130 * ripple,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(
                        alpha: (1 - ripple) * 0.18,
                      ),
                    ),
                  ),
                  Container(
                    width: 108 * ripple,
                    height: 108 * ripple,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(
                        alpha: (1 - ripple) * 0.22,
                      ),
                    ),
                  ),
                  Transform.scale(
                    scale: _searchingScale.value,
                    child: Container(
                      width: 78,
                      height: 78,
                      decoration: const BoxDecoration(
                        color: AppColors.lightTeal,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_on_outlined,
                        color: AppColors.primary,
                        size: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Finding your location',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please wait a moment...',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 24),
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: AppColors.primary,
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // LOCATION FOUND
  // ============================================================

  Widget _buildLocationFoundView() {
    return Column(
      mainAxisSize:
          MainAxisSize.min,

      children: [
        Container(
          width:
              78,

          height:
              78,

          decoration:
              const BoxDecoration(
            color:
                AppColors.lightTeal,

            shape:
                BoxShape.circle,
          ),

          child:
              const Icon(
            Icons.location_on,

            color:
                AppColors.primary,

            size:
                40,
          ),
        ),

        const SizedBox(
          height:
              28,
        ),

        Text(
          _showLocationReady
              ? 'Location ready'
              : 'Location found',

          textAlign:
              TextAlign.center,

          style:
              const TextStyle(
            color:
                AppColors.textPrimary,

            fontSize:
                22,

            fontWeight:
                FontWeight.w700,
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
                350,
          ),

          opacity:
              _showArea
                  ? 1.0
                  : 0.0,

          child:
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
                  17,

              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(
          height:
              22,
        ),

        AnimatedOpacity(
          duration:
              const Duration(
            milliseconds:
                350,
          ),

          opacity:
              _showReady
                  ? 1.0
                  : 0.0,

          child:
              const SizedBox(
            width:
                20,

            height:
                20,

            child:
                CircularProgressIndicator(
              strokeWidth:
                  2,

              color:
                  AppColors.primary,
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
      mainAxisSize:
          MainAxisSize.min,

      children: [
        Container(
          width:
              78,

          height:
              78,

          decoration:
              const BoxDecoration(
            shape:
                BoxShape.circle,

            color:
                AppColors.lightTeal,
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
      mainAxisSize:
          MainAxisSize.min,

      children: [
        Container(
          width:
              68,

          height:
              68,

          decoration:
              const BoxDecoration(
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