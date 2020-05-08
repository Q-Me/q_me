import 'dart:collection';
import 'package:intl/intl.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../model/queue.dart';

import '../constants.dart';

class BookingScreen extends StatefulWidget {
  static String id = 'booking';
  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  double get w => MediaQuery.of(context).size.width;
  double get h => MediaQuery.of(context).size.height;
  final double appBarOffset = 10;
  List<Queue> queues = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    queues = queuesFromJson(jsonString).queue;
  }

  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context).settings.arguments as Map;
    if (arguments != null) print('Recieved id is ${arguments['id']}');

    return Scaffold(
      backgroundColor: Colors.green,
      body: SafeArea(
        child: Column(
//              mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(
                  vertical: 15, horizontal: appBarOffset / 2),
              width: w - appBarOffset * 2,
              color: Colors.transparent,
              alignment: Alignment(-1, -1),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green,
                  radius: 20,
                  child: Icon(Icons.arrow_back_ios),
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: w,
                padding: EdgeInsets.only(left: 15, right: 15, top: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  color: Colors.white,
                ),
                child: Column(
                  children: <Widget>[
                    HeaderInfo(),
                    Expanded(
                      child: ListView.builder(
                          itemCount: queues.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) =>
                              QueueItem(queues[index])),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

final String jsonString = '''
{
    "queue":[
        {
            "queue_id":"CFBIpLGW3",
            "start_date_time":"2020-05-01T00:36:00.000Z",
            "end_date_time":"2020-05-01T09:30:00.000Z",
            "max_allowed":100,
            "avg_time_on_counter":3,
            "status":"ACTIVE",
            "current_token":2,
            "last_issued_token":4,
            "last_update":"2020-05-01T01:24:41.000Z",
            "total_issued_tokens":4,
            "subscriber":{
                "id":"YICeXFgnt",
                "name":"S3",
                "owner":"Kavya",
                "email":"S3@gmail.com",
                "phone":"9898009900"
            },
            "ETA":"00:03",
            "token":{
                "token_no":4,
                "status":"WAITING",
                "subscriber_id":"YICeXFgnt",
                "ahead":1
            }
        },
        {
            "queue_id":"CFBIpLGW3",
            "start_date_time":"2020-05-01T00:36:00.000Z",
            "end_date_time":"2020-05-01T09:30:00.000Z",
            "max_allowed":100,
            "avg_time_on_counter":3,
            "status":"ACTIVE",
            "current_token":2,
            "last_issued_token":4,
            "last_update":"2020-05-01T01:24:41.000Z",
            "total_issued_tokens":4,
            "subscriber":{
                "id":"YICeXFgnt",
                "name":"S3",
                "owner":"Kavya",
                "email":"S3@gmail.com",
                "phone":"9898009900"
            },
            "ETA":"00:03",
            "token":{
                "token_no":4,
                "status":"WAITING",
                "subscriber_id":"YICeXFgnt",
                "ahead":1
            }
        },
        {
            "queue_id":"CFBIpLGW3",
            "start_date_time":"2020-05-01T00:36:00.000Z",
            "end_date_time":"2020-05-01T09:30:00.000Z",
            "max_allowed":100,
            "avg_time_on_counter":3,
            "status":"ACTIVE",
            "current_token":2,
            "last_issued_token":4,
            "last_update":"2020-05-01T01:24:41.000Z",
            "total_issued_tokens":4,
            "subscriber":{
                "id":"YICeXFgnt",
                "name":"S3",
                "owner":"Kavya",
                "email":"S3@gmail.com",
                "phone":"9898009900"
            },
            "ETA":"00:03",
            "token":{
                "token_no":4,
                "status":"WAITING",
                "subscriber_id":"YICeXFgnt",
                "ahead":1
            }
        },
        {
            "queue_id":"CFBIpLGW3",
            "start_date_time":"2020-05-01T00:36:00.000Z",
            "end_date_time":"2020-05-01T09:30:00.000Z",
            "max_allowed":100,
            "avg_time_on_counter":3,
            "status":"ACTIVE",
            "current_token":2,
            "last_issued_token":4,
            "last_update":"2020-05-01T01:24:41.000Z",
            "total_issued_tokens":4,
            "subscriber":{
                "id":"YICeXFgnt",
                "name":"S3",
                "owner":"Kavya",
                "email":"S3@gmail.com",
                "phone":"9898009900"
            },
            "ETA":"00:03",
            "token":{
                "token_no":4,
                "status":"WAITING",
                "subscriber_id":"YICeXFgnt",
                "ahead":1
            }
        }
    ]
}
''';

class QueueItem extends StatelessWidget {
  final Queue queue;
  QueueItem(this.queue);

  String getDate(DateTime dateTime) =>
      DateFormat("dd-MM-yyyy").format(dateTime);

  String getTime(DateTime dateTime) => DateFormat("Hm").format(dateTime);

  DateTime nextTokenTime(Queue queue) => queue.startDateTime
      .add(Duration(minutes: queue.totalIssuedTokens * queue.avgTimeOnCounter));

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          border: Border.all(width: 1, color: Colors.green)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Starts at', style: kSmallTextStyle),
                            Text(getTime(queue.startDateTime),
                                style: kBigTextStyle),
                            Text(getDate(queue.startDateTime),
                                style: kSmallTextStyle),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Ends at', style: kSmallTextStyle),
                          Text(getTime(queue.endDateTime),
                              style: kBigTextStyle),
                          Text(getDate(queue.endDateTime),
                              style: kSmallTextStyle),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Waiting in queue', style: kSmallTextStyle),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Text('${queue.totalIssuedTokens}',
                                  style: kBigTextStyle),
                              SizedBox(width: 10),
                              Text('People', style: kSmallTextStyle)
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Your turn may come at', style: kSmallTextStyle),
                          Text('21:00', style: kBigTextStyle),
                          Text('12-05-2020', style: kSmallTextStyle),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                  child: Text(
                      'Last Updated at\n${DateFormat('hh:mm aaa, MMM d, yyyy EEE').format(queue.lastUpdate)}')),
              Container(
                height: 35.0,
                width: MediaQuery.of(context).size.width / 4,
                child: Material(
                  borderRadius: BorderRadius.circular(20.0),
                  shadowColor: Colors.greenAccent,
                  color: Colors.green,
                  elevation: 7.0,
                  child: InkWell(
                    onTap: () {
                      print('${queue.queueId}');
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Center(
                        child: Text(
                          // Check
                          'Book',
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
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HeaderInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Dr. Piyush, MBBS',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          Text('Raheja Hospital, Bandra(W), Mumbai',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.black54,
              )),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
