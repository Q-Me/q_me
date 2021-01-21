import 'dart:io';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:qme/api/app_exceptions.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:qme/constants.dart';
import 'package:qme/model/user.dart';
import 'package:qme/repository/user.dart';
import 'package:qme/services/firebase_auth_service.dart';
import 'package:qme/utilities/logger.dart';
import 'package:qme/views/home.dart';
import 'package:qme/views/otpPage.dart';
import 'package:qme/views/signup.dart';
import 'package:qme/widgets/text.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SignInScreen extends StatefulWidget {
  static const id = '/signin';
  @override
  _SignInScreenState createState() => new _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with TickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  TabController _controller;
  String idToken;
  String countryCodeVal;
  String countryCodePassword;
  final FirebaseMessaging _messaging = FirebaseMessaging();
  final formKey =
      GlobalKey<FormState>(); // Used in login button and forget password
  String email;
  String password;
  String phoneNumber;
  String _fcmToken;
  bool passwordHidden = true;
  BuildContext scaffoldContext;

  double get mediaHeight => MediaQuery.of(context).size.height;
  double get mediaWidth => MediaQuery.of(context).size.width;

  // Future<bool> loginUser(BuildContext context, String phone) async {
  //   FirebaseAuth _auth = FirebaseAuth.instance;

  //   _auth.verifyPhoneNumber(
  //       phoneNumber: phone,
  //       timeout: Duration(seconds: 60),
  //       verificationCompleted: (AuthCredential credential) async {
  //         UserCredential result = await _auth.signInWithCredential(credential);
  //         logger.d("printing the credential");
  //         logger.d(credential);

  //         FirebaseUser user = result.user;

  //         if (user != null) {
  //           var token = await user.getIdToken().then((result) async {
  //             idToken = result;
  //             logger.d("idToken: $idToken ");
  //             FocusScope.of(context).requestFocus(FocusNode());

  //             var response;
  //             try {
  //               // Box box = await hive.openbox("user");
  //               await box.put('fcmToken', _fcmToken);
  //               response =
  //                   // Make LOGIN API call
  //                   response = await UserRepository().signInWithOtp(idToken);

  //               if (response['accessToken'] != null) {
  //                 Navigator.pushNamedAndRemoveUntil(
  //                     context, HomeScreen.id, (route) => false);
  //                 var responsefcm =
  //                     await UserRepository().fcmTokenSubmit(_fcmToken);
  //                 logger.d("fcm token Api: $responsefcm");
  //               } else {
  //                 return;
  //               }
  //             } catch (e) {
  //               logger.d(" !!${e.toMap()["msg"].toString()}!!");
  //               final errorMessage = e.toMap()["msg"].toString();
  //               showDialog(
  //                   context: context,
  //                   barrierDismissible: false,
  //                   builder: (context) {
  //                     return AlertDialog(
  //                       title: Text("SignIn Failed!"),
  //                       content: Text(errorMessage),
  //                       actions: <Widget>[
  //                         FlatButton(
  //                           child: Text("OK"),
  //                           textColor: Colors.white,
  //                           color: Theme.of(context).primaryColor,
  //                           onPressed: () {
  //                             Navigator.pushAndRemoveUntil(
  //                               context,
  //                               MaterialPageRoute(
  //                                 builder: (context) => SignInScreen(),
  //                               ),
  //                               (route) => false,
  //                             );
  //                           },
  //                         )
  //                       ],
  //                     );
  //                   });
  //               logger.d('Error in signIn API: ' + e.toString());
  //               return;
  //             }
  //           });
  //         } else {
  //           logger.d("Error");
  //         }
  //       },
  //       verificationFailed: (FirebaseAuthException exception) {
  //         logger.d("here is exception error");
  //         logger.d(exception.message);
  //         String fireBaseError = exception.message.toString();
  //         if (exception.message ==
  //                 "The format of the phone number provided is incorrect. Please enter the phone number in a format that can be parsed into E.164 format. E.164 phone numbers are written in the format [+][country code][subscriber number including area code]. [ TOO_LONG ]" ||
  //             exception.message ==
  //                 "The format of the phone number provided is incorrect. Please enter the phone number in a format that can be parsed into E.164 format. E.164 phone numbers are written in the format [+][country code][subscriber number including area code]. [ TOO_SHORT ]") {
  //           fireBaseError =
  //               "Please verify and enter correct 10 digit phone number with country code.";
  //         } else if (exception.message ==
  //             "We have blocked all requests from this device due to unusual activity. Try again later.") {
  //           fireBaseError =
  //               "You have tried maximum number of signin.please retry after some time.";
  //         }

  //         showDialog(
  //             context: context,
  //             barrierDismissible: false,
  //             builder: (context) {
  //               return AlertDialog(
  //                 title: Text("Alert"),
  //                 content: Text(fireBaseError),
  //                 actions: <Widget>[
  //                   FlatButton(
  //                     child: Text("OK"),
  //                     textColor: Colors.white,
  //                     color: Theme.of(context).primaryColor,
  //                     onPressed: () {
  //                       Navigator.pushAndRemoveUntil(
  //                         context,
  //                         MaterialPageRoute(
  //                           builder: (context) => SignInScreen(),
  //                         ),
  //                         (route) => false,
  //                       );
  //                     },
  //                   )
  //                 ],
  //               );
  //             });
  //       },
  //       codeSent: (String verificationId, [int forceResendingToken]) async {
  //         // _authVar = _auth;
  //         // verificationIdVar = verificationId;
  //         verificationIdOtp = verificationId;
  //         authOtp = _auth;
  //         loginPage = "SignIn";
  //         // Box box = await hive.openbox("user");

  //         await box.put('fcmToken', _fcmToken);
  //       },
  //       codeAutoRetrievalTimeout: null);
  // }

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
          builder: (context) {
            scaffoldContext = context;
            return SingleChildScrollView(
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
                                          keyboardType: TextInputType.phone,
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
                                      SizedBox(height: mediaHeight * 0.05),
                                      Container(
                                        height: mediaHeight * 0.06,
                                        child: Material(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                          color: Theme.of(context).primaryColor,
                                          elevation: 7.0,
                                          child: InkWell(
                                            onTap: () async {
                                              if (formKey.currentState
                                                  .validate()) {
                                                FocusScope.of(context).requestFocus(
                                                    FocusNode()); // dismiss the keyboard
                                                Scaffold.of(context)
                                                    .showSnackBar(SnackBar(
                                                        content: Text(
                                                            'Processing Data')));
                                                final phone = _phoneController
                                                    .text
                                                    .trim();
                                                logger
                                                    .d("phone number: $phone");
                                                UserData user = context.read();
                                                user.phone =
                                                    countryCodeVal.toString() +
                                                        phone.toString();
                                                updateUserData(user);
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
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                        ),
                                                        FlatButton(
                                                          child: Text("Agree"),
                                                          textColor:
                                                              Colors.white,
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          onPressed: () {
                                                            BuildContext
                                                                dialogContext;
                                                            Navigator.pop(
                                                              context,
                                                            );
                                                            showDialog(
                                                              context:
                                                                  scaffoldContext,
                                                              builder:
                                                                  (context) {
                                                                dialogContext =
                                                                    context;
                                                                return AlertDialog(
                                                                  title: Text(
                                                                      "Attempting automatic OTP resolution"),
                                                                  content:
                                                                      Center(
                                                                    child:
                                                                        CircularProgressIndicator(),
                                                                  ),
                                                                );
                                                              },
                                                            );
                                                            FirebaseAuthService()
                                                                .phoneNumberAuth(
                                                              phoneNumber:
                                                                  user.phone,
                                                              context:
                                                                  scaffoldContext,
                                                              isLogin: true,
                                                              dialogContext:
                                                                  dialogContext,
                                                            );
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
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
                                          // controller: _phoneController,
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              return 'This field cannot be left blank';
                                            } else {
                                              phoneNumber =
                                                  countryCodePassword + value;
                                              return null;
                                            }
                                          },
                                        ),
                                      ),
                                      SizedBox(height: mediaHeight * 0.02),
                                      ListTile(
                                        title: TextFormField(
                                          obscureText: passwordHidden,
                                          decoration: InputDecoration(
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(8),
                                              ),
                                              borderSide: BorderSide(
                                                color: Colors.grey[200],
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(8),
                                              ),
                                              borderSide: BorderSide(
                                                color: Colors.grey[300],
                                              ),
                                            ),
                                            filled: true,
                                            fillColor: Colors.grey[100],
                                            hintText: "Password",
                                            suffixIcon: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  passwordHidden =
                                                      !passwordHidden;
                                                });
                                              },
                                              child: passwordHidden
                                                  ? Icon(Icons.visibility_off)
                                                  : Icon(Icons.visibility),
                                            ),
                                          ),
                                          style: GoogleFonts.roboto(
                                            fontWeight: FontWeight.bold,
                                          ),
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
                                                Scaffold.of(context)
                                                    .showSnackBar(SnackBar(
                                                        content: Text(
                                                            'Processing Data')));

                                                // email and password both are available here
                                                logger.d(
                                                    "phoneNumber : $phoneNumber and password: $password");
                                                UserData user;
                                                // try {
                                                user = await UserRepository()
                                                    .signInWithPassword(
                                                  phoneNumber,
                                                  password,
                                                );
                                                // } on BadRequestException catch (_) {
                                                //   Scaffold.of(context)
                                                //       .showSnackBar(
                                                //     SnackBar(
                                                //       content: Text(
                                                //           "Invalid Credentials"),
                                                //     ),
                                                //   );
                                                //   return;
                                                // } catch (e) {
                                                //   logger.e(e.toString());
                                                //   Scaffold.of(context)
                                                //       .showSnackBar(
                                                //     SnackBar(
                                                //       content: Text(
                                                //         e.toString(),
                                                //       ),
                                                //     ),
                                                //   );
                                                //   return;
                                                // }
                                                // Login Success
                                                user.fcmToken = _fcmToken;
                                                updateUserData(user);
                                                // register the fcm token
                                                try {
                                                  await UserRepository()
                                                      .fcmTokenSubmit(
                                                    _fcmToken,
                                                  );
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
                                                // FCM token success

                                                Navigator
                                                    .pushNamedAndRemoveUntil(
                                                        context,
                                                        HomeScreen.id,
                                                        (route) => false);
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
            );
          },
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
