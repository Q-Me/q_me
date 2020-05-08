import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'profile.dart';
import '../constants.dart';

/*

Display the token number, ETA, Distance

*/

class TokenPage extends StatefulWidget {
  static String id = 'token';
  @override
  _TokenPageState createState() => _TokenPageState();
}

class _TokenPageState extends State<TokenPage> {
  double get w => MediaQuery.of(context).size.width;
  double get h => MediaQuery.of(context).size.height;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.green,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: GestureDetector(
              onTap: () {
                // TODO to profile
                Navigator.pushNamed(context, ProfilePage.id);
              },
              child: Icon(Icons.arrow_back_ios)),
          title: Text('Your Token'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  width: w,
                  margin: EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Flexible(
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10)),
                          child: Image.asset(
                            'assets/images/profile_pic.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Dr. Piyush, MBBS',
                                style: kBigTextStyle.copyWith(
                                    color: Colors.black)),
                            Text('wrgg'),
                            Text('Booked At 27th April, 2020 03:28PM')
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  width: w,
                  margin: EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Flexible(
                        flex: 3,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text('12', style: kBigTextStyle),
                                Text('Queue', style: kSmallTextStyle),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text('47', style: kBigTextStyle),
                                Text('Minutes to go', style: kSmallTextStyle),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text('5.5', style: kBigTextStyle),
                                Text('km to reach', style: kSmallTextStyle),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text('12', style: kBigTextStyle),
                                Text('Queue', style: kSmallTextStyle),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 20,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              width: 10,
                              decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(10),
                                      bottomRight: Radius.circular(10))),
                            ),
                            Expanded(
                              child: Center(
                                child: Dash(
                                    direction: Axis.horizontal,
//                                    length: ,
//                                dashLength: 12,
                                    dashColor: Colors.black38),
                              ),
                            ),
                            Container(
                              width: 10,
                              decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      bottomLeft: Radius.circular(10))),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        flex: 4,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'Your Token Number',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 26),
                                ),
                                Text(
                                  'QA123',
                                  style: kBigTextStyle.copyWith(fontSize: 50),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Dash extends StatelessWidget {
  const Dash(
      {Key key,
      this.direction = Axis.horizontal,
      this.dashColor = Colors.black,
      this.length = 200,
      this.dashGap = 3,
      this.dashLength = 6,
      this.dashThickness = 1,
      this.dashBorderRadius = 0})
      : super(key: key);

  final Axis direction;
  final Color dashColor;
  final double length;
  final double dashGap;
  final double dashLength;
  final double dashThickness;
  final double dashBorderRadius;

  @override
  Widget build(BuildContext context) {
    var dashes = <Widget>[];
    double n = (length + dashGap) / (dashGap + dashLength);
    int newN = n.round();
    double newDashGap = (length - dashLength * newN) / (newN - 1);
    for (var i = newN; i > 0; i--) {
      dashes.add(step(i, newDashGap));
    }
    if (direction == Axis.horizontal) {
      return SizedBox(
          width: length,
          child: Row(
            children: dashes,
          ));
    } else {
      return Column(children: dashes);
    }
  }

  Widget step(int index, double newDashGap) {
    bool isHorizontal = direction == Axis.horizontal;
    return Padding(
        padding: EdgeInsets.fromLTRB(
            0,
            0,
            isHorizontal && index != 1 ? newDashGap : 0,
            isHorizontal || index == 1 ? 0 : newDashGap),
        child: SizedBox(
          width: isHorizontal ? dashLength : dashThickness,
          height: isHorizontal ? dashThickness : dashLength,
          child: DecoratedBox(
            decoration: BoxDecoration(
                color: dashColor,
                borderRadius:
                    BorderRadius.all(Radius.circular(dashBorderRadius))),
          ),
        ));
  }
}
