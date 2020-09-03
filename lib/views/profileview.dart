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
                  FieldValue(
                    label: "Username",
                    text: "$userName",
                  ),
                  FieldValue(
                    label: "Phone Number",
                    text: "$userPhone",
                  ),
                  FieldValue(
                    label: "Email",
                    text: "$userEmail",
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
              child: SvgPicture.network(
                  "https://firebasestorage.googleapis.com/v0/b/q-me-user.appspot.com/o/assets%2Fimages%2Fgb.svg?alt=media&token=17889efe-b8b5-4523-9d4c-f2f31df0f2b2"),
            ),
          ),
          //TODO: IMAGE
        )
      ],
    );
  }
}

class FieldValue extends StatelessWidget {
  final String label;
  final String text;

  FieldValue({
    Key key,
    @required this.label,
    this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: TextEditingController(text: text),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        focusColor: Colors.lightBlue,
        enabled: text != null ? false : true,
      ),
    );
  }
}
