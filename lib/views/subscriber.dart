import 'dart:collection';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:icon_shadow/icon_shadow.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qme/api/base_helper.dart';
import 'package:qme/api/kAPI.dart';
import 'package:qme/bloc/subscriber.dart';
import 'package:qme/bloc/subscriber_bloc/subscriber_bloc.dart';
import 'package:qme/constants.dart';
import 'package:qme/model/queue.dart';
import 'package:qme/model/reception.dart';
import 'package:qme/model/review.dart';
import 'package:qme/model/slot.dart';
import 'package:qme/model/subscriber.dart';
import 'package:qme/model/user.dart';
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

  const SubscriberScreen({Key key, this.subscriber}) : super(key: key);

  @override
  _SubscriberScreenState createState() => _SubscriberScreenState();
}

class _SubscriberScreenState extends State<SubscriberScreen> {
  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
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
        body: Stack(alignment: AlignmentDirectional.bottomEnd, children: [
          BlocBuilder<SubscriberBloc, SubscriberState>(
            builder: (context, state) {
              if (state is SubscriberLoading) {
                return Positioned(
                    top: 0,
                    child: Container(
                        height: h * 0.45,
                        width: w,
                        child: Center(child: CircularProgressIndicator())));
              }
              if (state is SubscriberReady) {
                BlocProvider.of<SubscriberBloc>(context)
                    .add(FetchReviewEvent(subscriber: widget.subscriber));
                return Positioned(
                  top: 0,
                  child: Container(
                    height: h * 0.45,
                    width: MediaQuery.of(context).size.width,
                    child: SubscriberImages(
                      images: state.images,
                    ),
                  ),
                );
              }
              if (state is SubscriberScreenReady) {
                return Positioned(
                  top: 0,
                  child: Container(
                    height: h * 0.45,
                    width: MediaQuery.of(context).size.width,
                    child: SubscriberImages(
                      images: state.images,
                    ),
                  ),
                );
              }
              if (state is SubscriberError) {
                return Error(
                  errorMessage: state.error,
                  onRetryPressed: () => BlocProvider.of<SubscriberBloc>(context)
                      .add(ProfileInitialEvent(subscriber: widget.subscriber)),
                );
              } else {
                return Container();
              }
            },
          ),
          Positioned(
            bottom: 0,
            child: Container(
              height: h * 0.6,
              padding: EdgeInsets.all(20),
              width: w,
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
                        width: w / 3.5,
                        height: w / 13,
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
                          arguments:
                              SlotViewArguments(subscriber: widget.subscriber));
                    },
                    icon: Icon(
                      Icons.message,
                      color: Colors.white,
                    ),
                    label: Container(
                      height: w / 8,
                      width: w / 1.6,
                      padding: EdgeInsets.all(10),
                      child: Row(
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
                  BlocBuilder<SubscriberBloc, SubscriberState>(
                    builder: (context, state) {
                      if (state is SubscriberLoading) {
                        return Container(
                          height: 50,
                          width: 50,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (state is SubscriberReady) {
                        return Container(
                          height: 50,
                          width: 50,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (state is SubscriberScreenReady) {
                        return SubscriberReviews(
                          reviews: state.review,
                        );
                      }
                      if (state is SubscriberError) {
                        return Container();
                      } else {
                        return Container();
                      }
                    },
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
        ]));
  }
}

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
  const SubscriberImages({Key key, @required this.images, this.accessToken})
      : super(key: key);
  final List<String> images;
  final String accessToken;

  @override
  Widget build(BuildContext context) {
    if (images.length == 0) {
      logger.i('No images to display');
      return Container();
    }
    List<String> imgs =
        images.map((e) => '$baseURL/user/displayimage/' + e).toList();
    logger.i('SubscriberBloc Access Token:$accessToken');
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
              HttpHeaders.authorizationHeader: 'Bearer $accessToken'
            },
          );
        }).toList(),
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

class SubscriberReviews extends StatelessWidget {
  const SubscriberReviews({
    this.reviews,
    Key key,
  }) : super(key: key);
  final List<Review> reviews;
  @override
  Widget build(BuildContext context) {
    print(reviews.length);
    return reviews.length == 0
        ? Center(
            child: Text('No ratings to show'),
          )
        : ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final Review review = reviews[index];
              return ListTile(
                title: Text(review.custName),
                leading: RatingBar(
                  itemSize: 12,
                  initialRating: review.rating.toDouble(),
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
                subtitle: Text(review.review),
              );
            });
  }
}
