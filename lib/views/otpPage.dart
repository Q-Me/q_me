import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:pin_entry_text_field/pin_entry_text_field.dart';
import 'package:qme/api/signin.dart';
import 'package:qme/utilities/logger.dart';
import 'package:qme/views/home.dart';
import 'package:qme/views/signin.dart';
import 'package:qme/widgets/button.dart';

import '../api/app_exceptions.dart';
import '../repository/user.dart';
import '../views/nearby.dart';
import 'signup.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OtpPage extends StatefulWidget {
  static const id = '/otpPage';

  @override
  _OtpPageState createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  Map<String, String> formData = {};
  var idToken;
  final formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  var _fcmToken;
  fcmTokenApiCall() async {
    Box box = await Hive.openBox("user");
    _fcmToken = await box.get('fcmToken');
    var responsefcm = await fcmTokenSubmit(_fcmToken);
    print("fcm token Api: $responsefcm");
    print("fcm token Api status: ${responsefcm['status']}");
    await box.put('fcmToken', _fcmToken);
    print(_fcmToken);
  }

  signInUser(BuildContext context) async {
    Map response;
    try {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('Processing Data')));
      response =
          // Make LOGIN API call
          response = await signInWithOtp(idToken);

      if (response['status'] == 200) {
        logger.d(response);
        fcmTokenApiCall();

        Navigator.pushNamed(context, HomeScreen.id);
      } else {
        logger.d(response);
        Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text(response['eror'].toString())));
        return logger.d("error in api hit");
      }
    } catch (e) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      log('Error in signIn API: ' + e.toString());
      return;
    }
  }

  signUpUser(BuildContext context) async {
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text('Processing Data'),
      ),
    );
    Box box = await Hive.openBox("user");
    formData['firstName'] = await box.get('userFirstNameSignup');
    formData['lastName'] = await box.get('userLastNameSignup');
    formData['phone'] = await box.get('userPhoneSignup');
    formData['password'] = await box.get('userPasswordSignup');
    formData['cpassword'] = await box.get('userCpasswordSignup');
    formData['email'] = await box.get('userEmailSignup');

    log('$formData');
    formData['name'] = formData['firstName'] + " " + formData['lastName'];

    UserRepository user = UserRepository();
    formData['name'] = '${formData['firstName']}|${formData['lastName']}';
    // Make SignUp API call
    Map response;
    try {
      logger.d(formData);
      response = await user.signUp(formData);
    } on BadRequestException catch (e) {
      log('BadRequestException on SignUp:' + e.toString());
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(
          e.toString(),
        ),
      ));
    } catch (e) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
    log('SignUp response:${response.toString()}');

    if (response != null && response['msg'] == 'Registation successful') {
      // Make SignIn call
      try {
        Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text('Processing Data')));
        response =
            // Make LOGIN API call
            response = await signInWithOtp(idToken);

        if (response['status'] == 200) {
          logger.d("respose of ${response['status']}");
          logger.d(response);

          Navigator.pushNamed(context, HomeScreen.id);
          fcmTokenApiCall();
        } else {
          return logger.d("error in api hit");
        }
      } catch (e) {
        Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
        log('Error in signIn API: ' + e.toString());
        return;
      }
    } else {
      logger.d("SignUp failed");
      //Navigator.pushNamed(context, SignInScreen.id);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Builder(
        builder: (context) => Form(
          key: formKey,
          child: KeyboardAvoider(
            autoScroll: true,
            child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    MyBackButton(),
                    Container(
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.025),
                        child: Center(
                          child: Hero(
                            tag: 'hero',
                            child: new CircleAvatar(
                              backgroundColor: Colors.transparent,
                              radius: 60.0,
                              child: SvgPicture.asset("assets/temp/users.svg"),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical:
                                MediaQuery.of(context).size.height * 0.15),
                        child: Column(
                          children: <Widget>[
                            Text(
                              "OTP Verification",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 25.0),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.03,
                            ),
                            Text("Enter OTP sent to mobile number"),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.05,
                            ),
                            PinEntryTextField(
                              fieldWidth:
                                  MediaQuery.of(context).size.width * 0.1,
                              fields: 6,
                              onSubmit: (String pin) {
                                _codeController.text = pin;
                              }, // end onSubmit
                            ),
                            SizedBox(height: 50.0),
                            Container(
                              height: 50.0,
                              child: Material(
                                borderRadius: BorderRadius.circular(20.0),
                                shadowColor: Colors.blueAccent,
                                color: Theme.of(context).primaryColor,
                                elevation: 7.0,
                                child: InkWell(
                                  onTap: () async {
                                    final code = _codeController.text.trim();
                                    try {
                                      AuthCredential credential =
                                          PhoneAuthProvider.getCredential(
                                              verificationId: verificationIdOtp,
                                              smsCode: code);

                                      Box box = await Hive.openBox("user");

                                      _fcmToken = await box.get('fcmToken');

                                      AuthResult result = await authOtp
                                          .signInWithCredential(credential);

                                      FirebaseUser userFireBAse = result.user;

                                      if (userFireBAse != null) {
                                        var token = await userFireBAse
                                            .getIdToken()
                                            .then((result) {
                                          idToken = result.token;
                                          formData['token'] = idToken;
                                          logger.d("@@ $idToken @@");
                                        });
                                        if (loginPage == "SignUp") {
                                          signUpUser(context);
                                        } else {
                                          signInUser(context);
                                        }
                                      } else {
                                        logger.d("Some Error occured");
                                      }
                                    } on PlatformException catch (e) {
                                      Navigator.of(context).pop();

                                      showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (context) {
                                            return AlertDialog(
                                              title:
                                                  Text("Verification Failed"),
                                              content: Text(e.code.toString()),
                                              actions: <Widget>[
                                                FlatButton(
                                                  child: Text("OK"),
                                                  textColor: Colors.white,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  onPressed: () {
                                                    // Navigator.of(context).pop();
                                                    Navigator
                                                        .pushAndRemoveUntil(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  SignInScreen(),
                                                            ),
                                                            (route) => false);
                                                  },
                                                )
                                              ],
                                            );
                                          });
                                      logger.d(e.code);
                                    } on Exception catch (e) {
                                      Navigator.of(context).pop();

                                      showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (context) {
                                            return AlertDialog(
                                              title:
                                                  Text("Verification Failed"),
                                              content: Text(e.toString()),
                                              actions: <Widget>[
                                                FlatButton(
                                                  child: Text("OK"),
                                                  textColor: Colors.white,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  onPressed: () async {
                                                    Navigator
                                                        .pushAndRemoveUntil(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  SignInScreen(),
                                                            ),
                                                            (route) => false);
                                                    // Navigator.of(context).pop();
                                                  },
                                                )
                                              ],
                                            );
                                          });
                                      logger.d(e);
                                    }
                                  },
                                  child: Center(
                                    child: Text(
                                      'Verify',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Montserrat'),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20.0),
                            SizedBox(
                              height: MediaQuery.of(context).viewInsets.bottom,
                            )
                          ],
                        )),
                  ]),
            ),
          ),
        ),
      )),
    );
  }
}
