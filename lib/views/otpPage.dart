import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:pin_entry_text_field/pin_entry_text_field.dart';
import 'package:qme/api/signin.dart';
import 'package:qme/views/home.dart';
import 'package:qme/views/signin.dart';
import 'package:qme/widgets/button.dart';
import 'package:qme/widgets/text.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();

                                      _fcmToken = prefs.getString('fcmToken');

                                      AuthResult result = await authOtp
                                          .signInWithCredential(credential);

                                      FirebaseUser userFireBAse = result.user;

                                      if (userFireBAse != null) {
                                        var token = await userFireBAse
                                            .getIdToken()
                                            .then((result) {
                                          idToken = result.token;
                                          formData['token'] = idToken;
                                          print("@@ $idToken @@");
                                        });
                                        if (loginPage == "SignUp") {
                                          Scaffold.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Processing Data'),
                                            ),
                                          );
                                          SharedPreferences prefs =
                                              await SharedPreferences
                                                  .getInstance();
                                          print("Signup page redirected");
                                          formData['firstName'] = prefs
                                              .getString('userFirstNameSignup');
                                          formData['lastName'] = prefs
                                              .getString('userLastNameSignup');
                                          formData['phone'] = prefs
                                              .getString('userPhoneSignup');
                                          formData['password'] = prefs
                                              .getString('userPasswordSignup');
                                          formData['cpassword'] = prefs
                                              .getString('userCpasswordSignup');
                                          formData['email'] = prefs
                                              .getString('userEmailSignup');

                                          log('$formData');

                                          _fcmToken = prefs.getString(
                                            'fcmToken',
                                          );
                                          formData['name'] =
                                              formData['firstName'] +
                                                  " " +
                                                  formData['lastName'];

                                          UserRepository user =
                                              UserRepository();
                                          formData['name'] =
                                              '${formData['firstName']}|${formData['lastName']}';
                                          // Make SignUp API call
                                          Map response;
                                          try {
                                            print("signUpData");
                                            print(formData['phone']);
                                            print(formData['name']);
                                            print(formData);
                                            response =
                                                await user.signUp(formData);
                                            print(response['status']);
                                            print(response);
                                          } on BadRequestException catch (e) {
                                            log('BadRequestException on SignUp:' +
                                                e.toString());
                                            Scaffold.of(context)
                                                .showSnackBar(SnackBar(
                                              content: Text(
                                                e.toString(),
                                              ),
                                            ));
                                          } catch (e) {
                                            log('SignUp failed:' +
                                                e.toString());
                                            Scaffold.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(e.toString()),
                                              ),
                                            );
                                          }
                                          log('SignUp response:${response.toString()}');

                                          if (response != null &&
                                              response['msg'] ==
                                                  'Registation successful') {
                                            // Make SignIn call
                                            try {
                                              SharedPreferences prefs =
                                                  await SharedPreferences
                                                      .getInstance();
                                              prefs.setString(
                                                  'fcmToken', _fcmToken);
                                              Scaffold.of(context).showSnackBar(
                                                  SnackBar(
                                                      content: Text(
                                                          'Processing Data')));
                                              response =
                                                  // Make LOGIN API call
                                                  response =
                                                      await signInWithOtp(
                                                          idToken);
                                              print("reponse Status ");

                                              if (response['status'] == 200) {
                                                print(
                                                    "respose of ${response['status']}");
                                                print(response);

                                                Navigator.pushNamed(
                                                    context, HomeScreen.id);
                                                var responsefcm =
                                                    await fcmTokenSubmit(
                                                        _fcmToken);
                                                print(
                                                    "fcm token Api: $responsefcm");
                                                print(
                                                    "fcm token Api response: ${responsefcm['status']}");
                                              } else {
                                                return print(
                                                    "error in api hit");
                                              }
                                            } catch (e) {
                                              Scaffold.of(context).showSnackBar(
                                                  SnackBar(
                                                      content:
                                                          Text(e.toString())));
                                              // _showSnackBar(e.toString());
                                              log('Error in signIn API: ' +
                                                  e.toString());
                                              return;
                                            }
                                            // if (response['name'] != null) {
                                            //   // SignIn successful
                                            //   Navigator.pushNamed(
                                            //       context, NearbyScreen.id);
                                            // }
                                          } else {
                                            print("SignUp failed");
                                            return;
                                          }
                                        } else {
                                          print("Else is called");
                                          Map response;
                                          try {
                                            Scaffold.of(context).showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        'Processing Data')));
                                            response =
                                                // Make LOGIN API call
                                                response = await signInWithOtp(
                                                    idToken);

                                            if (response['status'] == 200) {
                                              print(
                                                  "respose of ${response['status']}");
                                              print(response);

                                              SharedPreferences prefs =
                                                  await SharedPreferences
                                                      .getInstance();

                                              var responsefcm =
                                                  await fcmTokenSubmit(
                                                      _fcmToken);
                                              print(
                                                  "fcm token Api: $responsefcm");
                                              print(
                                                  "fcm token Api status: ${responsefcm['status']}");
                                              prefs.setString(
                                                  'fcmToken', _fcmToken);
                                              Navigator.pushNamed(
                                                  context, HomeScreen.id);
                                            } else {
                                              print(response['status']);
                                              print(response);
                                              Scaffold.of(context).showSnackBar(
                                                  SnackBar(
                                                      content: Text(response[
                                                                  'status']
                                                              .toString() +
                                                          " " +
                                                          response['error']
                                                              .toString())));
                                              return print("error in api hit");
                                            }
                                          } catch (e) {
                                            Scaffold.of(context).showSnackBar(
                                                SnackBar(
                                                    content:
                                                        Text(e.toString())));
                                            // _showSnackBar(e.toString());
                                            log('Error in signIn API: ' +
                                                e.toString());
                                            return;
                                          }
                                        }
                                      } else {
                                        print("Error");
                                      }
                                    } on PlatformException catch (e) {
                                      print("Looking for Error code");
                                      print(e.message);
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
                                                                      builder:
                                                                          (context) =>
                                                                              SignInScreen(),
                                                                    ),
                                                                    (route) =>
                                                                        false);
                                                  },
                                                )
                                              ],
                                            );
                                          });
                                      print(e.code);
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
                                                                      builder:
                                                                          (context) =>
                                                                              SignInScreen(),
                                                                    ),
                                                                    (route) =>
                                                                        false);
                                                    // Navigator.of(context).pop();

                                                  },
                                                )
                                              ],
                                            );
                                          });
                                      print("Looking for Error message");
                                      print(e);
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
