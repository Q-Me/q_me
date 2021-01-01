import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:qme/services/analytics.dart';
import 'package:qme/repository/user.dart';
import 'package:qme/utilities/logger.dart';
import 'package:qme/views/about_us.dart';
import 'package:qme/views/business_enquiry.dart';
import 'package:qme/views/contact_us.dart';
import 'package:qme/views/profileview.dart';
import 'package:qme/views/signin.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:qme/views/signup.dart';
import 'package:qme/widgets/survey.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({
    Key key,
    @required this.controller,
    @required this.observer,
  }) : super(key: key);
  final PageController controller;
  final FirebaseAnalyticsObserver observer;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Color.fromRGBO(9, 79, 239, 1),
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            controller.animateToPage(0,
                duration: Duration(milliseconds: 500), curve: Curves.ease);
            observer.analytics.setCurrentScreen(screenName: "Home Screen");
          },
          child: Center(
            child: FaIcon(FontAwesomeIcons.arrowLeft),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Menu",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(20, 50, 20, 40),
        child: Stack(
          overflow: Overflow.visible,
          alignment: AlignmentDirectional.topCenter,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Padding(
                padding: EdgeInsets.only(top: 55, bottom: 20),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ValueListenableBuilder(
                        valueListenable: Hive.box('user').listenable(),
                        builder: (context, box, widget) {
                          String name = box.get('name');
                          if (name != null && !name.startsWith('guest')) {
                            return Text(
                              name.length > 1
                                  ? "${name.split(" ").elementAt(0)}"
                                  : name,
                              style: TextStyle(fontSize: 30),
                            );
                          }
                          return SizedBox(height: 30);
                        },
                      ),
                      MenuListItem(
                        "My Profile",
                        FontAwesomeIcons.addressCard,
                        "profile",
                        controller,
                      ),
                      MenuListItem(
                        "My Bookings",
                        FontAwesomeIcons.userCheck,
                        "bookings",
                        controller,
                      ),
                      MenuListItem(
                        "Need Support?",
                        FontAwesomeIcons.phoneAlt,
                        "support",
                        controller,
                      ),
                      ValueListenableBuilder(
                        valueListenable: Hive.box('user').listenable(),
                        builder: (context, box, widget) {
                          bool isGuest = box.get('isGuest') ?? false;
                          if (!isGuest)
                            return MenuListItem(
                              "Log Out",
                              FontAwesomeIcons.signOutAlt,
                              "logout",
                              controller,
                            );
                          return MenuListItem(
                            "Sign Up",
                            FontAwesomeIcons.signInAlt,
                            "Sign Up",
                            controller,
                          );
                        },
                      ),
                      MenuListItem(
                        "Buisness Enquiry",
                        FontAwesomeIcons.projectDiagram,
                        "buisness",
                        controller,
                      ),
                      MenuListItem(
                        "About Us",
                        FontAwesomeIcons.infoCircle,
                        "about",
                        controller,
                      ),
                      MenuListItem(
                        "Recommend your saloon",
                        FontAwesomeIcons.pollH,
                        "survey",
                        controller,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -55,
              child: Container(
                padding: EdgeInsets.all(10),
                child: CircleAvatar(
                  child: FaIcon(
                    FontAwesomeIcons.solidUserCircle,
                    size: 90,
                  ),
                  radius: 50,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}

class MenuListItem extends StatelessWidget {
  const MenuListItem(this.title, this.icon, this.index, this.controller);
  final String title;
  final IconData icon;
  final String index;
  final PageController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(
            thickness: 3,
          ),
          Material(
            color: Colors.white,
            child: InkWell(
              onTap: () async {
                switch (index) {
                  case "profile":
                    Box box = Hive.box('user');
                    if (box.get('isGuest')) {
                      showDialog(context: context, child: LoginSignUpAlert());
                    } else {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return ProfileView();
                      }));
                    }
                    break;
                  case "bookings":
                    controller.animateToPage(1,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.ease);
                    AnalyticsService()
                        .getAnalyticsObserver()
                        .analytics
                        .setCurrentScreen(screenName: "My Bookings Screen");
                    break;
                  case "support":
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return ContactUsView();
                    }));
                    break;
                  case "logout":
                    showDialog(
                        context: context,
                        child: AlertDialogRefactor(
                          scaffoldContext: context,
                        ));
                    break;
                  case "buisness":
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return BusinessEnquiryView();
                    }));
                    break;
                  case "about":
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return AboutUsView();
                    }));
                    break;
                  case "Sign Up":
                    Navigator.pushNamed(context, SignUpScreen.id);
                    break;
                  case "survey":
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Survey(
                          key: UniqueKey(),
                        ),
                      ),
                    );
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Flexible(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: FaIcon(
                        icon,
                        size: 30,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        title,
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class LoginSignUpAlert extends StatelessWidget {
  const LoginSignUpAlert({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'You need to login or signup to proceed.',
        style: TextStyle(color: Color(0xFF49565e)),
      ),
      actions: [
        FlatButton(
          onPressed: () => Navigator.pushNamed(context, SignInScreen.id),
          child: Text(
            'Login',
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
        FlatButton(
          onPressed: () => Navigator.pushNamed(context, SignUpScreen.id),
          child: Text(
            'SignUp',
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
        FlatButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(color: Color(0xFF49565e)),
          ),
        ),
      ],
    );
  }
}

class AlertDialogRefactor extends StatelessWidget {
  const AlertDialogRefactor({
    Key key,
    this.scaffoldContext,
  }) : super(key: key);
  final BuildContext scaffoldContext;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Do you want to Log out?',
        style: TextStyle(color: Color(0xFF49565e)),
      ),
      actions: [
        FlatButton(
            child: Text(
              'YES',
              style: TextStyle(color: Colors.redAccent),
            ),
            onPressed: () async {
              try {
                await UserRepository().signOut();
                Navigator.pushReplacementNamed(context, SignInScreen.id);
              } catch (e) {
                logger.e(e.toString());
                Navigator.pop(context);
                Scaffold.of(scaffoldContext).showSnackBar(
                  SnackBar(
                    content: Text(e.toString()),
                  ),
                );
                return;
              }
            }),
        FlatButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'NO',
              style: TextStyle(color: Color(0xFF49565e)),
            ))
      ],
    );
  }
}
