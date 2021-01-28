import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:qme/model/api_params/signup.dart';
import 'package:qme/model/user.dart';
import 'package:qme/utilities/logger.dart';
import 'package:qme/views/home.dart';
import 'package:qme/services/firebase_auth_service.dart';
import 'package:qme/views/signin.dart';
import 'package:qme/widgets/button.dart';
import '../api/app_exceptions.dart';
import '../repository/user.dart';
import 'signup.dart';

class OtpPageArguments {
  String verificationId;
  bool isLogin;
  FirebaseErrorNotifier errorNotif;

  OtpPageArguments({this.isLogin, this.verificationId, this.errorNotif});
}

class OtpPage extends StatefulWidget {
  static const id = '/otpPage';
  final OtpPageArguments args;

  OtpPage({@required this.args});

  @override
  _OtpPageState createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  Map<String, String> formData = {};
  String idToken;
  final formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  var _fcmToken;
  String mobileNumber = "Mobile number";
  // fcmTokenApiCall() async {
  //   // Box box = await hive.openbox("user");
  //   _fcmToken = await box.get('fcmToken');
  //   var responsefcm = await UserRepository().fcmTokenSubmit(_fcmToken);
  //   print("fcm token Api: $responsefcm");
  //   // print("fcm token Api status: ${responsefcm['status']}");
  //   await box.put('fcmToken', _fcmToken);
  //   print(_fcmToken);
  // }

  // signInUser(BuildContext context) async {
  //   Map response;
  //   try {
  //     response = await UserRepository().signInWithOtp(idToken);

  //     if (response['accessToken'] != null) {
  //       logger.d(response);
  //       Navigator.pushNamedAndRemoveUntil(
  //           context, HomeScreen.id, (route) => false);

  //       fcmTokenApiCall();
  //     } else {
  //       logger.d("response of signin Otp: $response");
  //       Scaffold.of(context)
  //           .showSnackBar(SnackBar(content: Text(response['eror'].toString())));
  //       return logger.d("error in api hit");
  //     }
  //   } catch (e) {
  //     final errorMessage = e.toMap()["msg"].toString();
  //     Scaffold.of(context).showSnackBar(SnackBar(
  //       content: Text(errorMessage),
  //       action: SnackBarAction(
  //         label: 'Dismiss',
  //         onPressed: () {
  //           Navigator.pushNamedAndRemoveUntil(
  //               context, SignInScreen.id, (route) => false);
  //         },
  //       ),
  //     ));
  //     log('Error in signIn API: ' + e.toString());
  //     return;
  //   }
  // }

  // signUpUser(BuildContext context) async {
  //   // Box box = await hive.openbox("user");
  //   formData['firstName'] = await box.get('userFirstNameSignup');
  //   formData['lastName'] = await box.get('userLastNameSignup');
  //   formData['phone'] = await box.get('userPhoneSignup');
  //   formData['password'] = await box.get('userPasswordSignup');
  //   formData['cpassword'] = await box.get('userCpasswordSignup');
  //   formData['email'] = await box.get('userEmailSignup');

  //   log('$formData');

  //   UserRepository user = UserRepository();
  //   formData['name'] = '${formData['firstName']} ${formData['lastName']}';
  //   // Make SignUp API call
  //   Map response;
  //   try {
  //     logger.d(formData);
  //     response = await user.signUp(formData);
  //   } on BadRequestException catch (e) {
  //     log('BadRequestException on SignUp:' + e.toString());
  //     Scaffold.of(context).showSnackBar(SnackBar(
  //       content: Text(
  //         e.toMap()["msg"].toString(),
  //       ),
  //     ));
  //   } catch (e) {
  //     logger.e(e.toMap()['error']);
  //     Scaffold.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(e.toString()),
  //       ),
  //     );
  //   }
  //   log('SignUp response:${response.toString()}');

  //   if (response != null && response['msg'] == 'Registation successful') {
  //     // Make SignIn call
  //     try {
  //       response = await UserRepository().signInWithOtp(idToken);

  //       if (response['accessToken'] != null) {
  //         Navigator.pushNamedAndRemoveUntil(
  //             context, HomeScreen.id, (route) => false);
  //         fcmTokenApiCall();
  //       } else {
  //         logger.d("response of signin Otp: $response");
  //         Scaffold.of(context).showSnackBar(
  //             SnackBar(content: Text(response['error'].toString())));
  //         return logger.d("error in api hit");
  //       }
  //     } catch (e) {
  //       Scaffold.of(context)
  //           .showSnackBar(SnackBar(content: Text(e.toString())));
  //       log('Error in signIn API: ' + e.toString());
  //       return;
  //     }
  //   } else {
  //     logger.d("SignUp failed");
  //     //Navigator.pushNamed(context, SignInScreen.id);
  //     return;
  //   }
  // }

  fetchPhoneNumber() async {
    // Box box = await hive.openbox("user");
    setState(() {
      mobileNumber = Provider.of<UserData>(context).phone;
    });
  }

