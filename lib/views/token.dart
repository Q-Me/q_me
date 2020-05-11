import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:qme/model/token.dart';

import '../model/queue.dart';
import '../constants.dart';
import '../widgets/dash.dart';
import '../utilities/time.dart';
//import 'package:flutter_layout_grid/flutter_layout_grid.dart';

/*

Display the token number, ETA, Distance

*/

class TokenPage extends StatefulWidget {
  static String id = 'token';
  final String queueId;
  TokenPage({this.queueId});
  @override
  _TokenPageState createState() => _TokenPageState();
}

class _TokenPageState extends State<TokenPage> {
  double get w => MediaQuery.of(context).size.width;
  double get h => MediaQuery.of(context).size.height;
  Widget imgWidget = ClipRRect(
    borderRadius: BorderRadius.only(
        topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
    child: Image.asset(
      'assets/images/profile_pic.jpg',
      fit: BoxFit.cover,
    ),
  );

  Queue queue = Queue.fromJson(jsonDecode('''
{
    "queue_id": "CFBIpLGW3",
    "start_date_time": "2020-05-01T00:36:00.000Z",
    "end_date_time": "2020-05-01T09:30:00.000Z",
    "max_allowed": 100,
    "avg_time_on_counter": 3,
    "status": "ACTIVE",
    "current_token": 2,
    "last_issued_token": 4,
    "last_update": "2020-05-01T01:24:41.000Z",
    "total_issued_tokens": 4,
    "subscriber": {
        "id": "YICeXFgnt",
        "name": "S3",
        "owner": "Mr. A",
        "email": "S3@gmail.com",
        "phone": "9898009900"
    },
    "ETA": "00:03",
    "token": {
        "token_no": 4,
        "status": "WAITING",
        "subscriber_id": "YICeXFgnt",
        "ahead": 1
    }
}
'''));

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
                Navigator.pop(context);
              },
              child: Icon(Icons.arrow_back_ios)),
          title: Text('Queue Details'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              Flexible(
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
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.blue[200],
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(10),
                                  topLeft: Radius.circular(10))),
                        ),
                      ),
                      Flexible(
                        flex: 2,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(queue.subscriber.name,
                                  style: kBigTextStyle.copyWith(
                                      color: Colors.black)),
                              Text(queue.subscriber.owner),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                width: w,
                margin: EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Grid2x2(queue),
                    DashContainer(),
                    TokenDisplay(QueueToken(tokenNo: 1)),
                    TokenButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12),
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
                    direction: Axis.horizontal, dashColor: Colors.black38)),
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
    );
  }
}

class TokenDisplay extends StatelessWidget {
  final QueueToken token;
  TokenDisplay(this.token);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Your Token Number',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 26),
            ),
            Text(
              token.tokenNo.toString(),
              style: kBigTextStyle.copyWith(fontSize: 50),
            ),
          ],
        ),
      ),
    );
  }
}

class TokenButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      margin: EdgeInsets.all(20),
      alignment: Alignment.center,
      child: Material(
        borderRadius: BorderRadius.circular(20.0),
        shadowColor: Colors.greenAccent,
        color: Colors.green,
        elevation: 7.0,
        child: InkWell(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: Text(
                'Get Token',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Grid2x2 extends StatelessWidget {
  final Queue queue;
  Grid2x2(this.queue);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(10),
      child: Table(
        children: [
          TableRow(children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 8.0),
                child: Grid2x2Item(
                  'Starts at',
                  '${getTime(queue.startDateTime)}',
                  '${getDate(queue.startDateTime)}',
                )),
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 8.0),
                child: Grid2x2Item(
                  'Ends at',
                  '${getTime(queue.endDateTime)}',
                  '${getDate(queue.endDateTime)}',
                )),
          ]),
          TableRow(children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 0.0),
                child: Grid2x2Item(
                  'Already in queue',
                  '${queue.totalIssuedTokens}',
                  'People',
                )),
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 0.0),
                child: Grid2x2Item(
                  'Your turn may come at',
                  getTime(queue.startDateTime.add(queue.eta)).toString(),
                  getDate(queue.startDateTime.add(queue.eta)).toString(),
                )),
          ])
        ],
      ),
    );
  }
}

class Grid2x2Item extends StatelessWidget {
  final String top, center, bottom;
  Grid2x2Item(this.top, this.center, this.bottom);
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(top, style: kSmallTextStyle),
        Text(center, style: kBigTextStyle),
        Text(bottom, style: kSmallTextStyle),
      ],
    );
  }
}
