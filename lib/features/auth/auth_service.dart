import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // ============================================================
  // SEND OTP
  // ============================================================

  Future<void> sendOTP({
    required String phoneNumber,
    required Function(String verificationId)
        onCodeSent,
    required Function(String error)
        onError,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,

        // --------------------------------------------------------
        // ANDROID AUTO VERIFICATION
        // --------------------------------------------------------

        verificationCompleted:
            (PhoneAuthCredential credential) async {
          try {
            await _auth.signInWithCredential(
              credential,
            );
          } catch (e) {
            onError(
              e.toString(),
            );
          }
        },

        // --------------------------------------------------------
        // VERIFICATION FAILED
        // --------------------------------------------------------

        verificationFailed:
            (FirebaseAuthException e) {
          onError(
            e.message ??
                'OTP verification failed',
          );
        },

        // --------------------------------------------------------
        // OTP SENT
        // --------------------------------------------------------

        codeSent: (
          String verificationId,
          int? resendToken,
        ) {
          onCodeSent(
            verificationId,
          );
        },

        // --------------------------------------------------------
        // TIMEOUT
        // --------------------------------------------------------
        //
        // Inga onCodeSent call panna vendam.
        // VerificationId already codeSent-la kidaichidum.
        //

        codeAutoRetrievalTimeout:
            (String verificationId) {},
      );
    } catch (e) {
      onError(
        e.toString(),
      );
    }
  }

  // ============================================================
  // VERIFY OTP
  // ============================================================

  Future<UserCredential?> verifyOTP({
    required String verificationId,
    required String otp,
  }) async {
    try {
      final PhoneAuthCredential credential =
          PhoneAuthProvider.credential(
        verificationId:
            verificationId,
        smsCode:
            otp,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(
        credential,
      );

      return userCredential;
    } catch (e) {
      return null;
    }
  }

  // ============================================================
  // CURRENT USER
  // ============================================================

  User? get currentUser =>
      _auth.currentUser;

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    await _auth.signOut();
  }
}