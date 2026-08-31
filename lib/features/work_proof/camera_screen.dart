import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

enum CameraCaptureMode {
  photo,
  video,
}

class CameraScreen extends StatefulWidget {
  final CameraCaptureMode mode;

  const CameraScreen({
    super.key,
    required this.mode,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];

  bool _isInitializing = true;
  bool _isRecording = false;
  bool _isSwitchingCamera = false;

  String? _errorMessage;

  int _currentCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCameraFlow();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;

    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCameraFlow();
    }
  }

  Future<void> _initializeCameraFlow() async {
    if (!mounted) return;

    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    try {
      // Camera permission
      final cameraStatus = await Permission.camera.request();

      if (!cameraStatus.isGranted) {
        await _handlePermissionDenied(
          permissionName: 'Camera',
          status: cameraStatus,
        );
        return;
      }

      // Microphone permission is required only for video.
      if (widget.mode == CameraCaptureMode.video) {
        final microphoneStatus = await Permission.microphone.request();

        if (!microphoneStatus.isGranted) {
          await _handlePermissionDenied(
            permissionName: 'Microphone',
            status: microphoneStatus,
          );
          return;
        }
      }

      _cameras = await availableCameras();

      if (_cameras.isEmpty) {
        _showError('No camera was found on this device.');
        return;
      }

      // Prefer back camera.
      int selectedIndex = 0;

      for (int i = 0; i < _cameras.length; i++) {
        if (_cameras[i].lensDirection == CameraLensDirection.back) {
          selectedIndex = i;
          break;
        }
      }

      _currentCameraIndex = selectedIndex;

      await _createCameraController(
        _cameras[_currentCameraIndex],
      );
    } catch (e) {
      _showError('Unable to open camera.');
    }
  }

  Future<void> _createCameraController(
    CameraDescription cameraDescription,
  ) async {
    await _controller?.dispose();

    final controller = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: widget.mode == CameraCaptureMode.video,
    );

    _controller = controller;

    await controller.initialize();

    if (widget.mode == CameraCaptureMode.video) {
      await controller.prepareForVideoRecording();
    }

    if (!mounted) return;

    setState(() {
      _isInitializing = false;
    });
  }

  Future<void> _handlePermissionDenied({
    required String permissionName,
    required PermissionStatus status,
  }) async {
    if (!mounted) return;

    setState(() {
      _isInitializing = false;
      _errorMessage = '$permissionName permission is required.';
    });

    if (status.isPermanentlyDenied || status.isRestricted) {
      await _showSettingsDialog(permissionName);
    }
  }

  Future<void> _showSettingsDialog(String permissionName) async {
    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('$permissionName Permission Required'),
          content: Text(
            'Please allow $permissionName permission from '
            'Settings to use this feature.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _takePhoto() async {
    final controller = _controller;

    if (controller == null ||
        !controller.value.isInitialized ||
        controller.value.isTakingPicture) {
      return;
    }

    try {
      final XFile photo = await controller.takePicture();

      if (!mounted) return;

      Navigator.of(context).pop(photo);
    } catch (e) {
      _showError('Unable to take photo. Please try again.');
    }
  }

  Future<void> _startVideoRecording() async {
    final controller = _controller;

    if (controller == null ||
        !controller.value.isInitialized ||
        _isRecording) {
      return;
    }

    try {
      await controller.startVideoRecording();

      if (!mounted) return;

      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      _showError('Unable to start video recording.');
    }
  }

  Future<void> _stopVideoRecording() async {
    final controller = _controller;

    if (controller == null || !_isRecording) {
      return;
    }

    try {
      final XFile video = await controller.stopVideoRecording();

      if (!mounted) return;

      setState(() {
        _isRecording = false;
      });

      Navigator.of(context).pop(video);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isRecording = false;
      });

      _showError('Unable to stop video recording.');
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2 ||
        _isSwitchingCamera ||
        _isRecording) {
      return;
    }

    setState(() {
      _isSwitchingCamera = true;
    });

    try {
      _currentCameraIndex =
          (_currentCameraIndex + 1) % _cameras.length;

      await _createCameraController(
        _cameras[_currentCameraIndex],
      );
    } catch (e) {
      _showError('Unable to switch camera.');
    } finally {
      if (mounted) {
        setState(() {
          _isSwitchingCamera = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    setState(() {
      _isInitializing = false;
      _errorMessage = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // CAMERA PREVIEW
            Positioned.fill(
              child: _buildCameraPreview(controller),
            ),

            // TOP BAR
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  _roundButton(
                    icon: Icons.close,
                    onPressed: () {
                      if (_isRecording) {
                        _stopVideoRecording();
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.mode == CameraCaptureMode.photo
                          ? 'Problem Photo'
                          : 'Work Video',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _roundButton(
                    icon: Icons.flip_camera_ios,
                    onPressed:
                        _isRecording ? null : _switchCamera,
                  ),
                ],
              ),
            ),

            // RECORDING INDICATOR
            if (_isRecording)
              Positioned(
                top: 75,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.fiber_manual_record,
                          color: Colors.white,
                          size: 13,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'RECORDING',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // BOTTOM CONTROLS
            Positioned(
              left: 0,
              right: 0,
              bottom: 30,
              child: Column(
                children: [
                  if (!_isRecording)
                    const Text(
                      'Capture proof directly from camera',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),

                  const SizedBox(height: 15),

                  if (widget.mode == CameraCaptureMode.photo)
                    GestureDetector(
                      onTap: _takePhoto,
                      child: _captureButton(),
                    )
                  else
                    GestureDetector(
                      onTap: _isRecording
                          ? _stopVideoRecording
                          : _startVideoRecording,
                      child: _videoButton(),
                    ),
                ],
              ),
            ),

            // LOADING
            if (_isInitializing)
              Container(
                color: Colors.black.withValues(alpha: 0.85),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),

            // ERROR
            if (!_isInitializing && _errorMessage != null)
              Container(
                color: Colors.black.withValues(alpha: 0.88),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.white,
                          size: 55,
                        ),
                        const SizedBox(height: 18),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 22),
                        ElevatedButton(
                          onPressed: _initializeCameraFlow,
                          child: const Text('Try Again'),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Go Back',
                            style: TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview(
    CameraController? controller,
  ) {
    if (controller == null ||
        !controller.value.isInitialized) {
      return const ColoredBox(
        color: Colors.black,
      );
    }

    return Center(
      child: CameraPreview(controller),
    );
  }

  Widget _roundButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Material(
      color: Colors.black.withValues(alpha: 0.55),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(
            icon,
            color: onPressed == null
                ? Colors.white38
                : Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _captureButton() {
    return Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 5,
        ),
      ),
      child: Center(
        child: Container(
          width: 62,
          height: 62,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _videoButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 5,
        ),
      ),
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: _isRecording ? 38 : 62,
          height: _isRecording ? 38 : 62,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(
              _isRecording ? 8 : 50,
            ),
          ),
        ),
      ),
    );
  }
}