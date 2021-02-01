import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:qme/model/api_params/signup.dart';
import 'package:qme/model/user.dart';
import 'package:qme/services/analytics.dart';
import 'package:qme/utilities/logger.dart';
import 'package:qme/views/home.dart';
import 'package:qme/services/firebase_auth_service.dart';
import 'package:qme/widgets/button.dart';
import '../repository/user.dart';

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

  fetchPhoneNumber() async {
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
        context.read<AnalyticsService>().logEvent(
          "Login Success",
          {
            "Route": "OTP",
            "Phone": creds.user.phoneNumber,
          },
        );
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
        context.read<AnalyticsService>().logEvent(
          "Signup Success",
          {
            "Phone": user.phone,
          },
        );
      }
      context.read<AnalyticsService>().updateUserProp();
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
