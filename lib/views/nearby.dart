import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../bloc/subscriber.dart';
import '../model/subscriber.dart';
import 'booking.dart';
import '../widgets/CustomIcons.dart';
import '../widgets/text.dart';
import '../api/base_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/loader.dart';
import '../widgets/error.dart';

class MyAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // TODO Extend the
      child: Container(
//        color: Colors.green,
//        height: 30,
        padding: EdgeInsets.symmetric(horizontal: 25),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.menu,
                size: 30,
              ),
            ), // TODO Update broken menu icon
            Text(
              'Q Me',
              style: TextStyle(
                fontSize: 30,
              ), //TODO Change font style
            ),
            Row(
              children: <Widget>[
                Icon(Icons.check_box_outline_blank),
//                Icon(Icons.map),

                // TODO When Map view is added add this icon
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class NearbyScreenScroll extends StatelessWidget {
  static String id = 'nearby_category_h_scroll';

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(statusBarColor: Colors.transparent),
      child: Scaffold(
//      appBar: AppBar(
//        elevation: 0,
//        backgroundColor: Colors.transparent,
//        automaticallyImplyLeading: false,
//        bottom: PreferredSize(
//          preferredSize: Size(40, 40),
//          child: SafeArea(
//            child: Text('wrhg'),
//          ),
//        ),
////        flexibleSpace: Text('war'),
//      ),
        appBar: PreferredSize(
          preferredSize: Size(double.infinity, 100),
          child: Material(
            elevation: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    spreadRadius: 5,
                    blurRadius: 2,
                  )
                ],
              ),
              width: MediaQuery.of(context).size.width,
              height: 100,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20)),
                ),
                child: Container(
                  color: Colors.transparent,
                  margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(width: 20),
                      Icon(
                        CustomIcons.menu,
                        size: 32,
                        color: Colors.white,
                      ),
                      Spacer(),
                      Text(
                        "Q Me",
                        style: TextStyle(fontSize: 30, color: Colors.white),
                      ),
                      Spacer(),
                      Icon(
                        Icons.more_vert,
                        size: 32,
                        color: Colors.white,
                      ),
                      SizedBox(width: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
//          color: Colors.red,
          child: Container(
            decoration: BoxDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
//                MyAppBar(),
//              Container(
//                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
//                child: Text(
//                  'Browse Nearby.',
//                  style: TextStyle(fontSize: 40),
//                ),
//              ),
                Container(
                  padding: EdgeInsets.only(left: 30, top: 18),
                  child: ThemedText(
                    words: ['Explore Nearby'],
                    fontSize: 35,
                  ),
                ),
                HorizontalScrollHolder(title: 'Grocery Stores'),
                HorizontalScrollHolder(
                  title: 'Banks',
                ),
                HorizontalScrollHolder(
                  title: 'Medical Stores',
                ),
                HorizontalScrollHolder(
                  title: 'Doctors',
                ),
                SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HorizontalScrollHolder extends StatelessWidget {
  final String title;
  HorizontalScrollHolder({this.title});
  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Container(
        alignment: Alignment(-1, 0),
        padding: EdgeInsets.fromLTRB(30, 15, 30, 8),
        child: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 26),
        ),
      ),
      Container(
        height: 200,
        child: ListView.builder(
            itemCount: 3,
//          shrinkWrap: true,
//          physics: ClampingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return SubscriberTile(index);
            }),
      ),
    ]);
  }
}

