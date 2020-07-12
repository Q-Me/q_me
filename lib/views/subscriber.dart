import 'dart:collection';
import 'dart:developer';

import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qme/api/base_helper.dart';
import 'package:qme/bloc/subscriber.dart';
import 'package:qme/constants.dart';
import 'package:qme/model/queue.dart';
import 'package:qme/model/reception.dart';
import 'package:qme/model/slot.dart';
import 'package:qme/model/subscriber.dart';
import 'package:qme/utilities/time.dart';
import 'package:qme/views/appointment.dart';
import 'package:qme/views/token.dart';
import 'package:qme/widgets/error.dart';
import 'package:qme/widgets/loader.dart';

class SubscriberScreen extends StatefulWidget {
  static const String id = '/booking';
  final Subscriber subscriber;
  SubscriberScreen({this.subscriber});
  @override
  _SubscriberScreenState createState() => _SubscriberScreenState();
}

class _SubscriberScreenState extends State<SubscriberScreen> {
  double get w => MediaQuery.of(context).size.width;
  double get h => MediaQuery.of(context).size.height;
  final double appBarOffset = 10;

  SubscriberBloc _bloc;

  @override
  void initState() {
    log('Opening queues for subscriber id:' + widget.subscriber.id);
    super.initState();
    _bloc = SubscriberBloc(widget.subscriber.id);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bloc == null) {
      _bloc = SubscriberBloc(widget.subscriber.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ChangeNotifierProvider.value(
            value: widget.subscriber,
            child: Column(
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
                Container(
                  width: w,
                  padding: EdgeInsets.only(left: 15, right: 15, top: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: <Widget>[
                      SubscriberHeaderInfo(subscriber: widget.subscriber),
                      SizedBox(
                        width: 600,
                        height: 200,
                        child: Carousel(
                          images: [
                            NetworkImage(
                                'https://cdn-images-1.medium.com/max/2000/1*GqdzzfB_BHorv7V2NV7Jgg.jpeg'),
                            NetworkImage(
                                'https://cdn-images-1.medium.com/max/2000/1*wnIEgP1gNMrK5gZU7QS0-A.jpeg'),
                          ],
                        ),
                      ),
//                    CalStrip(),
                      /*StreamBuilder<ApiResponse<List<Queue>>>(
                        stream: _bloc.queuesListStream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            switch (snapshot.data.status) {
                              case Status.LOADING:
                                return Loading(
                                    // TODO add shimmer loader
                                    loadingMessage: snapshot.data.message);
                                break;
                              case Status.COMPLETED:
                                return QueuesDisplay(snapshot.data.data);
                                break;
                              case Status.ERROR:
                                return Error(
                                  errorMessage: snapshot.data.message,
                                  onRetryPressed: () => _bloc.fetchQueuesList(),
                                );
                                break;
                            }
                          } else {
                            log('no Snapshot data');
                          }
                          return Container();
                        },
                      ),
                      Divider(),*/
                      StreamBuilder<ApiResponse<List<Reception>>>(
                          stream: _bloc.receptionListStream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              switch (snapshot.data.status) {
                                case Status.LOADING:
                                  return Loading(
                                      // TODO add shimmer loader
                                      loadingMessage: snapshot.data.message);
                                  break;

                                case Status.ERROR:
                                  return Error(
                                    errorMessage: snapshot.data.message,
                                    onRetryPressed: () =>
                                        _bloc.fetchQueuesList(),
                                  );
                                  break;
                                case Status.COMPLETED:
                                  return Column(
                                      children: List<ReceptionCard>.from(
                                          snapshot
                                              .data.data
                                              .map(
                                                  (item) => ReceptionCard(item))
                                              .toList()));
                                  break;
                              }
                            } else {
                              log('No snapshot data for receptions');
                              return Text('dsg');
                            }
                            return Text('sgsDGzg');
                          }),
                      /*Column(
                        children: <Widget>[
                          ReceptionCard(Reception.fromJson(jsonDecode('''{
                "id": "FyKQeYVM8",
                "subscriber_id": "17dY6K8Hb",
                "starttime": "2020-06-28T20:00:00.000Z",
                "endtime": "2020-06-28T21:00:00.000Z",
                "slot": 15,
                "cust_per_slot": 1,
                "status": "UPCOMING"
            }'''))),
                          ReceptionCard(Reception.fromJson(jsonDecode('''{
    "counters": [
            {
                "id": "FyKQeYVM8",
                "subscriber_id": "17dY6K8Hb",
                "starttime": "2020-06-28T20:00:00.000Z",
                "endtime": "2020-06-28T21:00:00.000Z",
                "slot": 15,
                "cust_per_slot": 1,
                "status": "UPCOMING"
            },
            {
                "id": "pgXN_rw-0",
                "subscriber_id": "17dY6K8Hb",
                "starttime": "2020-06-28T18:00:00.000Z",
                "endtime": "2020-06-28T19:45:00.000Z",
                "slot": 15,
                "cust_per_slot": 3,
                "status": "UPCOMING"
            }
    ]
}''')["counters"][0])),
                        ],
                      ),*/
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ReceptionCard extends StatelessWidget {
  ReceptionCard(this.reception);
  final Reception reception;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: reception,
      child: Card(
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              Container(
                alignment: Alignment(-1, 0),
                child: Text(
                  DateFormat('MMMMEEEEd').format(reception.startTime),
                  style: TextStyle(fontSize: 24),
                ),
              ),
              Divider(),
              Container(
                child: Wrap(
                  spacing: 4.0, // gap between adjacent chips
                  runSpacing: 4.0, // gap between lines
                  children: reception
                      .createSlots()
                      .map((item) => SlotItem(item))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SlotItem extends StatelessWidget {
  SlotItem(this.slot);

  final Slot slot;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final Reception reception =
            Provider.of<Reception>(context, listen: false);
        final Subscriber subscriber =
            Provider.of<Subscriber>(context, listen: false);
        log('Reception Id:${reception.id}\nSubscriber id:${subscriber.id}\nSlot:${slot.startTime.toString()}-${slot.endTime.toString()}');
        Navigator.popAndPushNamed(context, AppointmentScreen.id, arguments: {
          "subscriber": subscriber,
          "reception": reception,
        });
      },
      child: Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            border: Border.all(width: 1, color: Colors.green[400])),
        child: Text(
          getTimeAmPm(slot.startTime) + '-' + getTimeAmPm(slot.endTime),
          style: TextStyle(
            color: Colors.green[800],
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class QueueItem extends StatelessWidget {
  final Queue queue;
  QueueItem(this.queue);

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
                            Text(getTimeAmPm(queue.startDateTime),
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
                          Text(getTimeAmPm(queue.endDateTime),
                              style: kBigTextStyle),
                          Text(getDate(queue.endDateTime),
                              style: kSmallTextStyle),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Already in queue', style: kSmallTextStyle),
                          Text('${queue.totalIssuedTokens}',
                              style: kBigTextStyle),
                          SizedBox(width: 10),
                          Text('People', style: kSmallTextStyle),
                        ],
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Container(
                            child: Text(
                                'Last Updated at\n${DateFormat('hh:mm aaa\nMMM d, yyyy\nEEE').format(queue.lastUpdate)}')),
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
//                                Navigator.push(
//                                    context,
//                                    MaterialPageRoute(
//                                        builder: (context) =>
//                                            TokenPage(queueId: queue.queueId)));
                                Navigator.pushNamed(context, TokenScreen.id,
                                    arguments: queue.queueId);
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
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
              ],
            ),
          ),
          /*Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
            ],
          ),*/
        ],
      ),
    );
  }
}

class QueuesDisplay extends StatelessWidget {
  final List<Queue> queues;
  QueuesDisplay(this.queues);

  @override
  Widget build(BuildContext context) {
    return queues != null && queues.length != 0
        ? ListView.builder(
            itemCount: queues.length,
            cacheExtent: 4,
            physics: const AlwaysScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) => QueueItem(queues[index]))
        : Text('No queues found');
  }
}

class SubscriberHeaderInfo extends StatelessWidget {
  final Subscriber subscriber;
  SubscriberHeaderInfo({this.subscriber});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(subscriber.name,
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Text(subscriber.category,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.black54,
            )),
        SizedBox(height: 10),
        Text(
          subscriber.address,
          style: TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.w400,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
