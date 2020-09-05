import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:qme/utilities/session.dart';
import 'package:qme/views/about_us.dart';
import 'package:qme/views/business_enquiry.dart';
import 'package:qme/views/contact_us.dart';
import 'package:qme/views/profileview.dart';
import 'package:qme/views/signin.dart';

import 'package:hive_flutter/hive_flutter.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({
    Key key,
    @required this.controller,
  }) : super(key: key);
  final PageController controller;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Color.fromRGBO(9, 79, 239, 1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Menu",
          style: TextStyle(color: Colors.white),
        ),
        leading: GestureDetector(
          onTap: () {},
          child: Center(
            child: FaIcon(FontAwesomeIcons.arrowLeft),
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(20, 50, 20, 40),
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
                        builder: (context, box, widget) => Text(
                          "${box.get("name").split(" ")[0]}",
                          style: TextStyle(fontSize: 30),
                        ),
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
                      MenuListItem(
                        "Log Out",
                        FontAwesomeIcons.signOutAlt,
                        "logout",
                        controller,
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
              onTap: () {
                switch (index) {
                  case "profile":
                    print("profile page");
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return ProfileView();
                    }));
                    break;
                  case "bookings":
                    controller.animateToPage(1,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.ease);
                    //TODO navigate to corresponding screen
                    break;
                  case "support":
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return ContactUsView();
                    }));
                    //TODO navigate to corresponding screen
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
              await clearSession();
              Navigator.pushReplacementNamed(context, SignInScreen.id);

              /* try {
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
              } */
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
