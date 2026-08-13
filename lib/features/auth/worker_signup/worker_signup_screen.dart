import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryColor =
      Color(0xFF00A88F);

  static const Color darkColor =
      Color(0xFF17232E);

  static const Color greyColor =
      Color(0xFF74808C);

  static const Color backgroundColor =
      Color(0xFFF7FAFB);

  static const Color borderColor =
      Color(0xFFDDE4E7);

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController _nameController =
      TextEditingController();

  // ============================================================
  // IMAGE PICKER
  // ============================================================

  final ImagePicker _imagePicker =
      ImagePicker();

  File? _profileImage;

  // ============================================================
  // FORM VALUES
  // ============================================================

  String? _selectedBloodGroup;

  String _selectedGender = 'Male';

  bool _isLoading = false;

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // ============================================================
  // PICK IMAGE
  // ============================================================

  Future<void> _pickProfileImage() async {
    try {
      final XFile? pickedImage =
          await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedImage == null) {
        return;
      }

      setState(() {
        _profileImage =
            File(pickedImage.path);
      });
    } catch (e) {
      debugPrint(
        '❌ Image picker error: $e',
      );

      _showMessage(
        'Unable to select image',
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
          Colors.white,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder:
          (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.all(24),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                const Text(
                  'Select Blood Group',
                  style: TextStyle(
                    color: darkColor,
                    fontSize: 21,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),

                const SizedBox(
                  height: 15,
                ),

                ...groups.map(
                  (String group) {
                    return ListTile(
                      title: Text(
                        group,
                        style:
                            const TextStyle(
                          color:
                              darkColor,
                          fontSize: 18,
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
                                      primaryColor,
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
  // VALIDATE FORM
  // ============================================================

  bool _validateForm() {
    if (_profileImage == null) {
      _showMessage(
        'Please add your profile photo',
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

      debugPrint(
        '📝 Creating worker profile',
      );

      debugPrint(
        '📱 Phone: $phoneNumber',
      );

      // ========================================================
      // SAVE WORKER DETAILS
      // ========================================================

      await FirebaseFirestore.instance
          .collection('workers')
          .doc(user.uid)
          .set(
        <String, dynamic>{
          'uid': user.uid,

          'phoneNumber':
              phoneNumber,

          'fullName':
              _nameController.text
                  .trim(),

          'bloodGroup':
              _selectedBloodGroup,

          'gender':
              _selectedGender,

          'profileImage':
              '',

          'createdAt':
              FieldValue
                  .serverTimestamp(),

          'updatedAt':
              FieldValue
                  .serverTimestamp(),
        },
        SetOptions(
          merge: true,
        ),
      );

      debugPrint(
        '✅ Worker profile saved',
      );

      if (!mounted) {
        return;
      }

      // ========================================================
      // SUCCESS
      // ========================================================

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
              (BuildContext context) {
            return const WorkerHomeScreen();
          },
        ),
        (Route<dynamic> route) =>
            false,
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
      width: double.infinity,
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: child,
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

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender =
              gender;
        });
      },
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            selected
                ? Icons
                    .radio_button_checked
                : Icons
                    .radio_button_unchecked,
            color: selected
                ? primaryColor
                : greyColor,
            size: 24,
          ),

          const SizedBox(
            width: 6,
          ),

          Text(
            gender,
            style:
                const TextStyle(
              color: darkColor,
              fontSize: 15,
              fontWeight:
                  FontWeight.w500,
            ),
          ),
        ],
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
      child: Column(
        children: [
          Icon(
            icon,
            color:
                primaryColor,
            size: 30,
          ),

          const SizedBox(
            height: 5,
          ),

          Text(
            title,
            style:
                const TextStyle(
              color: darkColor,
              fontSize: 13,
              fontWeight:
                  FontWeight.w800,
            ),
          ),

          const SizedBox(
            height: 3,
          ),

          Text(
            subtitle,
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              color: greyColor,
              fontSize: 9,
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
          backgroundColor,

      resizeToAvoidBottomInset:
          true,

      body: SafeArea(
        child:
            SingleChildScrollView(
          physics:
              const BouncingScrollPhysics(),

          child: Column(
            children: [
              // ==================================================
              // TOP SECTION
              // ==================================================

              Container(
                width:
                    double.infinity,

                padding:
                    const EdgeInsets
                        .fromLTRB(
                  24,
                  35,
                  24,
                  25,
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [
                    // --------------------------------------------
                    // BACK BUTTON
                    // --------------------------------------------

                   
                    // --------------------------------------------
                    // TITLE
                    // --------------------------------------------

                    const Text(
                      'Join Handzy\nThozhan',
                      style:
                          TextStyle(
                        color:
                            darkColor,
                        fontSize:
                            38,
                        height:
                            1.05,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    const Text(
                      'Create your worker profile\n'
                      'and start your journey with us.',
                      style:
                          TextStyle(
                        color:
                            greyColor,
                        fontSize:
                            17,
                        height:
                            1.45,
                      ),
                    ),

                    const SizedBox(
                      height: 22,
                    ),

                    // --------------------------------------------
                    // QUOTE
                    // --------------------------------------------

                    Container(
                      width:
                          double.infinity,

                      padding:
                          const EdgeInsets
                              .all(
                        18,
                      ),

                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xFFE9F8F5,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          18,
                        ),
                      ),

                      child:
                          const Text(
                        '“Your skills can make someone’s day better.”',
                        style:
                            TextStyle(
                          color:
                              darkColor,
                          fontSize:
                              16,
                          height:
                              1.4,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ==================================================
              // SIGNUP CARD
              // ==================================================

              Container(
                margin:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 18,
                ),

                padding:
                    const EdgeInsets
                        .fromLTRB(
                  18,
                  24,
                  18,
                  25,
                ),

                decoration:
                    BoxDecoration(
                  color:
                      Colors.white,

                  borderRadius:
                      BorderRadius
                          .circular(
                    26,
                  ),

                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black
                              .withValues(
                        alpha:
                            0.05,
                      ),
                      blurRadius:
                          25,
                      offset:
                          const Offset(
                        0,
                        8,
                      ),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [
                    // ==========================================
                    // TITLE
                    // ==========================================

                    const Text(
                      'Your Details',
                      style:
                          TextStyle(
                        color:
                            darkColor,
                        fontSize:
                            25,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    const Text(
                      'Tell us a little about yourself.',
                      style:
                          TextStyle(
                        color:
                            greyColor,
                        fontSize:
                            14,
                      ),
                    ),

                    const SizedBox(
                      height: 22,
                    ),

                    // ==========================================
                    // PROFILE IMAGE
                    // ==========================================

                    Center(
                      child:
                          GestureDetector(
                        onTap:
                            _pickProfileImage,

                        child:
                            Stack(
                          children: [
                            Container(
                              width:
                                  110,
                              height:
                                  110,

                              decoration:
                                  BoxDecoration(
                                shape:
                                    BoxShape.circle,

                                color:
                                    const Color(
                                  0xFFE9F8F5,
                                ),

                                border:
                                    Border.all(
                                  color:
                                      primaryColor,
                                  width:
                                      2,
                                ),

                                image:
                                    _profileImage !=
                                            null
                                        ? DecorationImage(
                                            image:
                                                FileImage(
                                              _profileImage!,
                                            ),
                                            fit:
                                                BoxFit.cover,
                                          )
                                        : null,
                              ),

                              child:
                                  _profileImage ==
                                          null
                                      ? const Icon(
                                          Icons
                                              .person_rounded,
                                          color:
                                              primaryColor,
                                          size:
                                              55,
                                        )
                                      : null,
                            ),

                            Positioned(
                              right:
                                  0,
                              bottom:
                                  0,

                              child:
                                  Container(
                                width:
                                    35,
                                height:
                                    35,

                                decoration:
                                    const BoxDecoration(
                                  color:
                                      primaryColor,
                                  shape:
                                      BoxShape.circle,
                                ),

                                child:
                                    const Icon(
                                  Icons
                                      .camera_alt_rounded,
                                  color:
                                      Colors.white,
                                  size:
                                      19,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    const Center(
                      child:
                          Text(
                        'Add Profile Photo',
                        style:
                            TextStyle(
                          color:
                              greyColor,
                          fontSize:
                              14,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    // ==========================================
                    // FULL NAME
                    // ==========================================

                    const Text(
                      'Full Name',
                      style:
                          TextStyle(
                        color:
                            darkColor,
                        fontSize:
                            15,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
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
                              darkColor,
                          fontSize:
                              16,
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
                                greyColor,
                          ),

                          hintText:
                              'Enter your full name',

                          hintStyle:
                              TextStyle(
                            color:
                                greyColor,
                          ),

                          contentPadding:
                              EdgeInsets
                                  .symmetric(
                            vertical:
                                18,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    // ==========================================
                    // BLOOD GROUP
                    // ==========================================

                    const Text(
                      'Blood Group',
                      style:
                          TextStyle(
                        color:
                            darkColor,
                        fontSize:
                            15,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
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
                                17,
                          ),

                          child:
                              Row(
                            children: [
                              const Icon(
                                Icons
                                    .bloodtype_outlined,
                                color:
                                    greyColor,
                              ),

                              const SizedBox(
                                width:
                                    12,
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
                                            ? greyColor
                                            : darkColor,
                                    fontSize:
                                        16,
                                  ),
                                ),
                              ),

                              const Icon(
                                Icons
                                    .keyboard_arrow_down_rounded,
                                color:
                                    greyColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    // ==========================================
                    // GENDER
                    // ==========================================

                    const Text(
                      'Gender',
                      style:
                          TextStyle(
                        color:
                            darkColor,
                        fontSize:
                            15,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    _fieldContainer(
                      child:
                          Padding(
                        padding:
                            const EdgeInsets
                                .all(
                          16,
                        ),

                        child:
                            Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,

                          children: [
                            _genderItem(
                              'Male',
                            ),

                            _genderItem(
                              'Female',
                            ),

                            _genderItem(
                              'Other',
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 25,
                    ),

                    // ==========================================
                    // CREATE ACCOUNT
                    // ==========================================

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
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              primaryColor,

                          foregroundColor:
                              Colors.white,

                          disabledBackgroundColor:
                              primaryColor
                                  .withValues(
                            alpha:
                                0.6,
                          ),

                          elevation:
                              0,

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
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
                                          Colors.white,
                                      strokeWidth:
                                          3,
                                    ),
                                  )
                                : const Text(
                                    'Create Account',
                                    style:
                                        TextStyle(
                                      fontSize:
                                          18,
                                      fontWeight:
                                          FontWeight
                                              .w800,
                                    ),
                                  ),
                      ),
                    ),

                    const SizedBox(
                      height: 22,
                    ),

                    // ==========================================
                    // TRUST SECTION
                    // ==========================================

                    const Divider(
                      color:
                          borderColor,
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    Row(
                      children: [
                        _trustItem(
                          icon: Icons
                              .verified_user_rounded,
                          title:
                              'Trusted',
                          subtitle:
                              'Verified workers',
                        ),

                        Container(
                          width: 1,
                          height: 50,
                          color:
                              borderColor,
                        ),

                        _trustItem(
                          icon: Icons
                              .security_rounded,
                          title:
                              'Safe',
                          subtitle:
                              'Your safety first',
                        ),

                        Container(
                          width: 1,
                          height: 50,
                          color:
                              borderColor,
                        ),

                        _trustItem(
                          icon:
                              Icons.bolt_rounded,
                          title:
                              'Fast',
                          subtitle:
                              'Quick service',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// TEMPORARY HOME SCREEN
// ================================================================
//
// Later un actual HomeScreen irundha,
// inga replace pannalam.
// ================================================================

class WorkerHomeScreen
    extends StatelessWidget {
  const WorkerHomeScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Worker Home',
          style: TextStyle(
            fontSize: 28,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),
    );
  }
}