  @override
  void initState() {
    fetchPhoneNumber();
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
                            backgroundColor: Colors.blue,
                            radius: 80.0,
                            child: Padding(
                              padding: const EdgeInsets.all(1.5),
                              child: SvgPicture.asset("assets/temp/otpSvg.svg"),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: MediaQuery.of(context).size.height * 0.15),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Enter OTP sent to: "),
                            Text(
                              "$mobileNumber",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.05,
                        ),
                        PinCodeTextField(
                          appContext: context,
                          pastedTextStyle: TextStyle(
                            color: Colors.green.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                          length: 6,
                          obscureText: false,
                          animationType: AnimationType.fade,
                          validator: (v) {
                            if (v.length != 6) {
                              return "Please enter valid OTP";
                            } else {
                              return null;
                            }
                          },
                          pinTheme: PinTheme(
                              inactiveFillColor: Colors.white,
                              activeFillColor: Colors.white,
                              inactiveColor: Theme.of(context).primaryColor,
                              activeColor: Theme.of(context).primaryColor),
                          animationDuration: Duration(milliseconds: 300),
                          enableActiveFill: true,
                          onCompleted: (pin) {
                            _codeController.text = pin;
                          },
                          // onTap: () {
                          //   print("Pressed");
                          // },
                          onChanged: (pin) {
                            setState(() {
                              _codeController.text = pin;
                            });
                          },
                          beforeTextPaste: (text) {
                            print("Allowing to paste $text");
                            return true;
                          },
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
                              onTap: () {
                                authenticateUsingOtp(context);
                              },
                              // onTap: () async {
                              //   final code = _codeController.text.trim();
                              //   try {
                              //     Scaffold.of(context).showSnackBar(SnackBar(
                              //         content: Text('Processing Data')));
                              //     AuthCredential credential =
                              //         PhoneAuthProvider.getCredential(
                              //             verificationId: verificationIdOtp,
                              //             smsCode: code);

                              //     // Box box = await hive.openbox("user");

                              //     _fcmToken = await box.get('fcmToken');

                              //     UserCredential result = await authOtp
                              //         .signInWithCredential(credential);

                              //     FirebaseUser userFireBAse = result.user;

                              //     if (userFireBAse != null) {
                              //       Scaffold.of(context).showSnackBar(SnackBar(
                              //           content: Text('Processing Data')));
                              //       var token = await userFireBAse
                              //           .getIdToken()
                              //           .then((result) {
                              //         idToken = result;
                              //         formData['token'] = idToken;
                              //         logger.d("@@ $idToken @@");
                              //       });
                              //       logger.d(token);
                              //       if (loginPage == "SignUp") {
                              //         signUpUser(context);
                              //       } else {
                              //         signInUser(context);
                              //       }
                              //     } else {
                              //       logger.d("Some Error occured");
                              //     }
                              //   } on PlatformException catch (e) {
                              //     String errorMessage;
                              //     e.code.toString() ==
                              //             "ERROR_INVALID_VERIFICATION_CODE"
                              //         ? errorMessage = "Invalid OTP was entered"
                              //         : errorMessage = e.code.toString();
                              //     showDialog(
                              //         context: context,
                              //         barrierDismissible: false,
                              //         builder: (context) {
                              //           return AlertDialog(
                              //             title: Text("Verification Failed"),
                              //             content: Text(errorMessage),
                              //             actions: <Widget>[
                              //               FlatButton(
                              //                 child: Text("OK"),
                              //                 textColor: Colors.white,
                              //                 color: Theme.of(context)
                              //                     .primaryColor,
                              //                 onPressed: () {
                              //                   Navigator.pop(context);
                              //                 },
                              //               )
                              //             ],
                              //           );
                              //         });
                              //     logger.d(e.code);
                              //   } on Exception catch (e) {
                              //     showDialog(
                              //         context: context,
                              //         barrierDismissible: false,
                              //         builder: (context) {
                              //           return AlertDialog(
                              //             title: Text("Verification Failed"),
                              //             content: Text(e.toString()),
                              //             actions: <Widget>[
                              //               FlatButton(
                              //                 child: Text("OK"),
                              //                 textColor: Colors.white,
                              //                 color: Theme.of(context)
                              //                     .primaryColor,
                              //                 onPressed: () async {
                              //                   Navigator.pop(context);
                              //                 },
                              //               )
                              //             ],
                              //           );
                              //         });
                              //     logger.d(e);
                              //   }
                              // },
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
                        ValueListenableBuilder<FirebaseError>(
                            valueListenable: widget.args.errorNotif,
                            builder: (context, value, child) {
                              if (value.error) {
                                WidgetsBinding.instance.addPostFrameCallback(
                                  (_) => Scaffold.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "An unexpected error ocurred. Please try again later\n${value.message}",
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return SizedBox(
                                height:
                                    MediaQuery.of(context).viewInsets.bottom,
                              );
                            })
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

  void authenticateUsingOtp(BuildContext context) async {
    try {
      final AuthCredential authCredential = PhoneAuthProvider.credential(
        smsCode: _codeController.text.trim(),
        verificationId: widget.args.verificationId,
      );
      UserCredential creds =
          await FirebaseAuth.instance.signInWithCredential(authCredential);
      String idToken = await creds.user.getIdToken();
      if (widget.args.isLogin) {
        await UserRepository().signInWithOtp(idToken);
      } else {
        UserData user = context.read<UserData>();
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
      Navigator.of(context).pushNamedAndRemoveUntil(
        HomeScreen.id,
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      logger.e(e.toString());
      Scaffold.of(context).hideCurrentSnackBar();
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text("An uunexpected error occurred. Please try again"),
        ),
      );
    }
  }
}
