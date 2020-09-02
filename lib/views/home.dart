import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:qme/api/base_helper.dart';
import 'package:qme/bloc/subscribersHome.dart';
import 'package:qme/model/subscriber.dart';
import 'package:qme/repository/user.dart';
import 'package:qme/utilities/logger.dart';
import 'package:qme/views/menu.dart';
import 'package:qme/views/myBookingsScreen.dart';
import 'package:qme/widgets/listItem.dart';

import '../widgets/error.dart';
import '../widgets/headerHome.dart';
import '../widgets/loader.dart';

class HomeScreenArguments {
  final int selectedIndex;

  const HomeScreenArguments({this.selectedIndex});
}

class HomeScreen extends StatefulWidget {
  static const id = '/home';
  final HomeScreenArguments args;
  const HomeScreen({
    Key key,
    this.args = const HomeScreenArguments(selectedIndex: 0),
  }) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageController pageController;
  SubscribersBloc _bloc;
  bool _enabled;
  int _selectedIndex;

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
    _selectedIndex = widget.args.selectedIndex;
    pageController = PageController(
      initialPage: _selectedIndex,
    );

    _bloc = SubscribersBloc();
    _enabled = true;
    super.initState();
    firebaseCloudMessagingListeners();
    _messaging.getToken().then((token) {
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
    final offset = MediaQuery.of(context).size.width / 20;
    return SafeArea(
      child: Scaffold(
        body: PageView(
            controller: pageController,
            onPageChanged: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            children: <Widget>[
              SingleChildScrollView(
                physics: ScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: offset),
                  child: ChangeNotifierProvider.value(
                    value: _bloc,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Header(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                const Text(
                                  'Hello!',
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                    'Let\'s save some of your time and effort.'),
                                const SizedBox(height: 10),
                                /*SearchBox(),*/
                                /*
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        child: Badges(),
                      ),
                      */
                              ],
                            ),
                            Container(
                              child: const Text(
                                'Saloons in Patna',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            _bloc.subscriberList != null &&
                                    _bloc.subscriberList.length != 0
                                ? ListView.builder(
                                    itemCount: _bloc.subscriberList.length,
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) =>
                                        SubscriberListItem(
                                      subscriber: _bloc.subscriberList[index],
                                    ),
                                  )
                                : StreamBuilder<ApiResponse<List<Subscriber>>>(
                                    stream: _bloc.subscribersListStream,
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        switch (snapshot.data.status) {
                                          case Status.LOADING:
                                            return ShimmerListLoader(_enabled);
                                            break;
                                          case Status.COMPLETED:
                                            _enabled = false;
                                            if (_bloc.subscriberList.length ==
                                                0) {
                                              return Text(
                                                'Sorry. We found nothing as per your search.',
                                                maxLines: 3,
                                                overflow: TextOverflow.clip,
                                                style: TextStyle(fontSize: 18),
                                              );
                                            } else {
                                              return ListView.builder(
                                                itemCount:
                                                    _bloc.subscriberList.length,
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                itemBuilder: (context, index) =>
                                                    Provider.value(
                                                  value: _bloc.accessToken,
                                                  child: SubscriberListItem(
                                                    subscriber: _bloc
                                                        .subscriberList[index],
                                                  ),
                                                ),
                                              );
                                            }
                                            break;
                                          case Status.ERROR:
                                            return Error(
                                              errorMessage:
                                                  snapshot.data.message,
                                              onRetryPressed: () =>
                                                  _bloc.fetchSubscribersList(),
                                            );
                                            break;
                                          default:
                                            return Text(
                                                'Has data but it is invalid');
                                        }
                                      } else {
                                        return Text('No snapshot data');
                                      }
                                    },
                                  ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // AppointmentsHistoryScreen()
              BookingsScreen(),
              // Column(
              //   children: <Widget>[
              //     Text('Your appointment history'),
              //     Text('Hello'),
              //   ],
              // ),
              MenuScreen(),
            ]),
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
