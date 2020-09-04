import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:hive/hive.dart';
import 'package:qme/repository/user.dart';
import 'package:qme/utilities/logger.dart';
import 'package:qme/views/menu.dart';
import 'package:qme/views/myBookingsScreen.dart';
import 'package:qme/widgets/searchBox.dart';


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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  HomeHeader(),
                  ListView.builder(
                    itemCount: 6,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) => ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: 300),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        color: Colors.white,
                        child: CategoryBox(),
                      ),
                    ),
                  ),
                ],
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

class CategoryBox extends StatelessWidget {
  const CategoryBox({
    Key key,
  }) : super(key: key);

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
                'Premium Salons',
                style: Theme.of(context).textTheme.headline6,
              ),
              Icon(Icons.arrow_forward)
            ],
          ),
        ),
        Expanded(
          child: Container(
            child: ListView.builder(
              itemCount: 6,
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  // width: 100,
                  // height: 50,
                  // color: Colors.red,
                  decoration: BoxDecoration(
                      /* boxShadow: [
                      BoxShadow(
                        offset: Offset(10, 0),
                        spreadRadius: 10,
                        blurRadius: 5,
                        color: Colors.black26,
                      )
                    ], */
                      ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        child: CachedNetworkImage(
                          imageUrl:
                              'https://firebasestorage.googleapis.com/v0/b/q-me-user.appspot.com/o/assets%2Fimages%2Flogo512x512.jpeg?alt=media&token=020809bb-b845-4d42-8f3c-f401560db688',
                          fit: BoxFit.cover,
                          width: 230,
                          height: 180,
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
                            bottomLeft: Radius.circular(10.0),
                            bottomRight: Radius.circular(10.0),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              'sfgsgdgsg',
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                            Text(
                              '1234567890123456789012345678901234567890',
                              maxLines: 1,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2
                                  .copyWith(color: Colors.grey),
                            ),
                            // Text('sdgg'),
                            Row(
                              children: [
                                RatingBarIndicator(
                                  itemSize: 15,
                                  direction: Axis.horizontal,
                                  itemCount: 5,
                                  rating: 3.0,
                                  itemPadding:
                                      EdgeInsets.symmetric(horizontal: 1.0),
                                  itemBuilder: (context, _) => Icon(
                                    Icons.star,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  // onRatingUpdate: (double value) {},
                                ),
                                SizedBox(width: 10),
                                Text(
                                  '4.5/5',
                                  style: TextStyle(
                                    fontSize: 11,
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
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
              child: const Text(
                'Hi!',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
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

class DateTile extends StatelessWidget {
  final int index;
  final context;

  DateTile(this.context, this.index);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.grey[100],
      ),
      height: 80,
      width: 60,
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Spacer(
            flex: 1,
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Tue',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              '${index % 31 + 1}',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
