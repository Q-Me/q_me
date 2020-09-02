import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({Key key}) : super(key: key);

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
                padding: EdgeInsets.only(top: 55),
                child: Column(
                  children: [
                    Text(
                      "${box.get("name")}",
                      style: TextStyle(fontSize: 30),
                    ),
                    _listItem(
                        "My Profile", FontAwesomeIcons.addressCard, "profile"),
                    _listItem(
                        "My Bookings", FontAwesomeIcons.userCheck, "bookings"),
                    _listItem(
                        "Need Support?", FontAwesomeIcons.phoneAlt, "support"),
                    _listItem("Log Out", FontAwesomeIcons.signOutAlt, "logout"),
                    _listItem("Buisness Enquiry",
                        FontAwesomeIcons.projectDiagram, "buisness"),
                    _listItem("About Us", FontAwesomeIcons.infoCircle, "about"),
                  ],
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

  Widget _listItem(String title, IconData icon, String index) {
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
                  case "booking":
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
