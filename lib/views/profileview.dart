import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';

class ProfileView extends StatelessWidget {
  final String userName = Hive.box("user").get("name");
  final String userPhone = Hive.box("user").get("phone");
  final String userEmail = Hive.box("user").get("email");

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      floatingActionButton: IconButton(
          icon: FaIcon(
            Icons.arrow_back,
            size: 40,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: Container(
        height: h,
        width: w,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(15),
              width: w,
              height: h * 0.25,
              color: Color(0xFF0053ce),
              child: Center(
                child: BlueTileItems(w: w, name: userName),
              ),
            ),
            Container(
              padding: EdgeInsets.all(20),
              width: w,
              child: Column(
                children: [
                  ProfileScreenInfoTab(
                    infoDescription: "Username",
                    info: "$userName",
                  ),
                  ProfileScreenInfoTab(
                    infoDescription: "Phone Number",
                    info: "$userPhone",
                  ),
                  ProfileScreenInfoTab(
                    infoDescription: "Email",
                    info: "$userEmail",
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class BlueTileItems extends StatelessWidget {
  const BlueTileItems({
    Key key,
    @required this.w,
    @required this.name,
  }) : super(key: key);

  final double w;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        FaIcon(FontAwesomeIcons.solidUserCircle,
            size: w * 0.17, color: Colors.white),
        Container(
          padding: EdgeInsets.only(left: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Hello",
                  style: TextStyle(color: Colors.white, fontSize: 14)),
              SizedBox(
                height: 3,
              ),
              Text(name,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
              SizedBox(
                height: 10,
              )
            ],
          ),
        ),
        Spacer(),
        Expanded(
          child: Align(
            alignment: Alignment.topRight,
            child: Container(
              width: w * 0.28,
              child: SvgPicture.asset(
                "assets/images/gb.svg",
              ),
            ),
          ),
          //TODO: IMAGE
        )
      ],
    );
  }
}

class ProfileScreenInfoTab extends StatelessWidget {
  const ProfileScreenInfoTab({
    Key key,
    @required this.infoDescription,
    @required this.info,
  }) : super(key: key);
  final String infoDescription;
  final String info;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 5,
        ),
        Text(infoDescription,
            style: TextStyle(
                color: Color(0xFFc4c4c4),
                fontSize: 14,
                fontWeight: FontWeight.bold)),
        SizedBox(
          height: 5,
        ),
        Text(
          info,
          style: TextStyle(
              color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 10,
        ),
        Divider(
          height: 2,
        ),
        SizedBox(
          height: 5,
        ),
      ],
    );
  }
}
