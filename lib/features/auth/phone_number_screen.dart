import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'otp_screen.dart';

class PhoneNumberScreen extends StatefulWidget {
  const PhoneNumberScreen({
    super.key,
  });

  @override
  State<PhoneNumberScreen> createState() =>
      _PhoneNumberScreenState();
}

class _PhoneNumberScreenState
    extends State<PhoneNumberScreen> {
  final TextEditingController _phoneController =
      TextEditingController();

  final FocusNode _phoneFocusNode =
      FocusNode();

  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();

    super.dispose();
  }

  // ============================================================
  // CONTINUE BUTTON
  // ============================================================
  
   Future<void> _continue() async {

  final String phone =
      _phoneController.text.trim();


  if (phone.length != 10) {

    ScaffoldMessenger.of(context)
        .showSnackBar(

      const SnackBar(
        content:
            Text(
          'Please enter a valid 10-digit mobile number',
        ),
      ),

    );

    return;
  }



  FocusScope.of(context).unfocus();



  setState(() {

    _isLoading = true;

  });



  await AuthService().sendOTP(

    phoneNumber:
        '+91$phone',



    onCodeSent:
        (String verificationId) {


      if (!mounted) return;



      setState(() {

        _isLoading = false;

      });



      Navigator.push(

        context,


        MaterialPageRoute(

          builder:
              (context) => OtpScreen(

            phoneNumber:
                phone,


            verificationId:
                verificationId,

          ),

        ),

      );


    },



    onError:
        (String error) {


      if (!mounted) return;



      setState(() {

        _isLoading = false;

      });



      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          content:
              Text(error),

        ),

      );


    },

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
          const Color(0xFFF8FAF9),

      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 24,
          ),

          child: Column(
            children: [
              // ==================================================
              // TOP CONTENT
              // ==================================================

              Expanded(
                child: SingleChildScrollView(
                  physics:
                      const BouncingScrollPhysics(),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      const SizedBox(
                        height: 34,
                      ),

                      // ==========================================
                      // LOGO
                      // ==========================================

                      Center(
                        child: Container(
                          width: 82,
                          height: 82,

                          padding:
                              const EdgeInsets.all(
                            7,
                          ),

                          decoration:
                              BoxDecoration(
                            color:
                                Colors.white,

                            shape:
                                BoxShape.circle,

                            boxShadow: [
                              BoxShadow(
                                color:
                                    const Color(
                                  0xFF00A88F,
                                ).withValues(
                                  alpha: 0.15,
                                ),

                                blurRadius: 25,

                                spreadRadius: 3,
                              ),
                            ],
                          ),

                          child:
                              ClipOval(
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

                      const SizedBox(
                        height: 34,
                      ),

                      // ==========================================
                      // TITLE
                      // ==========================================

                      const Text(
                        'Welcome to\nHandzy Thozhan 👋',

                        style:
                            TextStyle(
                          color:
                              Color(0xFF17212B),

                          fontSize: 29,

                          height: 1.15,

                          fontWeight:
                              FontWeight.w800,

                          letterSpacing:
                              -0.5,
                        ),
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      const Text(
                        'Enter your mobile number to '
                        'continue',

                        style:
                            TextStyle(
                          color:
                              Color(0xFF737D88),

                          fontSize: 15,

                          height: 1.5,

                          fontWeight:
                              FontWeight.w500,
                        ),
                      ),

                      const SizedBox(
                        height: 32,
                      ),

                      // ==========================================
                      // PHONE LABEL
                      // ==========================================

                      const Text(
                        'Mobile number',

                        style:
                            TextStyle(
                          color:
                              Color(0xFF17212B),

                          fontSize: 14,

                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      // ==========================================
                      // PHONE FIELD
                      // ==========================================

                      Container(
                        height: 58,

                        decoration:
                            BoxDecoration(
                          color:
                              Colors.white,

                          borderRadius:
                              BorderRadius.circular(
                            15,
                          ),

                          border:
                              Border.all(
                            color:
                                const Color(
                              0xFFDDE5E2,
                            ),

                            width: 1.2,
                          ),
                        ),

                        child: Row(
                          children: [
                            // ==================================
                            // COUNTRY CODE
                            // ==================================

                            Container(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 15,
                              ),

                              child:
                                  const Row(
                                children: [
                                  Text(
                                    '🇮🇳',

                                    style:
                                        TextStyle(
                                      fontSize:
                                          20,
                                    ),
                                  ),

                                  SizedBox(
                                    width: 8,
                                  ),

                                  Text(
                                    '+91',

                                    style:
                                        TextStyle(
                                      color:
                                          Color(
                                        0xFF17212B,
                                      ),

                                      fontSize:
                                          15,

                                      fontWeight:
                                          FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              width: 1,
                              height: 30,

                              color:
                                  const Color(
                                0xFFE2E8E5,
                              ),
                            ),

                            // ==================================
                            // MOBILE NUMBER
                            // ==================================

                            Expanded(
                              child:
                                  TextField(
                                controller:
                                    _phoneController,

                                focusNode:
                                    _phoneFocusNode,

                                keyboardType:
                                    TextInputType.phone,

                                maxLength:
                                    10,

                                textInputAction:
                                    TextInputAction.done,

                                onSubmitted:
                                    (_) =>
                                        _continue(),

                                decoration:
                                    const InputDecoration(
                                  hintText:
                                      'Enter mobile number',

                                  hintStyle:
                                      TextStyle(
                                    color:
                                        Color(
                                      0xFFA4ADB5,
                                    ),

                                    fontSize:
                                        15,
                                  ),

                                  counterText:
                                      '',

                                  border:
                                      InputBorder.none,

                                  contentPadding:
                                      EdgeInsets
                                          .symmetric(
                                    horizontal:
                                        15,
                                  ),
                                ),

                                style:
                                    const TextStyle(
                                  color:
                                      Color(
                                    0xFF17212B,
                                  ),

                                  fontSize:
                                      17,

                                  fontWeight:
                                      FontWeight.w600,

                                  letterSpacing:
                                      0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      // ==========================================
                      // INFO
                      // ==========================================

                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          const Icon(
                            Icons
                                .verified_user_outlined,

                            size: 18,

                            color:
                                Color(
                              0xFF00A88F,
                            ),
                          ),

                          const SizedBox(
                            width: 8,
                          ),

                          Expanded(
                            child:
                                Text(
                              'We will send you a verification '
                              'code to confirm your number.',

                              style:
                                  TextStyle(
                                color:
                                    const Color(
                                  0xFF737D88,
                                ).withValues(
                                  alpha: 0.9,
                                ),

                                fontSize:
                                    12.5,

                                height:
                                    1.45,

                                fontWeight:
                                    FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ==================================================
              // BOTTOM CONTENT
              // ==================================================

              Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 18,
                ),

                child: Column(
                  children: [
                    // ============================================
                    // CONTINUE BUTTON
                    // ============================================

                    SizedBox(
                      width:
                          double.infinity,

                      height: 56,

                      child:
                          ElevatedButton(
                        onPressed:
                            _isLoading
                                ? null
                                : _continue,

                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              const Color(
                            0xFF00A88F,
                          ),

                          disabledBackgroundColor:
                              const Color(
                            0xFF8CCFC3,
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
                                    width: 23,
                                    height: 23,

                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth:
                                          2.5,

                                      color:
                                          Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Continue',

                                    style:
                                        TextStyle(
                                      color:
                                          Colors.white,

                                      fontSize:
                                          16,

                                      fontWeight:
                                          FontWeight.w700,
                                    ),
                                  ),
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    // ============================================
                    // TERMS
                    // ============================================

                    Padding(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 12,
                      ),

                      child:
                          RichText(
                        textAlign:
                            TextAlign.center,

                        text:
                            const TextSpan(
                          style:
                              TextStyle(
                            color:
                                Color(
                              0xFF8A949D,
                            ),

                            fontSize:
                                11.5,

                            height:
                                1.45,
                          ),

                          children: [
                            TextSpan(
                              text:
                                  'By continuing, you agree to our ',
                            ),

                            TextSpan(
                              text:
                                  'Terms of Service',

                              style:
                                  TextStyle(
                                color:
                                    Color(
                                  0xFF00A88F,
                                ),

                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),

                            TextSpan(
                              text:
                                  ' and ',
                            ),

                            TextSpan(
                              text:
                                  'Privacy Policy',

                              style:
                                  TextStyle(
                                color:
                                    Color(
                                  0xFF00A88F,
                                ),

                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),

                            TextSpan(
                              text:
                                  '.',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

