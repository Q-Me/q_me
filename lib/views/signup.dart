import 'dart:developer';
import 'dart:io';

import 'package:checkbox_formfield/checkbox_formfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:provider/provider.dart';
import 'package:qme/api/app_exceptions.dart';
import 'package:qme/constants.dart';
import 'package:qme/repository/user.dart';
import 'package:qme/services/analytics.dart';
import 'package:qme/utilities/logger.dart';
import 'package:qme/views/home.dart';
import 'package:qme/views/otpPage.dart';
import 'package:qme/views/signin.dart';
import 'package:qme/widgets/button.dart';
import 'package:qme/widgets/formField.dart';
import 'package:qme/widgets/text.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpScreen extends StatefulWidget {
  static const id = '/signup';

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

String verificationIdOtp;
FirebaseAuth authOtp;
String loginPage;

class _SignUpScreenState extends State<SignUpScreen> {
  bool showSpinner = false, passwordVisible;
  final ScrollController _scrollController = ScrollController();
  final _phoneController = TextEditingController(text: "+91");
  bool checkedValue = false;
  final formKey = GlobalKey<FormState>();
  Map<String, String> formData = {};

  final _codeController = TextEditingController();
  String _fcmToken;
  Future<void> _launched;
  final FirebaseMessaging _messaging = FirebaseMessaging();
  String idToken;
  fcmTokenApiCall() async {
    Box box = await Hive.openBox("user");
    _fcmToken = await box.get('fcmToken');
    var responsefcm = await UserRepository().fcmTokenSubmit(_fcmToken);
    logger.d("fcm token Api: $responsefcm");
    await box.put('fcmToken', _fcmToken);
  }

