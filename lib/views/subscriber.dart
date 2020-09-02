import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:icon_shadow/icon_shadow.dart';
import 'package:qme/bloc/subscriber_bloc/subscriber_bloc.dart';
import 'package:qme/model/review.dart';
import 'package:qme/model/subscriber.dart';
import 'package:qme/utilities/logger.dart';
import 'package:qme/views/slot_view.dart';
import 'package:qme/widgets/error.dart';

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
      floatingActionButton: BackButton(),
      body: BlocProvider<SubscriberBloc>(
        create: (context) {
          SubscriberBloc _bloc = SubscriberBloc(widget.subscriber);
          _bloc.add(ProfileInitialEvent(subscriber: widget.subscriber));
          return _bloc;
        },
        child: SingleChildScrollView(
          child: Column(children: [
            BlocBuilder<SubscriberBloc, SubscriberState>(
              builder: (context, state) {
                if (state is SubscriberLoading) {
                  return Container(
                      height: h * 0.4,
                      width: w,
                      child: Center(child: CircularProgressIndicator()));
                }
                if (state is SubscriberReady) {
                  BlocProvider.of<SubscriberBloc>(context)
                      .add(FetchReviewEvent(subscriber: widget.subscriber));
                  return Container(
                    height: h * 0.4,
                    width: MediaQuery.of(context).size.width,
                    child: SubscriberImages(
                        images: state.images, accessToken: state.accessToken),
                  );
                }
                if (state is SubscriberScreenReady) {
                  return Container(
                    height: h * 0.4,
                    width: MediaQuery.of(context).size.width,
                    child: SubscriberImages(
                      images: state.images,
                      accessToken: state.accessToken,
                    ),
                  );
                }
                if (state is SubscriberError) {
                  return Error(
                    errorMessage: state.error,
                    onRetryPressed: () =>
                        BlocProvider.of<SubscriberBloc>(context).add(
                            ProfileInitialEvent(subscriber: widget.subscriber)),
                  );
                } else {
                  return Text('Undetermined state');
                }
              },
            ),
            Container(
              padding: EdgeInsets.only(left: 20, right: 20, top: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  SubscriberHeaderInfo(widget.subscriber),
                  CheckAvailableSlotsButton(subscriber: widget.subscriber),
                  SizedBox(height: 10),
                  Divider(thickness: 3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ratings and Reviews',
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ],
                  ),
                  BlocBuilder<SubscriberBloc, SubscriberState>(
                    builder: (context, state) {
                      if (state is SubscriberLoading ||
                          state is SubscriberReady) {
                        return Container(
                          height: 50,
                          width: 50,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      } else if (state is SubscriberScreenReady) {
                        return SubscriberReviews(
                          reviews: state.review,
                        );
                      } else if (state is SubscriberError) {
                        return Error(
                          errorMessage: "Could Not Load Reviews",
                          onRetryPressed: () {
                            BlocProvider.of<SubscriberBloc>(context).add(
                                ProfileInitialEvent(
                                    subscriber: widget.subscriber));
                          },
                        );
                      } else {
                        return Text("Undefined State");
                      }
                    },
                  )
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class BackButton extends StatelessWidget {
  const BackButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
        icon: IconShadowWidget(
          Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          shadowColor: Colors.white,
        ),
        onPressed: () {
          Navigator.pop(context);
        });
  }
}

class CheckAvailableSlotsButton extends StatelessWidget {
  const CheckAvailableSlotsButton({
    Key key,
    @required this.subscriber,
  }) : super(key: key);

  final Subscriber subscriber;

  @override
  Widget build(BuildContext context) {
    return RaisedButton.icon(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.0),
      ),
      onPressed: () {
        log('Navigating to subscriber id:${subscriber.id}');
        Navigator.pushNamed(context, SlotView.id,
            arguments: SlotViewArguments(subscriber: subscriber));
      },
      icon: Icon(
        Icons.message,
        color: Colors.white,
      ),
      label: Container(
        child: Center(
          child: Text(
            'Check available slots',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      color: Theme.of(context).primaryColor,
    );
  }
}

class SubscriberHeaderInfo extends StatelessWidget {
  final Subscriber subscriber;
  SubscriberHeaderInfo(this.subscriber);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${subscriber.name}",
                  // style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  style: Theme.of(context).textTheme.headline6,
                ),
                SizedBox(height: 5),
                Container(
                  child: Text(
                    "${subscriber.address}",
                    textAlign: TextAlign.left,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.all(5),
              child: SubscriberStarRating(
                subscriber: subscriber,
              ),
            )
          ],
        ),
        SizedBox(height: 10),
        SubscriberServices(
          description: subscriber.description,
        ),
        SizedBox(height: 10),
      ],
    );
  }
}

class SubscriberServices extends StatelessWidget {
  final String description;

  const SubscriberServices({Key key, this.description}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(thickness: 3),
        description == ""
            ? Text(
                description,
                textAlign: TextAlign.left,
              )
            : Container(),
        // TODO Add services based on tags here
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
    // logger.i('SubscriberBloc Access Token:$accessToken');
    return SizedBox(
      width: 10,
      height: 50,
      child: Carousel(
        showIndicator: false,
        images: images.map((imgUrl) {
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
            : RatingBarIndicator(
                itemSize: 15,
                direction: Axis.horizontal,
                itemCount: 5,
                rating: subscriber.rating.toDouble(),
                itemPadding: EdgeInsets.symmetric(horizontal: 1.0),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.black,
                ),
                // onRatingUpdate: (double value) {},
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
    return reviews.length == 0
        ? Container(child: Center(child: Text('No ratings to show')))
        : ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final Review review = reviews[index];
              return ListTile(
                title: Row(
                  children: [
                    Icon(Icons.account_circle),
                    SizedBox(
                      width: 10,
                    ),
                    Text(review.custName),
                  ],
                ),
                trailing: RatingBarIndicator(
                  rating: review.rating,
                  itemSize: 12,
                  direction: Axis.horizontal,
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(horizontal: 1.0),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.black,
                  ),
                ),
                subtitle: Text(review.review == "NULL" ? "" : review.review),
              );
            });
  }
}
