import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class WorkerReadyAnimation extends StatefulWidget {
  const WorkerReadyAnimation({
    super.key,
    this.onComplete,
  });

  final VoidCallback? onComplete;

  @override
  WorkerReadyAnimationState createState() =>
      WorkerReadyAnimationState();
}

class WorkerReadyAnimationState
    extends State<WorkerReadyAnimation> {
  late final VideoPlayerController _controller;

  late final Future<void> _initializationFuture;

  bool _hasCompleted = false;

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    // ==========================================================
    // VIDEO CONTROLLER
    // ==========================================================

    _controller = VideoPlayerController.asset(
      'assets/animations/worker_ready.mp4',
    );

    // ==========================================================
    // INITIALIZE
    //
    // IMPORTANT:
    // Video is prepared here.
    //
    // Video DOES NOT PLAY here.
    // ==========================================================

    _initializationFuture = _initialize();
  }

  // ============================================================
  // INITIALIZE VIDEO
  // ============================================================

  Future<void> _initialize() async {
    try {
      await _controller.initialize();

      if (!mounted) {
        return;
      }

      await _controller.setLooping(false);

      _controller.addListener(
        _checkVideoFinished,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isInitialized = true;
      });

      debugPrint(
        '👷 Worker video initialized - '
        'waiting for GPS success',
      );
    } catch (e) {
      debugPrint(
        '❌ Worker ready video error: $e',
      );
    }
  }

  // ============================================================
  // PLAY ANIMATION
  //
  // SplashScreen calls this ONLY after:
  //
  // 1. GPS success
  // 2. Logo intro completed
  // 3. Worker widget mounted
  //
  // ============================================================

  Future<void> playAnimation() async {
    debugPrint(
      '👷 Worker animation play request received',
    );

    // ----------------------------------------------------------
    // Wait for video initialization.
    // ----------------------------------------------------------

    await _initializationFuture;

    if (!mounted) {
      return;
    }

    // ----------------------------------------------------------
    // Check initialization.
    // ----------------------------------------------------------

    if (!_isInitialized ||
        !_controller.value.isInitialized) {
      debugPrint(
        '❌ Worker video is not initialized',
      );

      return;
    }

    // ----------------------------------------------------------
    // Prevent duplicate play.
    // ----------------------------------------------------------

    if (_controller.value.isPlaying) {
      debugPrint(
        '⚠️ Worker animation already playing',
      );

      return;
    }

    // ----------------------------------------------------------
    // Reset completion.
    // ----------------------------------------------------------

    _hasCompleted = false;

    // ----------------------------------------------------------
    // Start from first frame.
    // ----------------------------------------------------------

    await _controller.seekTo(
      Duration.zero,
    );

    if (!mounted) {
      return;
    }

    // ----------------------------------------------------------
    // ACTUAL VIDEO START
    // ----------------------------------------------------------

    await _controller.play();

    debugPrint(
      '👷 GPS SUCCESS → '
      'Worker cap animation started',
    );
  }

  // ============================================================
  // VIDEO COMPLETION
  // ============================================================

  void _checkVideoFinished() {
    if (!_controller.value.isInitialized) {
      return;
    }

    if (_hasCompleted) {
      return;
    }

    final Duration position =
        _controller.value.position;

    final Duration duration =
        _controller.value.duration;

    if (duration <= Duration.zero) {
      return;
    }

    // ----------------------------------------------------------
    // Small tolerance for the last frame.
    // ----------------------------------------------------------

    final bool reachedEnd =
        position >=
        duration -
            const Duration(
              milliseconds: 80,
            );

    if (reachedEnd) {
      _completeAnimation();
    }
  }

  // ============================================================
  // COMPLETE
  // ============================================================

  void _completeAnimation() {
    if (_hasCompleted) {
      return;
    }

    _hasCompleted = true;

    debugPrint(
      '👷 Worker cap animation completed',
    );

    widget.onComplete?.call();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _controller.removeListener(
      _checkVideoFinished,
    );

    _controller.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    // ----------------------------------------------------------
    // VIDEO NOT READY
    // ----------------------------------------------------------

    if (!_controller.value.isInitialized) {
      return const SizedBox(
        width: 300,
        height: 300,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Color(0xFF00A88F),
          ),
        ),
      );
    }

    // ----------------------------------------------------------
    // VIDEO READY
    //
    // It is visible but NOT automatically playing.
    // ----------------------------------------------------------

    return SizedBox(
      width: 300,
      height: 300,
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width:
              _controller.value.size.width,
          height:
              _controller.value.size.height,
          child: VideoPlayer(
            _controller,
          ),
        ),
      ),
    );
  }
}