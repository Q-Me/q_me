import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import '../widgets/button.dart';
import '../widgets/text.dart';
import '../widgets/formField.dart';
import '../views/nearby.dart';
import '../api/app_exceptions.dart';
import '../repository/user.dart';

class SignUpScreen extends StatefulWidget {
  static const id = '/signup';

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool showSpinner = false, passwordVisible;
  final ScrollController _scrollController = ScrollController();

  final formKey = GlobalKey<FormState>();
  Map<String, String> formData = {};

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
                                      if (formData['phone'].length != 10) {
                                        Scaffold.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Phone number must have 10 digits'),
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

                                      UserRepository user = UserRepository();
                                      formData['name'] =
                                          '${formData['firstName']}|${formData['lastName']}';
                                      // Make SignUp API call
                                      Map<String, dynamic> response;
                                      try {
                                        response = await user.signUp(formData);
                                      } on BadRequestException catch (e) {
                                        log('BadRequestException on SignUp:' +
                                            e.toString());
                                        Scaffold.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                e.toMap()['error'].join('\n')),
                                          ),
                                        );
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
                                          response['msg'] ==
                                              'Registation successful') {
                                        // Make SignIn call
                                        try {
                                          response = await user.signIn({
                                            'email': formData['email'],
                                            'password': formData['password']
                                          });
                                        } catch (e) {
                                          log(e.toString());
                                          Scaffold.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(e.toString()),
                                            ),
                                          );
                                        }
                                        if (response['name'] != null) {
                                          // SignIn successful
                                          Navigator.pushNamed(
                                              context, NearbyScreen.id);
                                        }
                                      } else {
                                        // SignUp failed
                                        return;
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
