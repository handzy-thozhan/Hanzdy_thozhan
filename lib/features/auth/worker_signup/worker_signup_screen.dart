import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../services/preferences_service.dart';
import '../../home/worker_home_screen.dart';

class WorkerSignupScreen extends StatefulWidget {
  const WorkerSignupScreen({
    super.key,
  });

  @override
  State<WorkerSignupScreen> createState() =>
      _WorkerSignupScreenState();
}

class _WorkerSignupScreenState
    extends State<WorkerSignupScreen> {
  final TextEditingController _nameController =
      TextEditingController();

  final ImagePicker _imagePicker =
      ImagePicker();

  File? _profileImage;

  String? _selectedBloodGroup;

  String _selectedGender = 'Male';

  bool _isLoading = false;

  static const String _defaultProfileImage =
      'assets/image/handzy_worker.png';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // ============================================================
  // CAMERA ONLY
  // ============================================================

  Future<void> _takeProfilePhoto() async {
    try {
      final XFile? pickedImage =
          await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        preferredCameraDevice:
            CameraDevice.front,
      );

      if (pickedImage == null) {
        return;
      }

      final Directory appDirectory =
          await getApplicationDocumentsDirectory();

      final Directory profileDirectory =
          Directory(
        '${appDirectory.path}/worker_profile',
      );

      if (!await profileDirectory.exists()) {
        await profileDirectory.create(
          recursive: true,
        );
      }

      final String filePath =
          '${profileDirectory.path}/profile_photo.jpg';

      final File savedImage =
          await File(pickedImage.path)
              .copy(filePath);

      if (!mounted) {
        return;
      }

      setState(() {
        _profileImage = savedImage;
      });

      debugPrint(
        '📸 Worker profile photo captured',
      );

      debugPrint(
        '💾 Local photo saved: ${savedImage.path}',
      );
    } catch (e) {
      debugPrint(
        '❌ Camera error: $e',
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        'Unable to open camera. Please try again.',
      );
    }
  }

  // ============================================================
  // BLOOD GROUP
  // ============================================================

  Future<void> _selectBloodGroup() async {
    const List<String> groups = [
      'A+',
      'A-',
      'B+',
      'B-',
      'AB+',
      'AB-',
      'O+',
      'O-',
    ];

    final String? selected =
        await showModalBottomSheet<String>(
      context: context,
      backgroundColor:
          AppColors.background,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder:
          (context) {
        return SafeArea(
          child:
              Padding(
            padding:
                const EdgeInsets.all(
              24,
            ),
            child:
                Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                const Text(
                  'Select Blood Group',
                  style:
                      TextStyle(
                    color:
                        AppColors.textPrimary,
                    fontSize:
                        21,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                const SizedBox(
                  height:
                      15,
                ),
                ...groups.map(
                  (group) {
                    return ListTile(
                      title:
                          Text(
                        group,
                        style:
                            const TextStyle(
                          color:
                              AppColors
                                  .textPrimary,
                          fontSize:
                              18,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                      trailing:
                          _selectedBloodGroup ==
                                  group
                              ? const Icon(
                                  Icons
                                      .check_circle,
                                  color:
                                      AppColors
                                          .primary,
                                )
                              : null,
                      onTap: () {
                        Navigator.pop(
                          context,
                          group,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted) {
      return;
    }

    if (selected != null) {
      setState(() {
        _selectedBloodGroup =
            selected;
      });
    }
  }

  // ============================================================
  // VALIDATION
  // ============================================================

  bool _validateForm() {
    if (_profileImage == null) {
      _showMessage(
        'Please take your profile photo',
      );

      return false;
    }

    if (_nameController.text
        .trim()
        .isEmpty) {
      _showMessage(
        'Please enter your full name',
      );

      return false;
    }

    if (_selectedBloodGroup == null) {
      _showMessage(
        'Please select your blood group',
      );

      return false;
    }

    if (_selectedGender
        .trim()
        .isEmpty) {
      _showMessage(
        'Please select your gender',
      );

      return false;
    }

    return true;
  }

  // ============================================================
  // CREATE ACCOUNT
  // ============================================================

  Future<void> _createAccount() async {
    if (_isLoading) {
      return;
    }

    if (!_validateForm()) {
      return;
    }

    final User? user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage(
        'Your verification session has expired. Please verify again.',
      );

      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final String phoneNumber =
          user.phoneNumber ?? '';

      final String localPhotoPath =
          _profileImage!.path;

      debugPrint(
        '📝 Creating worker profile',
      );

      debugPrint(
        '📱 Phone: $phoneNumber',
      );

      debugPrint(
        '📸 Photo: $localPhotoPath',
      );

      // ========================================================
      // FIRESTORE
      // ========================================================

      await FirebaseFirestore.instance
          .collection('workers')
          .doc(user.uid)
          .set(
        <String, dynamic>{
          'uid':
              user.uid,

          'phoneNumber':
              phoneNumber,

          'fullName':
              _nameController.text
                  .trim(),

          'bloodGroup':
              _selectedBloodGroup,

          'gender':
              _selectedGender,

          // Local device photo path
          'profileImage':
              localPhotoPath,

          'createdAt':
              FieldValue.serverTimestamp(),

          'updatedAt':
              FieldValue.serverTimestamp(),
        },
        SetOptions(
          merge: true,
        ),
      );

      debugPrint(
        '✅ Worker profile saved to Firestore',
      );

      await PreferencesService
          .savePhoneNumber(
        phoneNumber,
      );

      await PreferencesService
          .setUserRegistered(true);

      debugPrint(
        '💾 user_registered = true',
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        'Account created successfully',
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
      // GO HOME
      // ========================================================

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder:
              (context) {
            return const WorkerHomeScreen();
          },
        ),
        (route) => false,
      );
    } catch (e) {
      debugPrint(
        '❌ Signup error: $e',
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        'Unable to create account. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message,
  ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content:
            Text(message),
        behavior:
            SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // FIELD CONTAINER
  // ============================================================

  Widget _fieldContainer({
    required Widget child,
  }) {
    return Container(
      width:
          double.infinity,
      decoration:
          BoxDecoration(
        color:
            AppColors.background,
        borderRadius:
            BorderRadius.circular(
          16,
        ),
        border:
            Border.all(
          color:
              AppColors.border,
        ),
      ),
      child:
          child,
    );
  }

  // ============================================================
  // GENDER
  // ============================================================

  Widget _genderItem(
    String gender,
  ) {
    final bool selected =
        _selectedGender ==
            gender;

    return Expanded(
      child:
          GestureDetector(
        onTap: () {
          setState(() {
            _selectedGender =
                gender;
          });
        },
        child:
            Container(
          height:
              66,
          decoration:
              BoxDecoration(
            color:
                selected
                    ? AppColors.lightTeal
                    : AppColors.background,
            borderRadius:
                BorderRadius.circular(
              14,
            ),
          ),
          child:
              Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(
                selected
                    ? Icons
                        .radio_button_checked
                    : Icons
                        .radio_button_unchecked,
                color:
                    selected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                size:
                    24,
              ),
              const SizedBox(
                width:
                    7,
              ),
              Text(
                gender,
                style:
                    const TextStyle(
                  color:
                      AppColors.textPrimary,
                  fontSize:
                      15,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TRUST ITEM
  // ============================================================

  Widget _trustItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Expanded(
      child:
          Column(
        children: [
          Container(
            width:
                52,
            height:
                52,
            decoration:
                const BoxDecoration(
              color:
                  AppColors.lightTeal,
              shape:
                  BoxShape.circle,
            ),
            child:
                Icon(
              icon,
              color:
                  AppColors.primary,
              size:
                  29,
            ),
          ),
          const SizedBox(
            height:
                8,
          ),
          Text(
            title,
            style:
                const TextStyle(
              color:
                  AppColors.textPrimary,
              fontSize:
                  14,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          const SizedBox(
            height:
                3,
          ),
          Text(
            subtitle,
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              color:
                  AppColors.textSecondary,
              fontSize:
                  10,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PROFILE PHOTO
  // ============================================================

  Widget _buildProfilePhoto() {
    return GestureDetector(
      onTap:
          _takeProfilePhoto,
      child:
          Stack(
        alignment:
            Alignment.center,
        children: [
          Container(
            width:
                190,
            height:
                190,
            decoration:
                BoxDecoration(
              shape:
                  BoxShape.circle,
              color:
                  AppColors.lightTeal,
              border:
                  Border.all(
                color:
                    AppColors.primary,
                width:
                    2.5,
              ),
            ),
            child:
                ClipOval(
              child:
                  _profileImage !=
                          null
                      ? Image.file(
                          _profileImage!,
                          width:
                              190,
                          height:
                              190,
                          fit:
                              BoxFit.cover,
                        )
                      : Image.asset(
                          _defaultProfileImage,
                          width:
                              190,
                          height:
                              190,
                          fit:
                              BoxFit.cover,
                        ),
            ),
          ),
          Positioned(
            right:
                5,
            bottom:
                7,
            child:
                Container(
              width:
                  58,
              height:
                  58,
              decoration:
                  const BoxDecoration(
                color:
                    AppColors.primary,
                shape:
                    BoxShape.circle,
              ),
              child:
                  const Icon(
                Icons
                    .camera_alt_rounded,
                color:
                    AppColors
                        .textOnPrimary,
                size:
                    30,
              ),
            ),
          ),
        ],
      ),
    );
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
      resizeToAvoidBottomInset:
          true,
      body:
          SafeArea(
        child:
            SingleChildScrollView(
          physics:
              const BouncingScrollPhysics(),
          padding:
              const EdgeInsets.fromLTRB(
            24,
            24,
            24,
            30,
          ),
          child:
              Column(
            children: [
              _buildProfilePhoto(),

              const SizedBox(
                height:
                    20,
              ),

              const Text(
                'Add Profile Photo',
                textAlign:
                    TextAlign.center,
                style:
                    TextStyle(
                  color:
                      AppColors.textPrimary,
                  fontSize:
                      28,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),

              const SizedBox(
                height:
                    8,
              ),

              const Text(
                'Let’s get you started!',
                textAlign:
                    TextAlign.center,
                style:
                    TextStyle(
                  color:
                      AppColors.textSecondary,
                  fontSize:
                      17,
                  fontWeight:
                      FontWeight.w500,
                ),
              ),

              const SizedBox(
                height:
                    16,
              ),

              Container(
                width:
                    50,
                height:
                    5,
                decoration:
                    BoxDecoration(
                  color:
                      AppColors.secondary,
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                ),
              ),

              const SizedBox(
                height:
                    32,
              ),

              const Align(
                alignment:
                    Alignment.centerLeft,
                child:
                    Text(
                  'Full Name',
                  style:
                      TextStyle(
                    color:
                        AppColors.textPrimary,
                    fontSize:
                        19,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(
                height:
                    10,
              ),

              _fieldContainer(
                child:
                    TextField(
                  controller:
                      _nameController,
                  textCapitalization:
                      TextCapitalization
                          .words,
                  style:
                      const TextStyle(
                    color:
                        AppColors.textPrimary,
                    fontSize:
                        17,
                    fontWeight:
                        FontWeight.w500,
                  ),
                  decoration:
                      const InputDecoration(
                    border:
                        InputBorder.none,
                    prefixIcon:
                        Icon(
                      Icons
                          .person_outline_rounded,
                      color:
                          AppColors.primary,
                      size:
                          29,
                    ),
                    hintText:
                        'Enter your full name',
                    hintStyle:
                        TextStyle(
                      color:
                          AppColors.textSecondary,
                      fontSize:
                          17,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(
                      vertical:
                          19,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height:
                    28,
              ),

              const Align(
                alignment:
                    Alignment.centerLeft,
                child:
                    Text(
                  'Blood Group',
                  style:
                      TextStyle(
                    color:
                        AppColors.textPrimary,
                    fontSize:
                        19,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(
                height:
                    10,
              ),

              GestureDetector(
                onTap:
                    _selectBloodGroup,
                child:
                    _fieldContainer(
                  child:
                      Padding(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal:
                          16,
                      vertical:
                          18,
                    ),
                    child:
                        Row(
                      children: [
                        const Icon(
                          Icons
                              .bloodtype_outlined,
                          color:
                              AppColors.primary,
                          size:
                              30,
                        ),
                        const SizedBox(
                          width:
                              14,
                        ),
                        Expanded(
                          child:
                              Text(
                            _selectedBloodGroup ??
                                'Select your blood group',
                            style:
                                TextStyle(
                              color:
                                  _selectedBloodGroup ==
                                          null
                                      ? AppColors
                                          .textSecondary
                                      : AppColors
                                          .textPrimary,
                              fontSize:
                                  17,
                              fontWeight:
                                  FontWeight.w500,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons
                              .keyboard_arrow_down_rounded,
                          color:
                              AppColors
                                  .textSecondary,
                          size:
                              30,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height:
                    28,
              ),

              const Align(
                alignment:
                    Alignment.centerLeft,
                child:
                    Text(
                  'Gender',
                  style:
                      TextStyle(
                    color:
                        AppColors.textPrimary,
                    fontSize:
                        19,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(
                height:
                    10,
              ),

              _fieldContainer(
                child:
                    Padding(
                  padding:
                      const EdgeInsets.all(
                    4,
                  ),
                  child:
                      Row(
                    children: [
                      _genderItem(
                        'Male',
                      ),
                      Container(
                        width:
                            1,
                        height:
                            48,
                        color:
                            AppColors.border,
                      ),
                      _genderItem(
                        'Female',
                      ),
                      Container(
                        width:
                            1,
                        height:
                            48,
                        color:
                            AppColors.border,
                      ),
                      _genderItem(
                        'Other',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(
                height:
                    28,
              ),

              SizedBox(
                width:
                    double.infinity,
                height:
                    60,
                child:
                    ElevatedButton(
                  onPressed:
                      _isLoading
                          ? null
                          : _createAccount,
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.primary,
                    foregroundColor:
                        AppColors
                            .textOnPrimary,
                    disabledBackgroundColor:
                        AppColors.primary
                            .withValues(
                      alpha:
                          0.6,
                    ),
                    elevation:
                        0,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        16,
                      ),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                              width:
                                  25,
                              height:
                                  25,
                              child:
                                  CircularProgressIndicator(
                                color:
                                    AppColors
                                        .textOnPrimary,
                                strokeWidth:
                                    3,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .center,
                              children: [
                                Text(
                                  'Create Account',
                                  style:
                                      TextStyle(
                                    color:
                                        AppColors
                                            .textOnPrimary,
                                    fontSize:
                                        18,
                                    fontWeight:
                                        FontWeight.w800,
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      16,
                                ),
                                Icon(
                                  Icons
                                      .arrow_forward_rounded,
                                  color:
                                      AppColors
                                          .textOnPrimary,
                                  size:
                                      30,
                                ),
                              ],
                            ),
                ),
              ),

              const SizedBox(
                height:
                    30,
              ),

              Container(
                width:
                    double.infinity,
                padding:
                    const EdgeInsets
                        .symmetric(
                  vertical:
                      24,
                  horizontal:
                      10,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      AppColors.card,
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                  border:
                      Border.all(
                    color:
                        AppColors.border,
                  ),
                ),
                child:
                    Row(
                  children: [
                    _trustItem(
                      icon:
                          Icons
                              .verified_user_rounded,
                      title:
                          'Trusted',
                      subtitle:
                          'Verified workers',
                    ),
                    Container(
                      width:
                          1,
                      height:
                          70,
                      color:
                          AppColors.border,
                    ),
                    _trustItem(
                      icon:
                          Icons
                              .security_rounded,
                      title:
                          'Safe',
                      subtitle:
                          'Your safety first',
                    ),
                    Container(
                      width:
                          1,
                      height:
                          70,
                      color:
                          AppColors.border,
                    ),
                    _trustItem(
                      icon:
                          Icons
                              .bolt_rounded,
                      title:
                          'Fast',
                      subtitle:
                          'Quick service',
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height:
                    10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}