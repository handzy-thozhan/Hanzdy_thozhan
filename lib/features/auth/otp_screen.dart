import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'auth_service.dart';
import 'worker_signup/worker_signup_screen.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
  });

  final String phoneNumber;
  final String verificationId;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  // ============================================================
  // OTP CONTROLLERS
  // ============================================================

  final List<TextEditingController> _controllers =
      List.generate(
    6,
    (_) => TextEditingController(),
  );

  final List<FocusNode> _focusNodes =
      List.generate(
    6,
    (_) => FocusNode(),
  );

  // ============================================================
  // STATE
  // ============================================================

  bool _isLoading = false;
  bool _isVerified = false;

  String _errorMessage = '';

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
      Color(0xFFD9E0E3);

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    for (final TextEditingController controller
        in _controllers) {
      controller.dispose();
    }

    for (final FocusNode node in _focusNodes) {
      node.dispose();
    }

    super.dispose();
  }

  // ============================================================
  // GET COMPLETE OTP
  // ============================================================

  String get _otp {
    return _controllers
        .map(
          (TextEditingController controller) =>
              controller.text,
        )
        .join();
  }

  // ============================================================
  // OTP TEXT CHANGE
  // ============================================================

  void _onOtpChanged(
    int index,
    String text,
  ) {
    if (_isVerified || _isLoading) {
      return;
    }

    setState(() {
      _errorMessage = '';
    });

    // ----------------------------------------------------------
    // IF USER ENTERS A DIGIT
    // ----------------------------------------------------------

    if (text.isNotEmpty) {
      // Only keep the last entered digit
      if (text.length > 1) {
        final String lastDigit =
            text.substring(text.length - 1);

        _controllers[index].text =
            lastDigit;

        _controllers[index].selection =
            TextSelection.fromPosition(
          TextPosition(
            offset: 1,
          ),
        );
      }

      // Move to next box
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      }
    }

    // ----------------------------------------------------------
    // SIX DIGITS COMPLETE
    // ----------------------------------------------------------

    if (_otp.length == 6) {
      FocusScope.of(context).unfocus();

      _verifyOTP();
    }
  }

  // ============================================================
  // VERIFY OTP
  // ============================================================

  Future<void> _verifyOTP() async {
    if (_isLoading || _isVerified) {
      return;
    }

    if (_otp.length != 6) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final UserCredential? result =
          await AuthService().verifyOTP(
        verificationId:
            widget.verificationId,
        otp: _otp,
      );

      if (!mounted) {
        return;
      }

      // ========================================================
      // WRONG OTP
      // ========================================================

      if (result == null) {
        setState(() {
          _isLoading = false;

          _errorMessage =
              'Please enter a valid OTP';
        });

        // Clear all boxes
        for (final TextEditingController controller
            in _controllers) {
          controller.clear();
        }

        // Focus first box
        _focusNodes[0].requestFocus();

        return;
      }

      // ========================================================
      // CORRECT OTP
      // ========================================================

      debugPrint(
        '✅ OTP VERIFIED SUCCESSFULLY',
      );

      setState(() {
        _isLoading = false;

        _isVerified = true;

        _errorMessage = '';
      });

      // Same OTP screen-la
      // Verified Successfully show aagum
      await Future.delayed(
        const Duration(
          seconds: 1,
        ),
      );

      if (!mounted) {
        return;
      }

      // ========================================================
      // CHECK EXISTING PHONE
      // ========================================================

      await _checkExistingPhone();
    } catch (e) {
      debugPrint(
        '❌ OTP verification error: $e',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;

        _errorMessage =
            'OTP verification failed. Please try again.';
      });

      _focusNodes[0].requestFocus();
    }
  }

  // ============================================================
  // CHECK PHONE NUMBER IN FIRESTORE
  // ============================================================

  Future<void> _checkExistingPhone() async {
    try {
      final User? user =
          FirebaseAuth.instance.currentUser;

      if (user == null) {
        _showMessage(
          'User session not found. Please try again.',
        );

        return;
      }

      final String phoneNumber =
          user.phoneNumber ??
              widget.phoneNumber;

      debugPrint(
        '🔍 Checking phone number: $phoneNumber',
      );

      final QuerySnapshot<
              Map<String, dynamic>>
          snapshot =
          await FirebaseFirestore.instance
              .collection('workers')
              .where(
                'phoneNumber',
                isEqualTo: phoneNumber,
              )
              .limit(1)
              .get();

      if (!mounted) {
        return;
      }

      // ========================================================
      // PHONE EXISTS
      // ========================================================

      if (snapshot.docs.isNotEmpty) {
        debugPrint(
          '✅ Existing worker found',
        );

        debugPrint(
          '➡️ Going to HOME',
        );

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

        return;
      }

      // ========================================================
      // PHONE DOES NOT EXIST
      // ========================================================

      debugPrint(
        '🆕 New worker',
      );

      debugPrint(
        '➡️ Going to SIGNUP',
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder:
              (BuildContext context) {
            return const WorkerSignupScreen();
          },
        ),
        (Route<dynamic> route) =>
            false,
      );
    } catch (e) {
      debugPrint(
        '❌ Phone check error: $e',
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        'Unable to check your account. Please try again.',
      );
    }
  }

  // ============================================================
  // SHOW MESSAGE
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
  // OTP BOX
  // ============================================================

  Widget _buildOtpBox(
    int index,
  ) {
    final bool isFocused =
        _focusNodes[index].hasFocus;

    return SizedBox(
      width: 48,
      height: 58,
      child: TextField(
        controller:
            _controllers[index],

        focusNode:
            _focusNodes[index],

        enabled:
            !_isVerified &&
                !_isLoading,

        keyboardType:
            TextInputType.number,

        textInputAction:
            TextInputAction.next,

        textAlign:
            TextAlign.center,

        maxLength:
            1,

        style:
            const TextStyle(
          color: darkColor,
          fontSize: 23,
          fontWeight:
              FontWeight.w700,
        ),

        onChanged:
            (String text) {
          _onOtpChanged(
            index,
            text,
          );
        },

        decoration:
            InputDecoration(
          counterText: '',

          filled: true,

          fillColor:
              Colors.white,

          contentPadding:
              EdgeInsets.zero,

          border:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              12,
            ),

            borderSide:
                const BorderSide(
              color:
                  borderColor,
              width: 1.2,
            ),
          ),

          enabledBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              12,
            ),

            borderSide:
                BorderSide(
              color: _isVerified
                  ? primaryColor
                  : isFocused
                      ? primaryColor
                      : borderColor,

              width:
                  _isVerified ||
                          isFocused
                      ? 2
                      : 1.2,
            ),
          ),

          focusedBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              12,
            ),

            borderSide:
                const BorderSide(
              color:
                  primaryColor,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // OTP BOX ROW
  // ============================================================

  Widget _buildOtpBoxes() {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.center,

      children:
          List.generate(
        6,
        (int index) {
          return Padding(
            padding:
                EdgeInsets.only(
              right:
                  index == 5
                      ? 0
                      : 7,
            ),

            child:
                _buildOtpBox(
              index,
            ),
          );
        },
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

          padding:
              const EdgeInsets.fromLTRB(
            24,
            25,
            24,
            30,
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,

            children: [
              // ==================================================
              // BACK BUTTON
              // ==================================================

              GestureDetector(
                onTap:
                    _isVerified
                        ? null
                        : () {
                            Navigator.pop(
                              context,
                            );
                          },

                child:
                    const Icon(
                  Icons
                      .arrow_back_ios_new_rounded,

                  color:
                      darkColor,

                  size:
                      27,
                ),
              ),

              const SizedBox(
                height:
                    70,
              ),

              // ==================================================
              // TITLE
              // ==================================================

              const Text(
                'Verify your\nmobile number',

                style:
                    TextStyle(
                  color:
                      darkColor,

                  fontSize:
                      38,

                  height:
                      1.1,

                  fontWeight:
                      FontWeight.w800,
                ),
              ),

              const SizedBox(
                height:
                    25,
              ),

              // ==================================================
              // DESCRIPTION
              // ==================================================

              const Text(
                'We sent a verification code to',

                style:
                    TextStyle(
                  color:
                      greyColor,

                  fontSize:
                      17,

                  fontWeight:
                      FontWeight.w500,
                ),
              ),

              const SizedBox(
                height:
                    5,
              ),

              Text(
                '+91 ${widget.phoneNumber}',

                style:
                    const TextStyle(
                  color:
                      darkColor,

                  fontSize:
                      18,

                  fontWeight:
                      FontWeight.w700,
                ),
              ),

              const SizedBox(
                height:
                    42,
              ),

              // ==================================================
              // OTP BOXES
              // ==================================================

              _buildOtpBoxes(),

              const SizedBox(
                height:
                    25,
              ),

              // ==================================================
              // ERROR
              // ==================================================

              if (_errorMessage
                  .isNotEmpty)
                Center(
                  child:
                      Text(
                    _errorMessage,

                    textAlign:
                        TextAlign.center,

                    style:
                        const TextStyle(
                      color:
                          Colors.redAccent,

                      fontSize:
                          15,

                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),

              // ==================================================
              // SUCCESS
              // ==================================================

              if (_isVerified)
                const Center(
                  child:
                      Row(
                    mainAxisSize:
                        MainAxisSize.min,

                    children: [
                      Icon(
                        Icons
                            .check_circle_rounded,

                        color:
                            primaryColor,

                        size:
                            23,
                      ),

                      SizedBox(
                        width:
                            8,
                      ),

                      Text(
                        'Verified Successfully',

                        style:
                            TextStyle(
                          color:
                              primaryColor,

                          fontSize:
                              16,

                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

              // ==================================================
              // RESEND
              // ==================================================

              if (!_isVerified)
                const Center(
                  child:
                      Padding(
                    padding:
                        EdgeInsets.only(
                      top:
                          5,
                    ),

                    child:
                        Text(
                      "Didn't receive the code?  Resend OTP",

                      style:
                          TextStyle(
                        color:
                            primaryColor,

                        fontSize:
                            15,

                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ),
                ),

              const SizedBox(
                height:
                    55,
              ),

              // ==================================================
              // VERIFY BUTTON
              // ==================================================

              SizedBox(
                width:
                    double.infinity,

                height:
                    58,

                child:
                    ElevatedButton(
                  onPressed:
                      _isLoading ||
                              _isVerified
                          ? null
                          : _verifyOTP,

                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        primaryColor,

                    disabledBackgroundColor:
                        primaryColor,

                    foregroundColor:
                        Colors.white,

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
                                  24,
                              height:
                                  24,
                              child:
                                  CircularProgressIndicator(
                                color:
                                    Colors.white,
                                strokeWidth:
                                    3,
                              ),
                            )
                          : Text(
                              _isVerified
                                  ? 'Verified'
                                  : 'Verify OTP',

                              style:
                                  const TextStyle(
                                fontSize:
                                    18,
                                fontWeight:
                                    FontWeight
                                        .w800,
                              ),
                            ),
                ),
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

class WorkerHomeScreen
    extends StatelessWidget {
  const WorkerHomeScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
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