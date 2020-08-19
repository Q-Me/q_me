//import 'dart:html';
import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:qme/api/app_exceptions.dart';
import 'package:qme/constants.dart';
import 'package:qme/repository/user.dart';
import 'package:qme/utilities/logger.dart';
import 'package:qme/views/home.dart';
import 'package:qme/views/otpPage.dart';
import 'package:qme/views/signup.dart';
import 'package:qme/widgets/text.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInScreen extends StatefulWidget {
  static const id = '/signin';
  @override
  _SignInScreenState createState() => new _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with TickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _codeController = TextEditingController();
  TabController _controller;
  var idToken;
  var verificationIdVar;
  var _authVar;
  String countryCodeVal;
  String countryCodePassword;
  bool showOtpTextfield = false;
  final FirebaseMessaging _messaging = FirebaseMessaging();
  final formKey =
      GlobalKey<FormState>(); // Used in login button and forget password
  String email;
  String password;
  String phoneNumber;
  String _fcmToken;

  double get mediaHeight => MediaQuery.of(context).size.height;
  double get mediaWidth => MediaQuery.of(context).size.width;

  Future<bool> loginUser(String phone, BuildContext context) async {
    FirebaseAuth _auth = FirebaseAuth.instance;

    _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: Duration(seconds: 60),
        /*
         verificationCompleted: (AuthCredential credential) async {
           AuthResult result = await _auth.signInWithCredential(credential);
           logger.d("printing the credential");
           logger.d(credential);

           FirebaseUser user = result.user;

           if (user != null) {
             var token = await user.getIdToken().then((result) async {
               idToken = result.token;
               logger.d("idToken: $idToken ");
               FocusScope.of(context)
                   .requestFocus(FocusNode()); // dismiss the keyboard
               Scaffold.of(context)
                   .showSnackBar(SnackBar(content: Text('Processing Data')));
               var response;
               try {
                 SharedPreferences prefs = await SharedPreferences.getInstance();
                 prefs.setString('fcmToken', _fcmToken);
                 response =
                     // Make LOGIN API call
                     response = await signInWithOtp(idToken);

                 if (response['status'] == 200) {
                   Scaffold.of(context)
                       .showSnackBar(SnackBar(content: Text('Processing Data')));
                   Navigator.pushNamed(context, NearbyScreen.id);
                    prefs.setString('fcmToken',_fcmToken );

                   var responsefcm = await fcmTokenSubmit(_fcmToken);
                   logger.d("fcm token Api: $responsefcm");
                   logger.d("fcm token  Apiresponse: ${responsefcm['status']}");
                 } else {
                   return;
                 }
               } catch (e) {
                 logger.d(" !!$e !!");
                 Scaffold.of(context)
                     .showSnackBar(SnackBar(content: Text(e.toString())));
                 // _showSnackBar(e.toString());
                 log('Error in signIn API: ' + e.toString());
                 return;
               }
             });
           } else {
             logger.d("Error");
           }

           //This callback would gets called when verification is done auto maticlly
         },
        */
        verificationFailed: (AuthException exception) {
          logger.d("here is exception error");
          logger.d(exception.message);
          Scaffold.of(context).showSnackBar(SnackBar(
              content: Text("Phone number verification failed\n" +
                  exception.message.toString())));
        },
        codeSent: (String verificationId, [int forceResendingToken]) async {
          // _authVar = _auth;
          // verificationIdVar = verificationId;
          verificationIdOtp = verificationId;
          authOtp = _auth;
          loginPage = "SignIn";
          SharedPreferences prefs = await SharedPreferences.getInstance();

          prefs.setString('fcmToken', _fcmToken);

          setState(() {
            showOtpTextfield = true;
          });
        },
        codeAutoRetrievalTimeout: null);
  }

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 2, vsync: this);
    firebaseCloudMessagingListeners();
    _messaging.getToken().then((token) {
      logger.d("fcmToken: $token");
      _fcmToken = token;
    });
  }

  void firebaseCloudMessagingListeners() {
    if (Platform.isIOS) iosPermission();

    _messaging.getToken().then((token) {
      logger.d("FCM TOKEN: \n$token");
    });

    _messaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        //showNotification(message['notification']);
        logger.d('on message $message');
      },
      onResume: (Map<String, dynamic> message) async {
        logger.d('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        logger.d('on launch $message');
      },
    );
  }

  void iosPermission() {
    _messaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _messaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      logger.d("Settings registered: $settings");
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomPadding: true,
        body: Builder(
          builder: (context) => SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  child: ThemedText(words: ['Hello', 'There']),
                ),
                Container(
                    padding:
                        EdgeInsets.only(top: 40.0, left: 20.0, right: 20.0),
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: <Widget>[
                          SizedBox(height: 20.0),
                          LoginTabBar(controller: _controller),
                          Container(
                            height: mediaHeight * 0.42,
                            child: TabBarView(
                              controller: _controller,
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    SizedBox(height: mediaHeight * 0.02),
                                    ListTile(
                                      leading: CountryCodePicker(
                                        onChanged: print,
                                        initialSelection: 'In',
                                        hideSearch: false,
                                        showCountryOnly: false,
                                        showOnlyCountryWhenClosed: false,
                                        builder: (countryCode) {
                                          var countryCodes = countryCode;
                                          countryCodeVal =
                                              countryCodes.toString();
                                          return Container(
                                              alignment: Alignment.center,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.15,
                                              // height: 0.085,
                                              decoration: BoxDecoration(
                                                  color: Colors.grey[200],
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Text(
                                                '$countryCode',
                                                style: TextStyle(
                                                    color: Colors.black),
                                              ));
                                        },
                                      ),
                                      title: TextFormField(
                                        decoration: InputDecoration(
                                            enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(8)),
                                                borderSide: BorderSide(
                                                    color: Colors.grey[200])),
                                            focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(8)),
                                                borderSide: BorderSide(
                                                    color: Colors.grey[300])),
                                            filled: true,
                                            fillColor: Colors.grey[100],
                                            hintText: "Mobile Number"),
                                        controller: _phoneController,
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return 'This field cannot be left blank';
                                          } else {
                                            setState(() {
                                              phoneNumber =
                                                  countryCodeVal + value;
                                            });
                                            return null;
                                          }
                                        },
                                      ),
                                    ),
                                    SizedBox(height: mediaHeight * 0.02),
                                    /*
                                     showOtpTextfield
                                         ? Card(
                                             child: new ListTile(
                                               title: TextFormField(
                                                 decoration: InputDecoration(
                                                     enabledBorder: OutlineInputBorder(
                                                         borderRadius:
                                                             BorderRadius.all(
                                                                 Radius.circular(
                                                                     8)),
                                                         borderSide: BorderSide(
                                                             color: Colors
                                                                 .grey[200])),
                                                     focusedBorder: OutlineInputBorder(
                                                         borderRadius:
                                                             BorderRadius.all(
                                                                 Radius.circular(
                                                                     8)),
                                                         borderSide: BorderSide(
                                                             color: Colors.grey[300])),
                                                     filled: true,
                                                     fillColor: Colors.grey[100],
                                                     hintText: "Enter OTP"),
                                                 controller: _codeController,
                                               ),
                                             ),
                                           )
                                         : Container(),
                                     !showOtpTextfield
                                         ? RaisedButton(
                                             color:
                                                 Theme.of(context).primaryColor,
                                             onPressed: () {
                                               final phone =
                                                   _phoneController.text.trim();
                                               logger.d("phone number: $phone");
                                               loginUser(countryCodeVal + phone,
                                                   context);
                                             },
                                             child: const Text(
                                               'GET OTP',
                                               style: const TextStyle(
                                                   color: Colors.white),
                                             ),
                                           )
                                         : Container(),
                                    */
                                    SizedBox(height: mediaHeight * 0.05),
                                    Container(
                                      height: mediaHeight * 0.06,
                                      child: Material(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        // shadowColor: Colors.greenAccent,
                                        color: Theme.of(context).primaryColor,
                                        elevation: 7.0,
                                        child: InkWell(
                                          onTap: () async {
                                            if (formKey.currentState
                                                .validate()) {
                                              FocusScope.of(context).requestFocus(
                                                  FocusNode()); // dismiss the keyboard
                                              Scaffold.of(context).showSnackBar(
                                                  SnackBar(
                                                      content: Text(
                                                          'Processing Data')));
                                              final phone =
                                                  _phoneController.text.trim();
                                              logger.d("phone number: $phone");
                                              showDialog(
                                                  context: context,
                                                  barrierDismissible: false,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      title: Text("Alert!"),
                                                      content: Text(
                                                          "You might receive an SMS message for verification and standard rates apply."),
                                                      actions: <Widget>[
                                                        FlatButton(
                                                          child:
                                                              Text("Disagree"),
                                                          textColor:
                                                              Colors.white,
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          onPressed: () {
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
                                                        ),
                                                        FlatButton(
                                                          child: Text("Agree"),
                                                          textColor:
                                                              Colors.white,
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          onPressed: () async {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            loginUser(
                                                                countryCodeVal +
                                                                    phone,
                                                                context);

                                                            Navigator.pushNamed(
                                                                context,
                                                                OtpPage.id);
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  });
/*
                                               final code =
                                                   _codeController.text.trim();
                                               try {
                                                 AuthCredential credential =
                                                     PhoneAuthProvider
                                                         .getCredential(
                                                             verificationId:
                                                                 verificationIdVar,
                                                             smsCode: code);

                                                 AuthResult result =
                                                     await _authVar
                                                         .signInWithCredential(
                                                             credential);

                                                 FirebaseUser user = result.user;

                                                 if (user != null) {
                                                   var token = await user
                                                       .getIdToken()
                                                       .then((result) {
                                                     idToken = result.token;
                                                     logger.d("@@ $idToken @@");
                                                   });
                                                 } else {
                                                   logger.d("Error");
                                                 }
                                               } on PlatformException catch (e) {
                                                 logger.d("Looking for Error code");
                                                 logger.d(e.message);
                                                 Scaffold.of(context)
                                                     .showSnackBar(SnackBar(
                                                         content: Text(e.code
                                                             .toString())));
                                                 logger.d(e.code);
                                                 setState(() {
                                                   showOtpTextfield = false;
                                                 });
                                               } on Exception catch (e) {
                                                 logger.d(
                                                     "Looking for Error message");
                                                 Scaffold.of(context)
                                                     .showSnackBar(SnackBar(
                                                         content: Text(
                                                             e.toString())));
                                                 setState(() {
                                                   showOtpTextfield = false;
                                                 });
                                                 logger.d(e);
                                               }

                                               // email and password both are available here
                                               Map response;
                                               try {
                                                 response =
                                                     // Make LOGIN API call
                                                     response =
                                                         await signInWithOtp(
                                                             idToken);

                                                 if (response['status'] == 200) {
                                                   logger.d(
                                                       "respose of ${response['status']}");
                                                   logger.d(response);
                                                   Scaffold.of(context)
                                                       .showSnackBar(SnackBar(
                                                           content: Text(
                                                               'Processing Data')));
                                                   SharedPreferences prefs =
                                                       await SharedPreferences
                                                           .getInstance();

                                                   var responsefcm =
                                                       await fcmTokenSubmit(
                                                           _fcmToken);
                                                   logger.d(
                                                       "fcm token Api: $responsefcm");
                                                   logger.d(
                                                       "fcm token Api status: ${responsefcm['status']}");
                                                   prefs.setString(
                                                       'fcmToken', _fcmToken);
                                                   Navigator.pushNamed(
                                                       context, NearbyScreen.id);
                                                 } else {
                                                   logger.d(response['status']);
                                                   logger.d(response);
                                                   Scaffold.of(context)
                                                       .showSnackBar(SnackBar(
                                                           content: Text(response[
                                                                       'status']
                                                                   .toString() +
                                                               " " +
                                                               response['error']
                                                                   .toString())));
                                                   return logger.d(
                                                       "error in api hit");
                                                 }
                                               } catch (e) {
                                                 Scaffold.of(context)
                                                     .showSnackBar(SnackBar(
                                                         content: Text(
                                                             e.toString())));
                                                 // _showSnackBar(e.toString());
                                                 log('Error in signIn API: ' +
                                                     e.toString());
                                                 return;
                                               }
                                              */
                                            }
                                          },
                                          child: Center(
                                            child: Text(
                                              'Login with OTP',
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
                                  ],
                                ),
                                Column(
                                  children: <Widget>[
                                    SizedBox(height: mediaHeight * 0.02),
                                    ListTile(
                                      leading: CountryCodePicker(
                                        onChanged: print,
                                        initialSelection: 'In',
                                        hideSearch: false,
                                        showCountryOnly: false,
                                        showOnlyCountryWhenClosed: false,
                                        builder: (countryCode) {
                                          var countryCodes = countryCode;
                                          countryCodePassword =
                                              countryCodes.toString();
                                          return Container(
                                              alignment: Alignment.center,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.15,
                                              // height: 0.085,
                                              decoration: BoxDecoration(
                                                  color: Colors.grey[200],
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Text(
                                                '$countryCode',
                                                style: TextStyle(
                                                    color: Colors.black),
                                              ));
                                        },
                                      ),
                                      title: TextFormField(
                                        decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8)),
                                              borderSide: BorderSide(
                                                  color: Colors.grey[200])),
                                          focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8)),
                                              borderSide: BorderSide(
                                                  color: Colors.grey[300])),
                                          filled: true,
                                          fillColor: Colors.grey[100],
                                          hintText: "Mobile Number",
                                        ),
                                        keyboardType: TextInputType.number,
                                        controller: _phoneController,
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return 'This field cannot be left blank';
                                          } else {
                                            setState(() {
                                              phoneNumber =
                                                  countryCodePassword + value;
                                            });
                                            return null;
                                          }
                                        },
                                      ),
                                    ),
                                    SizedBox(height: mediaHeight * 0.02),
                                    ListTile(
                                      title: TextFormField(
                                        obscureText: true,
                                        decoration: InputDecoration(
                                            enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(8)),
                                                borderSide: BorderSide(
                                                    color: Colors.grey[200])),
                                            focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(8)),
                                                borderSide: BorderSide(
                                                    color: Colors.grey[300])),
                                            filled: true,
                                            fillColor: Colors.grey[100],
                                            hintText: "Password"),
                                        controller: _passwordController,
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return 'This field cannot be left blank';
                                          } else {
                                            password = value;
                                            return null;
                                          }
                                        },
                                      ),
                                    ),
                                    SizedBox(height: mediaHeight * 0.05),
                                    Container(
                                      height: mediaHeight * 0.06,
                                      child: Material(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        shadowColor: Colors.blueAccent,
                                        color: Theme.of(context).primaryColor,
                                        elevation: 7.0,
                                        child: InkWell(
                                          onTap: () async {
                                            if (formKey.currentState
                                                .validate()) {
                                              FocusScope.of(context).requestFocus(
                                                  FocusNode()); // dismiss the keyboard
                                              Scaffold.of(context).showSnackBar(
                                                  SnackBar(
                                                      content: Text(
                                                          'Processing Data')));

                                              // email and password both are available here
                                              logger.d(
                                                  "phoneNumber : $phoneNumber and password: $password");
                                              try {
                                                final response =
                                                    await UserRepository()
                                                        .signInWithPassword(
                                                  phoneNumber,
                                                  password,
                                                );
                                              } on BadRequestException catch (e) {
                                                Scaffold.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        "Invalid Credentials"),
                                                  ),
                                                );
                                                return;
                                              } catch (e) {
                                                logger.e(e.toString());
                                                Scaffold.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        'Something unexpected happened'),
                                                  ),
                                                );
                                                return;
                                              }
                                              // Login Success

                                              // register the fcm token
                                              try {
                                                final responseFcm =
                                                    await UserRepository()
                                                        .fcmTokenSubmit(
                                                  _fcmToken,
                                                );
                                              } on Exception catch (e) {
                                                logger.e(e.toString());
                                                Scaffold.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        'Something unexpected happened'),
                                                  ),
                                                );
                                                return;
                                              }
                                              // FCM token success

                                              Navigator.pushNamed(
                                                context,
                                                HomeScreen.id,
                                              );
                                            }
                                          },
                                          child: Center(
                                            child: Text(
                                              'Login with password ',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'Montserrat',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
                SizedBox(height: 15.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'New to Q Me?',
                      style: TextStyle(fontFamily: 'Montserrat'),
                    ),
                    SizedBox(width: 5.0),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pushNamed(SignUpScreen.id);
                        logger.d('Register button pressed');
                      },
                      child: Text(
                        'Register',
                        style: kLinkTextStyle,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoginTabBar extends StatelessWidget {
  const LoginTabBar({
    Key key,
    @required TabController controller,
  })  : _controller = controller,
        super(key: key);

  final TabController _controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: new BoxDecoration(color: Theme.of(context).primaryColor),
      child: new TabBar(
        controller: _controller,
        indicatorColor: Colors.transparent,
        tabs: [
          Tab(
            icon: const Icon(Icons.message),
            text: '  OTP   ',
          ),
          Tab(
            icon: const Icon(Icons.visibility_off),
            text: 'Password',
          ),
        ],
      ),
    );
  }
}
