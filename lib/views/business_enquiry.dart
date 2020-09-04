import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class BusinessEnquiryView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButton: IconButton(
          icon: FaIcon(
            Icons.arrow_back,
            size: 40,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          }),
      body: SingleChildScrollView(
        child: Column(
          children: [
            PinkContainer(h: h, w: w),
            SizedBox(
              height: 10,
            ),
            Slogan(w: w),
            SizedBox(
              height: 10,
            ),
            Divider(
              height: 2,
              color: Colors.black,
            ),
            NameAndPost(w: w),
            EmailAndPhoneNumberTiles()
          ],
        ),
      ),
    );
  }
}

class EmailAndPhoneNumberTiles extends StatelessWidget {
  const EmailAndPhoneNumberTiles({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const String phone1 = "+91 9931059201";
    const String phone2 = "+91 8340342582";
    const String beEmail = "aman.ks0224@gmail.com";
    _launchURL({String phoneNum, String email}) async {
      String url = phoneNum != null
          ? 'tel:$phoneNum'
          : 'mailto:$email?subject=Business%20Enquiry';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $phoneNum';
      }
    }

    return Container(
      padding: EdgeInsets.all(18),
      child: Column(
        children: [
          Column(
            children: [
              ListTile(
                  onTap: () async {
                    await _launchURL(phoneNum: phone1);
                  },
                  contentPadding: EdgeInsets.only(left: 14),
                  title: Row(
                    children: [
                      Icon(Icons.phone),
                      SizedBox(
                        width: 10,
                      ),
                      Text(phone1),
                    ],
                  )),
            ],
          ),
          ListTile(
            onTap: () async {
              await _launchURL(phoneNum: phone2);
            },
            title: Row(
              children: [
                Icon(Icons.phone),
                SizedBox(
                  width: 10,
                ),
                Text(phone2)
              ],
            ),
          ),
          ListTile(
            onTap: () async {
              await _launchURL(email: beEmail);
            },
            contentPadding: EdgeInsets.only(left: 14),
            title: Row(
              children: [
                Icon(Icons.mail),
                SizedBox(
                  width: 10,
                ),
                Text(beEmail),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NameAndPost extends StatelessWidget {
  const NameAndPost({
    Key key,
    @required this.w,
  }) : super(key: key);

  final double w;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: w,
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Aman Deep",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            "Business head",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w500, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class Slogan extends StatelessWidget {
  const Slogan({
    Key key,
    @required this.w,
  }) : super(key: key);

  final double w;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: w,
      padding: EdgeInsets.only(right: 12, left: 12, bottom: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "We would love to collaborate with you.",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            "Feel free to reach out :) ",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class PinkContainer extends StatelessWidget {
  const PinkContainer({
    Key key,
    @required this.h,
    this.w,
  }) : super(key: key);

  final double h;
  final double w;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 14),
      height: h * 0.3,
      width: w,
      decoration: BoxDecoration(
          color: Color(0xFFf0e2dd),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          )),
      // child: CircleAvatar(
      //   radius: w / 6,
      //   backgroundColor: Colors.white,
      // ),
      child: Align(
        alignment: Alignment.topRight,
        child: Container(
          height: h * 0.3 * 0.85,
          width: w / 2,
          child: SvgPicture.network(
            "https://firebasestorage.googleapis.com/v0/b/q-me-user.appspot.com/o/assets%2Fimages%2Fwantlist.svg?alt=media&token=8371ca6e-34c4-4b9a-ac36-09f051ce0428",
          ),
        ),
      ),
    );
  }
}
