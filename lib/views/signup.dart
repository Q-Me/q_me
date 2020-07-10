import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:qme/api/app_exceptions.dart';
import 'package:qme/api/signin.dart';
import 'package:qme/constants.dart';
import 'package:qme/repository/user.dart';
import 'package:qme/views/nearby.dart';
import 'package:qme/views/otpPage.dart';
import 'package:qme/widgets/button.dart';
import 'package:qme/widgets/formField.dart';
import 'package:qme/widgets/text.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpScreen extends StatefulWidget {
  static const id = '/signup';

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

var verificationIdOtp;
var authOtp;

class _SignUpScreenState extends State<SignUpScreen> {
  bool showSpinner = false, passwordVisible;
  final ScrollController _scrollController = ScrollController();
  final _phoneController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  Map<String, String> formData = {};

  final _codeController = TextEditingController();

  var idToken;
  bool showOtpTextfield = false;

  // otp verification with firebase
  Future<bool> loginUser(String phone, BuildContext context) async {
    FirebaseAuth _auth = FirebaseAuth.instance;

    _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: Duration(seconds: 60),
        verificationCompleted: (AuthCredential credential) async {
          AuthResult result = await _auth.signInWithCredential(credential);

          FirebaseUser user = result.user;

          if (user != null) {
            var token = await user.getIdToken().then((result) {
              idToken = result.token;
              formData['token'] = idToken;
              print(" $idToken ");
            });
            final code = _codeController.text.trim();
            try {
              log('$formData');
              SharedPreferences prefs = await SharedPreferences.getInstance();

              formData['firstName'] = prefs.getString('userFirstNameSignup');
              formData['lastName'] = prefs.getString('userLastNameSignup');
              formData['phone'] = prefs.getString('userPhoneSignup');
              formData['password'] = prefs.getString('userPasswordSignup');
              formData['cpassword'] = prefs.getString('userCpasswordSignup');
              formData['email'] = prefs.getString(
                'userEmailSignup',
              );
              formData['name'] =
                  formData['firstName'] + " " + formData['lastName'];

              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text('Processing Data'),
                ),
              );

              UserRepository user = UserRepository();
              formData['name'] =
                  '${formData['firstName']}|${formData['lastName']}';
              // Make SignUp API call
              Map response;
              try {
                print("signUpData");
                print(formData['phone']);
                print(formData['name']);
                print(formData);
                response = await user.signUp(formData);
                print(response['status']);
                print(response);
              } on BadRequestException catch (e) {
                log('BadRequestException on SignUp:' + e.toString());
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text(
                    e.toString(),
                  ),
                ));
              } catch (e) {
                log('SignUp failed:' + e.toString());
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString()),
                  ),
                );
              }
              log('SignUp response:${response.toString()}');

              if (response != null &&
                  response['msg'] == 'Registation successful') {
                // Make SignIn call
                try {
                  response =
                      // Make LOGIN API call
                      response = await signInWithOtp(idToken);
                  print("reponse Status ");

                  if (response['status'] == 200) {
                    print("respose of ${response['status']}");
                    print(response);
                    Navigator.pushNamed(context, NearbyScreen.id);
                  } else {
                    return print("error in api hit");
                  }
                } catch (e) {
                  Scaffold.of(context)
                      .showSnackBar(SnackBar(content: Text(e.toString())));
                  // _showSnackBar(e.toString());
                  log('Error in signIn API: ' + e.toString());
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
            } on PlatformException catch (e) {
              print("Looking for Error code");
              print(e.message);
              Navigator.of(context).pop();

              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Verification Failed"),
                      content: Text(e.code.toString()),
                      actions: <Widget>[
                        FlatButton(
                          child: Text("OK"),
                          textColor: Colors.white,
                          color: Theme.of(context).primaryColor,
                          onPressed: () {
                            Navigator.of(context).pop();
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
                      title: Text("Verification Failed"),
                      content: Text(e.toString()),
                      actions: <Widget>[
                        FlatButton(
                          child: Text("OK"),
                          textColor: Colors.white,
                          color: Theme.of(context).primaryColor,
                          onPressed: () async {
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    );
                  });
              print("Looking for Error message");
              print(e);
            }
          } else {
            print("Error");
          }

          //This callback would gets called when verification is done auto maticlly
        },
        verificationFailed: (AuthException exception) {
          print(exception.message);
          Scaffold.of(context).showSnackBar(
              SnackBar(content: Text(exception.message.toString())));
        },
        codeSent: (String verificationId, [int forceResendingToken]) {
          verificationIdOtp = verificationId;
          authOtp = _auth;

          Navigator.of(context).pushNamed(OtpPage.id);
          //
        },
        codeAutoRetrievalTimeout: null);
  }

  @override
  void initState() {
    passwordVisible = false;
    super.initState();
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
              controller: _scrollController,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    MyBackButton(),
                    Container(
                        padding: EdgeInsets.only(left: 20),
                        child: ThemedText(words: ['Hop', 'In'])),
                    Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 30.0),
                        child: Column(
                          children: <Widget>[
                            MyFormField(
                              required: true,
                              name: 'FIRST NAME',
                              callback: (value) {
                                formData['firstName'] = value;
                                print(formData['firstName']);
                                log('first name is ${formData['firstName']}');
                              },
                            ),
                            SizedBox(height: 10.0),
                            MyFormField(
                              name: 'LAST NAME',
                              callback: (value) {
                                formData['lastName'] = value;
                                print(formData['lastName']);

                                log('last name is ${formData['lastName']}');
                              },
                            ),
                            SizedBox(height: 10.0),
                            Container(
                              child: TextFormField(
                                keyboardType: TextInputType.phone,
                                controller: _phoneController,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'This field cannot be left blank';
                                  } else {
                                    //setState(() {
                                    formData['phone'] = value;
                                    print(formData['phone']);
                                    //  });
                                  }
                                },
                                decoration: kTextFieldDecoration.copyWith(
                                    labelText: "PHONE"),
                              ),
                            ),
                            SizedBox(height: 10.0),
                            MyFormField(
                              keyboardType: TextInputType.emailAddress,
                              name: 'EMAIL',
                              required: true,
                              callback: (value) {
                                formData['email'] = value;
                                print(formData['email']);
                              },
                            ),
                            SizedBox(height: 10.0),
                            TextFormField(
                              // Password
                              autofocus: true,
                              obscureText: !passwordVisible,
                              validator: (value) {
                                if (value.length < 6)
                                  return 'Password should be not be less than 6 characters';
                                else {
                                  formData['password'] = value;
                                  return null;
                                }
                              },
                              decoration: InputDecoration(
                                labelText: 'PASSWORD',
                                labelStyle: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor)),
                                focusColor: Colors.lightBlue,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    // Based on passwordVisible state choose the icon
                                    passwordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  onPressed: () {
                                    // Update the state i.e. toogle the state of passwordVisible variable
                                    setState(() {
                                      passwordVisible = !passwordVisible;
                                    });
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: 10.0),
                            TextFormField(
                              // Password
                              autofocus: true,
                              obscureText: !passwordVisible,
                              validator: (value) {
                                if (value.length < 6)
                                  return 'Password should be not be less than 6 characters';
                                else {
                                  formData['cpassword'] = value;
                                  return null;
                                }
                              },
                              decoration: InputDecoration(
                                labelText: 'CONFIRM PASSWORD',
                                labelStyle: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.green)),
                                focusColor: Theme.of(context).primaryColorDark,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    // Based on passwordVisible state choose the icon
                                    passwordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  onPressed: () {
                                    // Update the state i.e. toggle the state of passwordVisible variable
                                    setState(() {
                                      passwordVisible = !passwordVisible;
                                    });
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: 50.0),
                            Container(
                              /*TODO Make this container into a button class
                                       using provider of form data, form key and
                                       onTap callback function
                                       */
                              height: 50.0,
                              child: Material(
                                borderRadius: BorderRadius.circular(20.0),
                                shadowColor: Colors.greenAccent,
                                color: Colors.green,
                                elevation: 7.0,
                                child: InkWell(
                                  onTap: () async {
                                    FocusScope.of(context).requestFocus(
                                        FocusNode()); // dismiss the keyboard
                                    if (formKey.currentState.validate()) {
                                      log('$formData');
                                      // check phone number length
                                      if (formData['phone'].length != 13) {
                                        Scaffold.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Phone number must have 10 digits with country code'),
                                          ),
                                        );
                                      }

                                      if (formData['password'] !=
                                          formData['cpassword']) {
                                        Scaffold.of(context).showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Passwords do not match')),
                                        );
                                        return null;
                                      }

                                      Scaffold.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Processing Data'),
                                        ),
                                      );
                                      final phone =
                                          _phoneController.text.trim();
                                      print("phone number: $phone");
                                      print(formData);
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();

                                      prefs.setString('userFirstNameSignup',
                                          formData['firstName']);
                                      prefs.setString('userLastNameSignup',
                                          formData['lastName']);
                                      prefs.setString(
                                          'userPhoneSignup', formData['phone']);

                                      prefs.setString('userPasswordSignup',
                                          formData['password']);
                                      prefs.setString('userCpasswordSignup',
                                          formData['cpassword']);

                                      prefs.setString(
                                          'userEmailSignup', formData['email']);
                                      loginUser(phone, context);
                                      //   UserRepository user = UserRepository();
                                      //   formData['name'] =
                                      //       '${formData['firstName']}|${formData['lastName']}';
                                      //   // Make SignUp API call
                                      //   Map<String, dynamic> response;
                                      //   try {
                                      //     response = await user.signUp(formData);
                                      //   } on BadRequestException catch (e) {
                                      //     log('BadRequestException on SignUp:' +
                                      //         e.toString());
                                      //     Scaffold.of(context).showSnackBar(
                                      //       SnackBar(
                                      //         content: Text(
                                      //             e.toString(),
                                      //       ),
                                      //     ));
                                      //   } catch (e) {
                                      //     log('SignUp failed:' + e.toString());
                                      //     Scaffold.of(context).showSnackBar(
                                      //       SnackBar(
                                      //         content: Text(e.toString()),
                                      //       ),
                                      //     );
                                      //   }
                                      //   log('SignUp response:${response.toString()}');

                                      //   if (response != null &&
                                      //       response['msg'] ==
                                      //           'Registation successful') {
                                      //     // Make SignIn call
                                      //     try {
                                      //       response = await user.signIn({
                                      //         'email': formData['email'],
                                      //         'password': formData['password']
                                      //       });
                                      //     } catch (e) {
                                      //       log(e.toString());
                                      //       Scaffold.of(context).showSnackBar(
                                      //         SnackBar(
                                      //           content: Text(e.toString()),
                                      //         ),
                                      //       );
                                      //     }
                                      //     if (response['name'] != null) {
                                      //       // SignIn successful
                                      //       Navigator.pushNamed(
                                      //           context, NearbyScreen.id);
                                      //     }
                                      //   } else {
                                      //     // SignUp failed
                                      //     return;
                                      //   }
                                      // }
                                    }
                                  },
                                  child: Center(
                                    child: Text(
                                      'Verify Phone Number By OTP',
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