  showAlert(BuildContext context, String content) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text("Verification Failed"),
            content: Text(content),
            actions: <Widget>[
              FlatButton(
                child: Text("OK"),
                textColor: Colors.white,
                color: Theme.of(context).primaryColor,
                onPressed: () async {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignInScreen(),
                    ),
                    (route) => false,
                  );
                },
              )
            ],
          );
        });
  }

  // otp verification with firebase
  Future<bool> loginUser(String phone, BuildContext context) async {
    FirebaseAuth _auth = FirebaseAuth.instance;

    _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: Duration(seconds: 60),
        verificationCompleted: (AuthCredential credential) async {
          UserCredential result = await _auth.signInWithCredential(credential);

          FirebaseUser user = result.user;

          if (user != null) {
            var token = await user.getIdToken().then((result) {
              idToken = result;
              formData['token'] = idToken;
              logger.d(" $idToken ");
            });
            final code = _codeController.text.trim();
            try {
              Box box = await Hive.openBox("user");
              formData['firstName'] =
                  await box.get('userFirstNameSignup').toString().trim();
              formData['lastName'] =
                  await box.get('userLastNameSignup').toString().trim();
              formData['phone'] = await box.get('userPhoneSignup');
              formData['password'] = await box.get('userPasswordSignup');
              formData['cpassword'] = await box.get('userCpasswordSignup');
              formData['email'] =
                  await box.get('userEmailSignup').toString().trim();

              UserRepository user = UserRepository();
              formData['name'] =
                  '${formData['firstName']} ${formData['lastName']}';
              log('$formData');
              // Make SignUp API call
              Map response;
              try {
                logger.d(formData);
                response = await user.signUp(formData);
              } on BadRequestException catch (e) {
                log('BadRequestException on SignUp:' + e.toString());
                showAlert(context, e.toMap()["msg"].toString());
              } catch (e) {
                showAlert(context, e.toMap()["msg"].toString());
              }
              log('SignUp response:${response.toString()}');

              if (response != null &&
                  response['msg'] == 'Registation successful') {
                AnalyticsService()
                    .getAnalyticsObserver()
                    .analytics
                    .logSignUp(signUpMethod: "Normal");
                // Make SignIn call
                try {
                  response = await UserRepository().signInWithOtp(idToken);
                  if (response['accessToken'] != null) {
                    logger.d("respose of ${response['status']}");
                    logger.d(response);
                    Navigator.pushNamedAndRemoveUntil(
                        context, HomeScreen.id, (route) => false);
                    fcmTokenApiCall();
                  } else {
                    return logger.d("error in api hit");
                  }
                } catch (e) {
                  showAlert(context, e.toMap()["msg"].toString());
                  log('Error in signIn API: ' + e.toString());
                  return;
                }
              } else {
                logger.d("SignUp failed");
                return;
              }
            } on PlatformException catch (e) {
              print("Looking for Error code");
              print(e.message);
              Navigator.of(context).pop();

              showAlert(context, e.code.toString());
              print(e.code);
            } on Exception catch (e) {
              Navigator.of(context).pop();

              showAlert(context, e.toString());
              print("Looking for Error message");
              print(e);
            }
          } else {
            print("Error");
          }

          //This callback would gets called when verification is done auto maticlly
        },
        verificationFailed: (FirebaseAuthException exception) {
          logger.e(exception.message);
          String fireBaseError = exception.message.toString();
          if (exception.message ==
                  "The format of the phone number provided is incorrect. Please enter the phone number in a format that can be parsed into E.164 format. E.164 phone numbers are written in the format [+][country code][subscriber number including area code]. [ TOO_LONG ]" ||
              exception.message ==
                  "The format of the phone number provided is incorrect. Please enter the phone number in a format that can be parsed into E.164 format. E.164 phone numbers are written in the format [+][country code][subscriber number including area code]. [ TOO_SHORT ]") {
            fireBaseError =
                "PPlease verify and enter correct 10 digit phone number with country code.";
          } else if (exception.message ==
              "We have blocked all requests from this device due to unusual activity. Try again later.") {
            fireBaseError =
                "You have tried maximum number of signup.please retry after some time.";
          }

          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  title: Text("Alert"),
                  content: Text(fireBaseError),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("OK"),
                      textColor: Colors.white,
                      color: Theme.of(context).primaryColor,
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignInScreen(),
                          ),
                          (route) => false,
                        );
                      },
                    )
                  ],
                );
              });
        },
        codeSent: (String verificationId, [int forceResendingToken]) {
          verificationIdOtp = verificationId;
          authOtp = _auth;
          loginPage = "SignUp";

          Navigator.of(context).pushNamed(OtpPage.id);
          //
        },
        codeAutoRetrievalTimeout: null);
  }

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    passwordVisible = false;
    super.initState();
    firebaseCloudMessagingListeners();

    _messaging.getToken().then((token) {
      print("fcmToken: $token");
      _fcmToken = token;
    });
  }

  void firebaseCloudMessagingListeners() {
    if (Platform.isIOS) iosPermission();

    _messaging.getToken().then((token) {
      print(token);
    });

    _messaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        //showNotification(message['notification']);
        print('on message $message');
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );
  }

  void iosPermission() {
    _messaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _messaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
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
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
                    child: Column(
                      children: <Widget>[
                        MyFormField(
                          required: true,
                          name: 'FIRST NAME*',
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
                              } else if (!value.startsWith("+91")) {
                                return 'Phone number must start with +91';
                              } else if (value.length != 13) {
                                return 'Phone number must be 10 digits after +91';
                              } else {
                                //setState(() {
                                formData['phone'] = value;
                                print(formData['phone']);
                                //  });
                              }
                              return null;
                            },
                            decoration: kTextFieldDecoration.copyWith(
                                labelText: "PHONE*"),
                          ),
                        ),
                        SizedBox(height: 10.0),
                        MyFormField(
                          keyboardType: TextInputType.emailAddress,
                          name: 'EMAIL',
                          required: false,
                          callback: (value) {
                            formData['email'] = value;
                            print(formData['email']);
                          },
                        ),
                        SizedBox(height: 10.0),
                        TextFormField(
                          // Password
                          //autofocus: true,
                          obscureText: !passwordVisible,
                          validator: (value) {
                            Pattern pattern =
                                r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])';
                            RegExp regex = new RegExp(pattern);
                            if (value.length < 6 || value.length > 20)
                              return 'Password should be not be less than 6 characters';
                            else if (!regex.hasMatch(value)) {
                              return 'Password must contain one numeric ,one upper and one lower\ncase letter.';
                            } else {
                              formData['password'] = value;
                              return null;
                            }
                          },
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.bold,
                          ),
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
                          // autofocus: true,
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.bold,
                          ),
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
                                borderSide: BorderSide(color: Colors.green)),
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
                        Provider.value(
                          value: checkedValue,
                          child: CheckboxListTileFormField(
                            title: FlatButton(
                              color: Colors.transparent,
                              onPressed: () => setState(() {
                                _launched = _launchInBrowser(
                                    "https://q-me.flycricket.io/privacy.html");
                              }),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'I agree to Privacy Policy',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            onSaved: (newValue) {
                              bool checkedValue = Provider.of<bool>(context);
                              checkedValue = newValue;
                              logger.d('Checked $checkedValue');
                            },
                            validator: (bool value) {
                              if (value) {
                                return null;
                              } else {
                                return 'In order to proceed you have to agree';
                              }
                            },
                          ),
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
                                          content:
                                              Text('Passwords do not match')),
                                    );
                                    return null;
                                  }

                                  Scaffold.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Processing Data'),
                                    ),
                                  );
                                  final phone = _phoneController.text.trim();
                                  print("phone number: $phone");
                                  print(formData);
                                  Box box = await Hive.openBox("user");

                                  await box.put('userFirstNameSignup',
                                      formData['firstName']);
                                  await box.put('userLastNameSignup',
                                      formData['lastName']);
                                  await box.put(
                                      'userPhoneSignup', formData['phone']);

                                  await box.put('userPasswordSignup',
                                      formData['password']);
                                  await box.put('userCpasswordSignup',
                                      formData['cpassword']);

                                  await box.put(
                                      'userEmailSignup', formData['email']);

                                  await box.put('fcmToken', _fcmToken);
                                  showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text("Alert!"),
                                          content: Text(
                                              "You might receive an SMS message for verification and standard rates apply."),
                                          actions: <Widget>[
                                            DisagreeButton(),
                                            FlatButton(
                                              child: Text("Agree"),
                                              textColor: Colors.white,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              onPressed: () async {
                                                Navigator.of(context)
                                                    .pushNamed(OtpPage.id);
                                                loginUser(phone, context);
                                              },
                                            ),
                                          ],
                                        );
                                      });
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
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      )),
    );
  }
}

class DisagreeButton extends StatelessWidget {
  const DisagreeButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Text("Disagree"),
      textColor: Colors.white,
      color: Theme.of(context).primaryColor,
      onPressed: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => SignInScreen()),
          (route) => false,
        );
      },
    );
  }
}
