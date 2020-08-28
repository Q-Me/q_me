import 'dart:collection';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:icon_shadow/icon_shadow.dart';
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

class SubscriberHeaderInfo extends StatelessWidget {
  final Subscriber subscriber;
  SubscriberHeaderInfo({this.subscriber});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${subscriber.name}",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          "${subscriber.address}",
          textAlign: TextAlign.left,
        ),
      ],
    );
  }
}

class SubscriberServices extends StatelessWidget {
  final Subscriber subscriber;

  const SubscriberServices({Key key, this.subscriber}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 2,
          width: MediaQuery.of(context).size.width,
          color: Colors.grey,
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Text('Unisex Saloon'),
                Text('Free Shampoo'),
                Text(subscriber.description == "NULL"
                    ? " "
                    : "${subscriber.description}")
              ],
            ),
            Text("learn more")
          ],
        ),
      ],
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
                  width: 10,
                  height: 50,
                  child: Carousel(
                    showIndicator: false,
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

class SubscriberScreen extends StatefulWidget {
  static const String id = '/booking';
  final Subscriber subscriber;

  const SubscriberScreen({Key key, this.subscriber}) : super(key: key);

  @override
  _SubscriberScreenState createState() => _SubscriberScreenState();
}

class _SubscriberScreenState extends State<SubscriberScreen> {
  SubscriberBloc _bloc;

  @override
  void initState() {
    logger.d('Opening queues for subscriber id:' + widget.subscriber.id);
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
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButton: IconButton(
          icon: IconShadowWidget(
            Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            shadowColor: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          }),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: ChangeNotifierProvider.value(
          value: _bloc,
          child: Stack(
            alignment: AlignmentDirectional.bottomEnd,
            children: [
              Positioned(
                top: 0,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.45,
                  width: MediaQuery.of(context).size.width,
                  child: SubscriberImages(),
                ),
              ),
              Positioned(
                bottom: 0,
                child: SingleChildScrollView(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.6,
                    padding: EdgeInsets.all(20),
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SubscriberHeaderInfo(
                              subscriber: widget.subscriber,
                            ),
                            Container(
                              padding: EdgeInsets.all(5),
                              width: MediaQuery.of(context).size.width / 3.5,
                              height: MediaQuery.of(context).size.width / 13,
                              child: SubscriberStarRating(
                                subscriber: widget.subscriber,
                              ),
                            )
                          ],
                        ),
                        SubscriberServices(subscriber: widget.subscriber),
                        RaisedButton.icon(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                          onPressed: () {
                            log('Navigating to subscriber id:${widget.subscriber.id}');
                            Navigator.pushNamed(context, SlotView.id,
                                arguments: SlotViewArguments(
                                    subscriber: widget.subscriber));
                          },

                          icon: Icon(
                            Icons.message,
                            color: Colors.white,
                          ),
                          label: Container(
                            height: MediaQuery.of(context).size.width / 8,
                            width: MediaQuery.of(context).size.width / 1.6,
                            padding: EdgeInsets.all(10),
                            child: Row(
                              // mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'Check availible slots',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                          ),

                          color: Color(0xFF084ff2),
                          //   width: MediaQuery.of(context).size.width / 1.4,
                          //   height: MediaQuery.of(context).size.width / 9,
                          //   decoration: BoxDecoration(
                          //       borderRadius: BorderRadius.circular(18)),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Ratings and Reviews',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            Icon(Icons.arrow_forward)
                          ],
                        ),
                        Placeholder(
                          fallbackWidth: 200,
                          fallbackHeight: 50,
                        )
                      ],
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20)),
                    ),
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

class SubscriberStarRating extends StatelessWidget {
  const SubscriberStarRating({
    this.subscriber,
    Key key,
  }) : super(key: key);
  final Subscriber subscriber;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        subscriber.rating == null
            ? Container()
            : RatingBar(
                itemSize: 15,
                initialRating: subscriber.rating.toDouble(),
                minRating: 0,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: EdgeInsets.symmetric(horizontal: 1.0),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.black,
                ),
                onRatingUpdate: (double value) {},
              ),
      ],
    );
  }
}
