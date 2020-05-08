import 'package:flutter/material.dart';

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