class SubscriberTile extends StatelessWidget {
  // TODO Add shadow to this container
  final int index;
  SubscriberTile(this.index);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: index == 0
          ? EdgeInsets.only(left: 12, right: 4)
          : EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, BookingScreen.id);
        },
        child: Stack(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
//              child: Image.network(
//                // TODO Cache this image
//                'https://images.pexels.com/photos/1659438/pexels-photo-1659438.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260',
////              height: 200,
//                width: 150,
//                fit: BoxFit.cover,
//              ),
              child: CachedNetworkImage(
                placeholder: (context, url) => CircularProgressIndicator(),
                height: 200,
                width: 150,
                fit: BoxFit.cover,
                imageUrl:
                    'https://images.pexels.com/photos/1659438/pexels-photo-1659438.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260',
              ),
            ),
            Container(
              padding: EdgeInsets.all(8),
              height: 200,
              width: 150,
              child: Column(
                children: <Widget>[
                  // New
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        decoration: BoxDecoration(
                            color: Colors.white54,
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          "New",
                          style: TextStyle(color: Colors.black45),
                        ),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        decoration: BoxDecoration(
                            color: Colors.white54,
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          "100m away",
                          style: TextStyle(color: Colors.black45),
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              child: Text(
                                "Anna Purna Store",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            // 12 tours
                            Text(
                              "New stock arrived",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                          ],
                        ),
                      ),
                      /*Column(
//                      crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white54,
                            ),
                            padding:
                                EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                            width: 30,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Text(
                                  '4.5',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                ),
                                Icon(
                                  Icons.star,
                                  size: 17,
                                  color: Colors.white,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),*/
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SubscriberGridTile extends StatelessWidget {
  final Subscriber subscriberData;
  final int index;
  SubscriberGridTile({this.subscriberData, this.index});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
          left: index % 2 == 0 ? 10 : 5,
          right: index % 2 != 0 ? 10 : 5,
          top: 5,
          bottom: 5),
      child: GestureDetector(
        onTap: () {
          log('From Nearby (SubscriberGridTile) Going to Subscriber id:${subscriberData.id}');
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookingScreen(subscriber: subscriberData),
              ));
        },
        child: Container(
          decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.all(Radius.circular(10))),
          padding: EdgeInsets.all(8),
          child: Column(
            children: <Widget>[
              // New
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(8)),
                    child: Text("New", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: Text(subscriberData.name,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20)),
                        ),
                        SizedBox(height: 8),
                        Text(subscriberData.owner,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            )),
                        SizedBox(height: 8),
                        Text(
                          subscriberData.address,
                          maxLines: 2,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*class NearbyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Subscriber> subs = getDummySubscriber().list;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(statusBarColor: Colors.transparent),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(double.infinity, 100),
          child: Material(
            elevation: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    spreadRadius: 5,
                    blurRadius: 2,
                  )
                ],
              ),
              width: MediaQuery.of(context).size.width,
              height: 100,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20)),
                ),
                child: Container(
                  color: Colors.transparent,
                  margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(width: 20),
                      Icon(
                        CustomIcons.menu,
                        size: 32,
                        color: Colors.white,
                      ),
                      Spacer(),
                      Text(
                        "Q Me",
                        style: TextStyle(fontSize: 30, color: Colors.white),
                      ),
                      Spacer(),
                      Icon(
                        Icons.refresh,
                        size: 32,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Icon(
                        Icons.more_vert,
                        size: 32,
                        color: Colors.white,
                      ),
                      SizedBox(width: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        body: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 30, top: 18),
              child: ThemedText(
                words: ['Explore Nearby'],
                fontSize: 35,
              ),
            ),
            Expanded(
              child: Container(
                child: GridView.builder(
                  itemCount: subs.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  itemBuilder: (BuildContext context, int index) {
                    //if (index < 50)
                    return SubscriberGridTile(
                      index: index,
                      data: subs[index],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}*/

class NearbyScreen extends StatefulWidget {
  static String id = 'nearby_grid';

  @override
  _NearbyScreenState createState() => _NearbyScreenState();
}

class _NearbyScreenState extends State<NearbyScreen> {
  SubscribersBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = SubscribersBloc();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(statusBarColor: Colors.transparent),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(double.infinity, 100),
          child: Material(
            elevation: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    spreadRadius: 5,
                    blurRadius: 2,
                  )
                ],
              ),
              width: MediaQuery.of(context).size.width,
              height: 100,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20)),
                ),
                child: Container(
                  color: Colors.transparent,
                  margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(width: 20),
                      Icon(CustomIcons.menu, size: 32, color: Colors.white),
                      Spacer(),
                      Text("Q Me",
                          style: TextStyle(fontSize: 30, color: Colors.white)),
                      Spacer(),
                      Icon(
                        Icons.refresh,
                        size: 32,
                        color: Colors.white,
                      ),
                      SizedBox(width: 10),
                      Icon(
                        Icons.more_vert,
                        size: 32,
                        color: Colors.white,
                      ),
                      SizedBox(width: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        body: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 30, top: 18),
              child: ThemedText(
                words: ['Explore Nearby'],
                fontSize: 35,
              ),
            ),
            RefreshIndicator(
              onRefresh: () => _bloc.fetchSubscribersList(),
              child: StreamBuilder<ApiResponse<List<Subscriber>>>(
                stream: _bloc.subscribersListStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    switch (snapshot.data.status) {
                      case Status.LOADING:
                        return Loading(loadingMessage: snapshot.data.message);
                        break;
                      case Status.COMPLETED:
                        return SubscribersGrid(
                            subscriberList: snapshot.data.data);
                        break;
                      case Status.ERROR:
                        return Error(
                          errorMessage: snapshot.data.message,
                          onRetryPressed: () => _bloc.fetchSubscribersList(),
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
          ],
        ),
      ),
    );
  }
}

class SubscribersGrid extends StatelessWidget {
  final List<Subscriber> subscriberList;

  const SubscribersGrid({this.subscriberList});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: subscriberList.length,
      shrinkWrap: true,
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemBuilder: (context, index) => SubscriberGridTile(
          subscriberData: subscriberList[index], index: index),
    );
  }
}

/*
class SubscriberGridTile extends StatelessWidget {
  final Subscriber data;
  final int index;
  SubscriberGridTile({this.data, this.index});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
          left: index % 2 == 0 ? 10 : 5,
          right: index % 2 != 0 ? 10 : 5,
          top: 5,
          bottom: 5),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, BookingScreen.id,
              arguments: {'id': data.id});
        },
        child: Stack(
          children: <Widget>[
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
            ),
            Container(
              padding: EdgeInsets.all(8),
//              height: 200,
//              width: 150,
              child: Column(
                children: <Widget>[
                  // New
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(8)),
                        child:
                            Text("New", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              child: Text(
                                data.name,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              data.owner,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
*/
