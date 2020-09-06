import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:hive/hive.dart';
import 'package:qme/api/base_helper.dart';
import 'package:qme/bloc/home_bloc/home_bloc.dart';
import 'package:qme/model/subscriber.dart';
import 'package:qme/repository/user.dart';
import 'package:qme/utilities/logger.dart';
import 'package:qme/views/menu.dart';
import 'package:qme/views/myBookingsScreen.dart';
import 'package:qme/widgets/searchBox.dart';
import 'package:hive_flutter/hive_flutter.dart';

final jsonString = {
  "id": "nplhS-7cJ",
  "name": "Piyush Saloon",
  "description": "NULL",
  "owner": "Mr. A",
  "email": "piyush@gmail.com",
  "phone": "+919876543210",
  "address": "Mumbai",
  "longitude": 0,
  "latitude": 0,
  "category": "Beauty & Wellness",
  "tags": null,
  "profileImage": "Beauty & Wellness.png",
  "verified": 0,
  "rating": 3.7,
  "displayImages": ["nplhS-7cJ_1.jpeg"]
};
final subscriber = Subscriber.fromJson(jsonString);

class HomeScreen extends StatefulWidget {
  static const id = '/home';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageController pageController;
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      pageController.animateToPage(index,
          duration: Duration(milliseconds: 500), curve: Curves.ease);
      logger.d('Navigation bar index: $_selectedIndex');
    });
  }

  final FirebaseMessaging _messaging = FirebaseMessaging();
  String _fcmToken;

  @override
  void initState() {
    pageController = PageController(
      initialPage: 0,
    );
    super.initState();
    firebaseCloudMessagingListeners();
    _messaging.getToken().then((token) {
      logger.i("fcmToken: $token");
      _fcmToken = token;
      verifyFcmTokenChange(_fcmToken);
    });
  }

  void verifyFcmTokenChange(String _fcmToken) async {
    Box box = await Hive.openBox("user");
    String fcmToken = await box.get('fcmToken');
    if (fcmToken != _fcmToken) {
      await UserRepository().fcmTokenSubmit(_fcmToken);
      await box.put('fcmToken', _fcmToken);
      logger.i("FCM toke updated from $fcmToken\nto: $_fcmToken");
    }
  }

  void firebaseCloudMessagingListeners() {
    if (Platform.isIOS) iosPermission();

    _messaging.getToken().then((token) {
      logger.i(token);
    });

    _messaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        //showNotification(message['notification']);
        logger.i('on message $message');
      },
      onResume: (Map<String, dynamic> message) async {
        logger.i('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        logger.i('on launch $message');
      },
    );
  }

  void iosPermission() {
    _messaging.requestNotificationPermissions(
      IosNotificationSettings(sound: true, badge: true, alert: true),
    );
    _messaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      logger.i("Settings registered: $settings");
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: PageView(
          controller: pageController,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          children: <Widget>[
            SingleChildScrollView(
              child: BlocProvider(
                create: (context) {
                  HomeBloc bloc = HomeBloc();
                  bloc.add(GetCategories());
                  return bloc;
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    HomeHeader(),
                    BlocBuilder<HomeBloc, HomeState>(
                      builder: (context, state) {
                        if (state is HomeLoading) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(state.msg),
                              CircularProgressIndicator(),
                            ],
                          );
                        } else if (state is CategorySuccess) {
                          return ListView.builder(
                            itemCount: state.categoryList.length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) => ConstrainedBox(
                              constraints: BoxConstraints(maxHeight: 300),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                color: Colors.white,
                                child: CategoryBox(state.categoryList[index]),
                              ),
                            ),
                          );
                        } else {
                          return Text('Undetermined state');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            BookingsScreen(),
            MenuScreen(),
          ],
        ),
        bottomNavigationBar: CupertinoTabBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home)),
            BottomNavigationBarItem(icon: Icon(Icons.timer)),
            BottomNavigationBarItem(icon: Icon(Icons.person)),
          ],
        ),
      ),
    );
  }
}

class CategoryBox extends StatefulWidget {
  const CategoryBox(
    this.categorySubscriberList, {
    Key key,
  }) : super(key: key);

  final CategorySubscriberList categorySubscriberList;

  @override
  _CategoryBoxState createState() => _CategoryBoxState();
}

class _CategoryBoxState extends State<CategoryBox> {
  ScrollController scrollController;

  @override
  void initState() {
    scrollController = ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.categorySubscriberList.categoryName,
                style: Theme.of(context).textTheme.headline6,
              ),
              GestureDetector(
                onTap: () {
                  logger.d('Tapped');
                  /* scrollController.animateTo(
                    300,
                    duration: Duration(milliseconds: 200),
                    curve: Curves.ease,
                  ); */
                },
                child: Icon(Icons.arrow_forward),
              )
            ],
          ),
        ),
        Expanded(
          child: Container(
            child: ListView.builder(
              itemCount: widget.categorySubscriberList.subscribers.length,
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              controller: scrollController,
              itemBuilder: (context, index) {
                return SubscriberBox(
                    widget.categorySubscriberList.subscribers[index]);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class SubscriberBox extends StatelessWidget {
  const SubscriberBox(
    this.subscriber, {
    Key key,
  }) : super(key: key);
  final Subscriber subscriber;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: ValueListenableBuilder(
              valueListenable: Hive.box('user').listenable(),
              builder: (context, box, widget) => CachedNetworkImage(
                imageUrl: subscriber.imgURL,
                fit: BoxFit.cover,
                httpHeaders: {
                  HttpHeaders.authorizationHeader:
                      bearerToken(box.get('accessToken'))
                },
                width: 230,
                height: 180,
              ),
            ),
          ),
          Container(
            width: 230,
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.black26,
                width: 1.0,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  subscriber.name,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                Text(
                  subscriber.address,
                  maxLines: 1,
                  style: Theme.of(context)
                      .textTheme
                      .subtitle2
                      .copyWith(color: Colors.grey),
                ),
                Opacity(
                  opacity: subscriber.rating <= 0.0 ? 0 : 1,
                  child: Row(
                    children: [
                      RatingBarIndicator(
                        itemSize: 15,
                        direction: Axis.horizontal,
                        itemCount: 5,
                        rating: subscriber.quantizedRating,
                        itemPadding: EdgeInsets.symmetric(horizontal: 1.0),
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: Theme.of(context).primaryColor,
                        ),
                        // onRatingUpdate: (double value) {},
                      ),
                      SizedBox(width: 10),
                      Text(
                        '${subscriber.rating}/5',
                        style: TextStyle(
                          fontSize: 11,
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ValueListenableBuilder(
                valueListenable: Hive.box('user').listenable(keys: ['name']),
                builder: (context, box, widget) {
                  final String fullName = box.get('name');
                  return Text(
                    'Hi ${fullName.split(" ").elementAt(0)}!',
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                ),
              ),
            )
          ],
        ),
        Positioned(
          top: 80,
          child: SearchBox(),
        ),
      ],
    );
  }
}
