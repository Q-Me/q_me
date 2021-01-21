import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qme/model/user.dart';
import 'package:qme/repository/user.dart';
import 'package:qme/utilities/logger.dart';
import 'package:qme/views/home.dart';
import 'package:qme/views/otpPage.dart';

class FirebaseAuthService {
  Future phoneNumberAuth({@required String phoneNumber,@required BuildContext context,
      @required bool isLogin, @required BuildContext dialogContext}) async {
    FirebaseAuth _auth = FirebaseAuth.instance;

    await _auth.verifyPhoneNumber(
      codeSent: (verificationId, forceResendingToken) {
        Navigator.of(context).pushNamed(
          OtpPage.id,
          arguments: OtpPageArguments(
            isLogin: isLogin,
            verificationId: verificationId,
          ),
        );
      },
      verificationCompleted: (phoneAuthCredential) async {
        UserCredential userCredential =
            await _auth.signInWithCredential(phoneAuthCredential);
        String idToken = await userCredential.user.getIdToken();
        UserData user = await UserRepository().signInWithOtp(idToken);
        updateUserData(user);
        Navigator.of(context)
            .pushNamedAndRemoveUntil(HomeScreen.id, (Route route) => false);
        return;
      },
      codeAutoRetrievalTimeout: (verificationId) {
        Navigator.of(context).pushNamed(
          OtpPage.id,
          arguments: OtpPageArguments(
            isLogin: isLogin,
            verificationId: verificationId,
          ),
        );
      },
      verificationFailed: (error) {
        logger.e(error.toString());
        Scaffold.of(context).hideCurrentSnackBar();
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "An unexpected error occured while signing you in. Please try again"),
          ),
        );
      },
      phoneNumber: phoneNumber,
      timeout: Duration(seconds: 60),
    );
  }
}

// class FirebaseAuthStatus {}

// class FirebaseAuthError {
//   final FirebaseAuthException error;

//   FirebaseAuthError(this.error);
// }

// class FirebaseAuthSuccess {}

// class FirebaseAuthSmsRequired {
//   final String verificationId;

//   FirebaseAuthSmsRequired(this.verificationId);
// }
