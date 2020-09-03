import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({
    Key key,
    @required this.controller,
  }) : super(key: key);
  final PageController controller;
  @override
  Widget build(BuildContext context) {
    Box box = Hive.box("user");
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
                      Text(
                        "${box.get("name")}",
                        style: TextStyle(fontSize: 30),
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
                    //TODO navigate to corresponding screen
                    break;
                  case "bookings":
                    controller.animateToPage(1,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.ease);
                    //TODO navigate to corresponding screen
                    break;
                  case "support":
                    //TODO navigate to corresponding screen
                    break;
                  case "logout":
                    //TODO navigate to corresponding screen
                    break;
                  case "buisness":
                    //TODO navigate to corresponding screen
                    break;
                  case "about":
                    //TODO navigate to corresponding screen
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
