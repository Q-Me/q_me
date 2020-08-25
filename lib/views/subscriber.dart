import 'dart:collection';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qme/api/base_helper.dart';
import 'package:qme/api/kAPI.dart';
import 'package:qme/bloc/subscriber.dart';
import 'package:qme/constants.dart';
import 'package:qme/model/queue.dart';
import 'package:qme/model/reception.dart';
import 'package:qme/model/slot.dart';
import 'package:qme/model/subscriber.dart';
import 'package:qme/utilities/logger.dart';
import 'package:qme/utilities/time.dart';
import 'package:qme/views/appointment.dart';
import 'package:qme/views/slot_view.dart';
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
    logger.d('Opening subscriber for subscriber id:' + widget.subscriber.id);
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
      appBar: AppBar(
        leading: Container(
          padding:
              EdgeInsets.symmetric(vertical: 15, horizontal: appBarOffset / 2),
          width: w - appBarOffset * 2,
          color: Colors.transparent,
          alignment: Alignment(-1, -1),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: CircleAvatar(
              foregroundColor: Colors.white,
              backgroundColor: Colors.transparent,
              radius: 20,
              child: Icon(
                Icons.keyboard_backspace,
                size: 30,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ChangeNotifierProvider.value(
            value: _bloc,
            child: Column(
              children: <Widget>[
                SubscriberHeaderInfo(subscriber: widget.subscriber),
                SubscriberImages(),
                // Queues(),
                RaisedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      SlotView.id,
                      arguments:
                          SlotViewArguments(subscriberId: _bloc.subscriberId),
                    );
                  },
                  child: Text('Check Available slots'),
                ),
                Divider(),
                ReceptionsDisplay(),
                SizedBox(height: 20)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SubscriberImages extends StatelessWidget {
  const SubscriberImages({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ApiResponse<List<String>>>(
        stream: Provider.of<SubscriberBloc>(context).imageStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            switch (snapshot.data.status) {
              case Status.COMPLETED:
                if (snapshot.data.data.length == 0) {
                  logger.i('No images to display');
                  return Container();
                }
                List<String> imgs = snapshot.data.data
                    .map((e) => '$baseURL/user/displayimage/' + e)
                    .toList();
                logger.i(
                    'SubscriberBloc Access Token:${Provider.of<SubscriberBloc>(context).accessToken}');
                return SizedBox(
                  width: 600,
                  height: 300,
                  child: Carousel(
                    images: imgs.map((imgUrl) {
                      return CachedNetworkImage(
                        imageUrl: imgUrl,
                        fit: BoxFit.contain,
                        httpHeaders: {
                          HttpHeaders.authorizationHeader:
                              'Bearer ${Provider.of<SubscriberBloc>(context).accessToken}'
                        },
                      );
                    }).toList(),
                  ),
                );
                break;
              case Status.LOADING:
                return Loading(
                    // TODO add shimmer loader
                    loadingMessage: snapshot.data.message);
                break;
              case Status.ERROR:
                return Error(
                  errorMessage: snapshot.data.message,
                  onRetryPressed: () => Provider.of<SubscriberBloc>(context)
                      .fetchSubscriberDetails(),
                );
                break;
            }
          } else {
            log('no Snapshot data');
          }
          return Container();
        });
  }
}

class Queues extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SubscriberBloc _bloc = Provider.of<SubscriberBloc>(context);
    return StreamBuilder<ApiResponse<List<Queue>>>(
      stream: _bloc.queuesListStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          switch (snapshot.data.status) {
            case Status.COMPLETED:
              return QueuesDisplay(snapshot.data.data);
              break;
            case Status.LOADING:
              return Loading(
                  // TODO add shimmer loader
                  loadingMessage: snapshot.data.message);
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
    );
  }
}

class ReceptionsDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SubscriberBloc _bloc = Provider.of<SubscriberBloc>(context);
    return StreamBuilder<ApiResponse<List<Reception>>>(
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
                  onRetryPressed: () => _bloc.fetchReceptions(),
                );
                break;
              case Status.COMPLETED:
                List<Reception> receptions = snapshot.data.data;
                if (receptions.length == 0) {
                  return Text('No Receptions available.');
                } else
                  return Column(
                      children: List<ReceptionCard>.from(receptions
                          .map((item) => ReceptionCard(item))
                          .toList()));
                break;
            }
          } else {
            log('No snapshot data for receptions');
            return Text('No data for receptions');
          }
          return Text('sgsDGzg');
        });
  }
}

class ReceptionCard extends StatelessWidget {
  ReceptionCard(this.reception);
  final Reception reception;
  @override
  Widget build(BuildContext context) {
    return Provider.value(
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
            Provider.of<SubscriberBloc>(context, listen: false).subscriber;
        logger.i(
          'Selected\nReception Id:${reception.id}\n'
          'Subscriber id:${subscriber.id}\n'
          'Slot:\nStart:${slot.startTime.toString()}\n'
          'End:${slot.endTime.toString()}',
        );
        Navigator.pushNamed(context, AppointmentScreen.id, arguments: {
          "subscriber": subscriber,
          "reception": reception,
          "slot": slot,
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
