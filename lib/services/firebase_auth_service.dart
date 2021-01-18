import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  void sendOtpToPhoneNumber(String phoneNumber) {
    FirebaseAuth _auth = FirebaseAuth.instance;

    _auth.verifyPhoneNumber(
      codeSent: (verificationId, forceResendingToken) {},
      verificationCompleted: (phoneAuthCredential) {},
      codeAutoRetrievalTimeout: (verificationId) {},
      verificationFailed: (error) {},
      phoneNumber: phoneNumber,
      timeout: Duration(seconds: 60),
    );
  }
}
