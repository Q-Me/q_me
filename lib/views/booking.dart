import 'dart:collection';
import 'dart:developer';

import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qme/widgets/calenderStrip.dart';

import '../api/base_helper.dart';
import '../bloc/queue.dart';
import '../constants.dart';
import '../model/queue.dart';
import '../model/subscriber.dart';
import '../utilities/time.dart';
import '../views/token.dart';
import '../widgets/error.dart';
import '../widgets/loader.dart';

class BookingScreen extends StatefulWidget {
  static const String id = '/booking';
  final Subscriber subscriber;
  BookingScreen({this.subscriber});
  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  double get w => MediaQuery.of(context).size.width;
  double get h => MediaQuery.of(context).size.height;
  final double appBarOffset = 10;

  QueuesBloc _bloc;

  @override
  void initState() {
    log('Opening queues for subscriber id:' + widget.subscriber.id);
    super.initState();
    _bloc = QueuesBloc(widget.subscriber.id);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bloc == null) {
      _bloc = QueuesBloc(widget.subscriber.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: SafeArea(
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
                    SubscriberHeaderInfo(subscriber: widget.subscriber),
                    // TODO put in the image carousel
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
                    CalStrip(),
                    Flexible(
                      child: RefreshIndicator(
                        // WIDGET bug https://github.com/flutter/flutter/issues/34990
                        onRefresh: () => _bloc.fetchQueuesList(),
                        child: StreamBuilder<ApiResponse<List<Queue>>>(
                          // Bug in rendering due to late api response
                          // Bug fix https://github.com/flutter/flutter/issues/16465#issuecomment-493698128
                          initialData: ApiResponse.completed([]),
                          stream: _bloc.queuesListStream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              switch (snapshot.data.status) {
                                case Status.LOADING:
                                  return Loading(
                                      loadingMessage: snapshot.data.message);
                                  break;
                                case Status.COMPLETED:
                                  return QueuesDisplay(snapshot.data.data);
                                  break;
                                case Status.ERROR:
                                  return Error(
                                    errorMessage: snapshot.data.message,
                                    onRetryPressed: () =>
                                        _bloc.fetchQueuesList(),
                                  );
                                  break;
                              }
                            } else {
                              log('no Snapshot data');
                            }
                            return Container();
                          },
                        ),
                      ),
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
