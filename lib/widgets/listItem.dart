import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:qme/api/kAPI.dart';
import 'package:qme/bloc/subscriber_bloc/subscriber_bloc.dart';
import 'package:qme/bloc/subscribersHome.dart';
import 'package:qme/model/subscriber.dart';
import 'package:qme/views/subscriber.dart';
import 'package:shimmer/shimmer.dart';

class SubscriberListItem extends StatelessWidget {
  final Subscriber subscriber;
  SubscriberListItem({@required this.subscriber});
  static const double imgHeight = 150.0, imgWidth = 150.0;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, SubscriberScreen.id,
              arguments: subscriber);
        },
        child: Row(
          children: <Widget>[
            Stack(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  child: CachedNetworkImage(
                    imageUrl: subscriber.imgURL != null
                        ? subscriber.imgURL
                        : 'https://dontwaitapp.co/img/bank1080.png',
                    httpHeaders: {
                      HttpHeaders.authorizationHeader:
                          'Bearer ${Provider.of<SubscribersBloc>(context).accessToken}'
                    },
                    height: SubscriberListItem.imgHeight,
                    width: SubscriberListItem.imgWidth,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[300],
                        highlightColor: Colors.grey[100],
                        child: Container(
                          width: SubscriberListItem.imgWidth,
                          height: SubscriberListItem.imgHeight,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        )),
                    errorWidget: (context, url, error) => Container(
                      width: SubscriberListItem.imgWidth,
                      height: SubscriberListItem.imgHeight,
                      child: Icon(Icons.error),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: subscriber.verified
                      ? Container(
                          decoration: BoxDecoration(
                            color: Colors.black26.withOpacity(0.5),
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          margin: EdgeInsets.all(5),
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            subscriber.verified ? 'Verified' : 'Unverified',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : Container(),
                ),
              ],
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Text(
                      subscriber.name,
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      maxLines: 2,
                    ),
                    Text(
                      subscriber.address,
                      maxLines: 3,
                      overflow: TextOverflow.clip,
                      style: TextStyle(fontSize: 18),
                    ),
                    Visibility(
                      visible: subscriber.distance != null &&
                          subscriber.distance.length > 0,
                      child: Row(
                        children: <Widget>[
                          Container(
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.location_on),
                                Text(subscriber.distance ?? ''),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
