import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AboutUsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButton: IconButton(
          icon: FaIcon(
            Icons.arrow_back,
            size: 40,
            color: Color(0xFF838383),
          ),
          onPressed: () {
            Navigator.pop(context);
          }),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: w,
              height: h * 0.4,
              child: SvgPicture.asset(
                "assets/images/aboutus.svg",
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              width: w,
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "About Us",
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    """We're a group of B-Tech students from IIT Patna.

We have created this app with an aim to create an online marketplace for offline services and save time of the users by providing hassle free appointment system. 

This app which you're using right now is just a basic version of what we have already planned. You would be getting a hell lot of features in coming days. We're working hard to roll out next features.

Just stay with us and trust us, we would completely change your beauty & wellness experience.

We are in a process to add more & more services near you so that you doesn't miss your favourite one.

We're starting this from Patna and will roll out in other cities in coming days.

Also, we would love to hear a feedback from you regarding your current experience and suggestions for us.

Please feel free to contact or email us. """,
                    style: TextStyle(fontWeight: FontWeight.bold),
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
