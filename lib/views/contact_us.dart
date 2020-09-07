import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsView extends StatelessWidget {
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
            color: Colors.grey,
          ),
          onPressed: () {
            Navigator.pop(context);
          }),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: h * 0.4,
              child: SvgPicture.asset(
                "assets/images/contactus.svg",
              ),
            ),
            NameAndPost(
              w: w,
              name: "Aman Deep",
              position: "Building Relations @ Q Me",
            ),
            EmailAndPhoneNumberTiles(
              phone1: "+91 9931059201",
              phone2: "+91 8340342582",
              beEmail: "aman.ks0224@gmail.com",
            ),
            NameAndPost(
              w: w,
              name: "Piyush Chauhan",
              position: "Building Product @ Q Me",
            ),
            EmailAndPhoneNumberTiles(
              phone1: "+91 96735 82517",
              phone2: "+91 8850774467",
              beEmail: "pi.codemonk@gmail.com",
            ),
          ],
        ),
      ),
    );
  }
}

class EmailAndPhoneNumberTiles extends StatelessWidget {
  const EmailAndPhoneNumberTiles({
    Key key,
    @required this.phone1,
    @required this.phone2,
    @required this.beEmail,
  }) : super(key: key);

  final String phone1;
  final String phone2;
  final String beEmail;

  @override
  Widget build(BuildContext context) {
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
                      Column(
                        children: [Text(phone1), SizedBox()],
                      ),
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
    @required this.name,
    @required this.position,
  }) : super(key: key);

  final double w;
  final String name;
  final String position;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: w,
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            position,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w500, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
