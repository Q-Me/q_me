import 'package:flutter/material.dart';
import '../model/subscriber.dart';
import 'dart:developer';
import '../views/booking.dart';

class MyTheme {
  static const Color indigo = Color(0xff3f4fa5);
  static const Color pink = Color(0xfffe6491);
  static const Color textColor = Color(0xff33429e);
  static const Color grey = Color(0xffa5acd1);
  static const Color lightGrey = Color(0xffe4e9f5);
}

class CustomListTile extends StatelessWidget {
  final double w;
  final String img;
  final String title;
  final String subtitle;
  final bool isOpened;
  final Function onTap;

  const CustomListTile(
      {Key key,
      this.w,
      this.img,
      this.title,
      this.subtitle,
      this.isOpened,
      this.onTap})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: w - 48,
      height: 102,
      padding: EdgeInsets.symmetric(horizontal: 9),
      child: Row(
        children: <Widget>[
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: AssetImage(img),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      color: MyTheme.textColor,
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: MyTheme.textColor,
                    size: 20,
                  ),
                ],
              ),
              SizedBox(height: 6),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 16,
                  color: MyTheme.grey,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class SubscriberGridTile extends StatelessWidget {
  final Subscriber subscriberData;
  final int index;
  SubscriberGridTile({this.subscriberData, this.index});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
          left: index % 2 == 0 ? 10 : 5,
          right: index % 2 != 0 ? 10 : 5,
          top: 5,
          bottom: 5),
      child: GestureDetector(
        onTap: () {
//          log('From Nearby (SubscriberGridTile) Going to Subscriber id:${subscriberData.id}');
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookingScreen(subscriber: subscriberData),
              ));
        },
        child: Container(
          decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.all(Radius.circular(10))),
          padding: EdgeInsets.all(8),
          child: Column(
            children: <Widget>[
              // New
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(8)),
                    child: Text("New", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: Text(subscriberData.name,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20)),
                        ),
                        SizedBox(height: 8),
                        Text(subscriberData.owner,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            )),
                        SizedBox(height: 8),
                        Text(
                          subscriberData.address,
                          maxLines: 2,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
