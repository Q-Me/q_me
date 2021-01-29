import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qme/model/api_params/signup.dart';
import 'package:qme/model/user.dart';
import 'package:qme/repository/user.dart';
import 'package:qme/utilities/logger.dart';
import 'package:qme/views/home.dart';
import 'package:qme/views/otpPage.dart';

class FirebaseAuthService {
  Future phoneNumberAuth(
      {@required String phoneNumber,
      @required BuildContext context,
      @required bool isLogin,
      @required BuildContext dialogContext}) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    FirebaseErrorNotifier errorNotif = FirebaseErrorNotifier(
      FirebaseError(false, ""),
    );

    await _auth.verifyPhoneNumber(
      codeSent: (verificationId, forceResendingToken) {
        Navigator.of(context).pushNamed(
          OtpPage.id,
          arguments: OtpPageArguments(
            isLogin: isLogin,
            verificationId: verificationId,
            errorNotif: errorNotif,
          ),
        );
      },
      verificationCompleted: (phoneAuthCredential) async {
        try {
          UserCredential userCredential =
              await _auth.signInWithCredential(phoneAuthCredential);
          String idToken = await userCredential.user.getIdToken().then((value) {
            logger.i("idToken is $value");
            return value;
          }, onError: (error) => logger.e("error ocurred + $error"));

          if (isLogin) {
            UserData user = await UserRepository().signInWithOtp(idToken);
            updateUserData(user);
          } else {
            UserData user = getUserDataFromStorage();
            await UserRepository().signUp(
              SignUpParams(
                idToken: idToken,
                name: user.name,
                password: user.password,
                phone: user.phone,
                email: user?.email,
              ),
            );
            await UserRepository().signInWithOtp(idToken);
          }
          Navigator.of(context)
              .pushNamedAndRemoveUntil(HomeScreen.id, (Route route) => false);
          return;
        } catch (e) {
          logger.e(e.toString());
          errorNotif.value = FirebaseError(true, e.toString());
        }
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
        Navigator.pop(dialogContext);
        Scaffold.of(context).hideCurrentSnackBar();
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "An unexpected error occured while signing you in. Please try again"),
          ),
        );
        errorNotif.value = FirebaseError(true, error.toString());
      },
      phoneNumber: phoneNumber,
      timeout: Duration(seconds: 60),
    );
  }
}

class FirebaseError {
  FirebaseError(this.error, this.message);

  bool error;
  String message;
}

class FirebaseErrorNotifier extends ValueNotifier<FirebaseError> {
  FirebaseErrorNotifier(FirebaseError value) : super(value);

  void errorOccurred(bool error, String message) {
    value.error = error;
    value.message = message;
    notifyListeners();
  }
}
