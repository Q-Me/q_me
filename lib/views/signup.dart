import 'package:flutter/material.dart';
import '../api/signin.dart';
import '../widgets/button.dart';
import 'dart:developer';

import '../widgets/text.dart';
import '../widgets/formField.dart';
import 'nearby.dart';
import '../api/signup.dart';

class SignUpPage extends StatefulWidget {
  static final id = 'signup';

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool showSpinner = false;
  final formKey = GlobalKey<FormState>();
  Map<String, String> formData = {};

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          resizeToAvoidBottomPadding: false,
          body: Builder(
            builder: (context) => SingleChildScrollView(
              child: Form(
                key: formKey,
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
                                  log('first name is ${formData['firstName']}');
                                },
                              ),
                              SizedBox(height: 10.0),
                              MyFormField(
                                name: 'LAST NAME',
                                callback: (value) {
                                  formData['lastName'] = value;
                                  log('last name is ${formData['lastName']}');
                                },
                              ),
                              SizedBox(height: 10.0),
                              MyFormField(
                                keyboardType: TextInputType.phone,
                                name: 'PHONE',
                                required: true,
                                callback: (value) {
                                  formData['phone'] = value;
                                },
                              ),
                              SizedBox(height: 10.0),
                              MyFormField(
                                keyboardType: TextInputType.emailAddress,
                                name: 'EMAIL',
                                required: true,
                                callback: (value) {
                                  formData['email'] = value;
                                },
                              ),
                              SizedBox(height: 10.0),
                              MyFormField(
                                required: true,
                                name: 'PASSWORD',
                                obscureText: true,
                                callback: (value) {
                                  formData['pswd'] = value;
                                },
                              ),
                              SizedBox(height: 10.0),
                              MyFormField(
                                required: true,
                                obscureText: true,
                                name: 'CONFIRM PASSWORD',
                                callback: (value) {
                                  formData['cpswd'] = value;
                                },
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
                                      if (formKey.currentState.validate()) {
                                        log('$formData');
                                        // check phone number length
                                        if (formData['phone'].length != 10) {
                                          Scaffold.of(context).showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Phone number must have 10 digits')));
                                        }

                                        if (formData['pswd'] !=
                                            formData['cpswd']) {
                                          Scaffold.of(context).showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Passwords do not match')));
                                          return null;
                                        }

                                        FocusScope.of(context).requestFocus(
                                            FocusNode()); // dismiss the keyboard
                                        Scaffold.of(context).showSnackBar(
                                            SnackBar(
                                                content:
                                                    Text('Processing Data')));
                                        // Make SignUp API call
                                        String msg = await signUp(
                                            formData['firstName'],
                                            formData['lastName'],
                                            formData['email'],
                                            formData['pswd'],
                                            formData['phone']);
                                        log('signup response  $msg');
                                        if (msg ==
                                            'Email already registered.') {
//                                          Navigator.pushNamed(
//                                              context, SignInPage.id);
                                        } else if (msg ==
                                            'Registation successful') {
                                          // TODO SignIn the user
                                          Map userData = await signIn(
                                              formData['email'],
                                              formData['pswd']);

                                          if (userData['status'] == 200) {
                                            // Show login success
                                            Scaffold.of(context).showSnackBar(
                                                SnackBar(
                                                    content:
                                                        Text('Sigining in')));
                                            // Navigate to Nearby screen
                                            Navigator.pushNamed(
                                                context, NearbyScreen.id);
                                          } else {
                                            // TODO Check for other errors
                                            // Here there is no chance of invalid credentials because same password is used for signUp and sigIn
                                            Scaffold.of(context).showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        '${userData['error']}')));
                                          }
                                        }
                                      }
                                    },
                                    child: Center(
                                      child: Text(
                                        'SIGNUP',
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
                              /*HollowSocialButton(
                                label: 'Signup with Facebook',
                                img: ImageIcon(
                                    AssetImage('assets/facebook.png')),
                                onPress: () {
                                  print('Signup with FB Pressed');
//                                Navigator.pushNamed(context, NearbyScreen.id);
                                },
                              ),
                              SizedBox(height: 20.0),
                              HollowSocialButton(
                                label: '  Signup with Google  ',
                                img: ImageIcon(
                                    AssetImage('assets/icons8-google-512.png')),
                                onPress: () {
                                  log('Signup with Google Pressed');
                                },
                              ),
                              SizedBox(height: 20.0),*/
                            ],
                          )),
                    ]),
              ),
            ),
          )),
    );
  }
}
