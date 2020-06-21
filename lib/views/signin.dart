//import 'dart:html';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:qme/fireBase/sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'nearby.dart';
import 'signup.dart';
import '../constants.dart';
import '../widgets/formField.dart';
import '../widgets/text.dart';
import '../api/signin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignInScreen extends StatefulWidget {
  static const id = '/signin';
  @override
  _SignInScreenState createState() => new _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final formKey =
      GlobalKey<FormState>(); // Used in login button and forget password
  String email;
  String password;
  googleLogin(var finals) async {
      print(finals.email);
    print(finals.displayName);
    print(finals.id);
    print(finals.photoUrl);
    print(finals.email);
    log('Showing snackbar');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var accessToken = prefs.getString('accessToken');
    print("acessToken-signin_page: $accessToken");
    if (accessToken == null) {
      Navigator.of(context).pushNamed(SignUpScreen.id);
    } else {

      print("sign_in page called");
      Map response =
          await signIn(finals.email,  "#" + finals.email + "#");
          print("finals.email ${finals.email} and password ${ '#' + finals.email + '#'}");
          print("here is repponse $response");
      if (response['status'] == 200) {
        // Navigate to Nearby screen
        Navigator.pushNamed(context, NearbyScreen.id);
      } else {
        return;
      }
    }
  
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
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
                          MyFormField(
                            required: true,
                            name: 'EMAIL',
                            callback: (String newEmail) {
                              email = newEmail;
                              log('email is $email');
                            },
                          ),
                          SizedBox(height: 20.0),
                          MyFormField(
                            required: true,
                            obscureText: true,
                            name: 'PASSWORD',
                            callback: (String newPassword) {
                              password = newPassword;
                              log('pass1 is $password');
                            },
                          ),
                          SizedBox(height: 5.0),
                          /* TODO complete this after API for forget password is working
                            Container(
                              alignment: Alignment(1.0, 0.0),
                              padding: EdgeInsets.only(top: 15.0, left: 20.0),
                              child: InkWell(
                                child: Text(
                                  'Forgot Password',
                                  style: kLinkTextStyle,
                                ),
                              ),
                            ),*/
                          SizedBox(height: 40.0),
                          Container(
                            height: 50.0,
                            child: Material(
                              borderRadius: BorderRadius.circular(20.0),
                              shadowColor: Colors.greenAccent,
                              color: Colors.green,
                              elevation: 7.0,
                              child: InkWell(
                                onTap: () async {
                                  log('Showing snackbar');
                                  if (formKey.currentState.validate()) {
                                    // email and password both are available here
                                    log('email $email pass $password');
                                    FocusScope.of(context).requestFocus(
                                        FocusNode()); // dismiss the keyboard
                                    Scaffold.of(context).showSnackBar(SnackBar(
                                        content: Text('Processing Data')));

                                    // Make LOGIN API call
                                    Map response =
                                        await signIn(email, password);

                                    if (response['status'] == 200) {
                                      // TODO Show login success
                                      // Navigate to Nearby screen
                                      Navigator.pushNamed(
                                          context, NearbyScreen.id);
                                    } else {
                                      return;
                                    }
                                  }
                                },
                                child: Center(
                                  child: Text(
                                    'LOGIN',
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
                          _signInButton(),
                          // SizedBox(height: 5.0),
                          /*
                            HollowSocialButton(
                              label: 'Login with Facebook',
                              img: ImageIcon(AssetImage('assets/facebook.png')),
                              onPress: () {
                                print('FB');
                              },
                            ),
                            SizedBox(height: 20.0),
                            HollowSocialButton(
                              label: '  Login with Google  ',
                              img: ImageIcon(
                                  AssetImage('assets/icons8-google-512.png')),
                              onPress: () {
                                print('Google');
                              },
                            ),*/
                          SizedBox(height: 20.0),
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
                        print('Register button pressed');
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

  Widget _signInButton() {
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: () async {
        var finals = await signInWithGoogle();

        return googleLogin(finals);
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.grey),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(
                image: AssetImage("assets/icons/google_logo.png"),
                height: 35.0),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'Sign in with Google',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
