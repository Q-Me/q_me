import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:qme/api/base_helper.dart';
import 'package:qme/bloc/home_bloc/home_bloc.dart';
import 'package:qme/model/subscriber.dart';
import 'package:qme/repository/user.dart';
import 'package:qme/utilities/logger.dart';
import 'package:qme/views/menu.dart';
import 'package:qme/views/myBookingsScreen.dart';
import 'package:qme/views/signin.dart';
import 'package:qme/views/subscriber.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';

final borderRadius = Radius.circular(20);

class HomeScreen extends StatefulWidget {
  static const id = '/home';
  const HomeScreen({Key key}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageController pageController;
  int _selectedIndex = 0;
  Box indexOfPage;
  final ValueNotifier<int> _counter =
      ValueNotifier<int>(Hive.box("counter").get("counter"));

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      indexOfPage.put("index", index);
      pageController.animateToPage(index,
          duration: Duration(milliseconds: 500), curve: Curves.ease);
      // logger.d('Navigation bar index: $_selectedIndex');
    });
  }

  final FirebaseMessaging _messaging = FirebaseMessaging();
  String _fcmToken;

  @override
  void initState() {
    indexOfPage = Hive.box("index");
    _selectedIndex = indexOfPage.get("index");
    pageController = PageController(
      initialPage: _selectedIndex ?? 0,
    );
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
      // logger.i(token);
    });

    _messaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        //showNotification(message['notification']);
        setState(() {
          logger.i('on message $message');
        });
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
    return WillPopScope(
      onWillPop: () {
        if (_selectedIndex != 0) {
          pageController.animateToPage(0,
              duration: Duration(milliseconds: 500), curve: Curves.ease);
          return Future.value(false);
        } else {
          return Future.value(true);
        }
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: PageView(
            controller: pageController,
            onPageChanged: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            children: <Widget>[
              HomeScreenPage(),
              BookingsScreen(controller: pageController),
              MenuScreen(controller: pageController),
            ],
          ),
          bottomNavigationBar: CupertinoTabBar(
            currentIndex: _selectedIndex ?? 0,
            onTap: _onItemTapped,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.home)),
              BottomNavigationBarItem(
                icon: Hive.box("counter").get("counter") > 0
                    ? Stack(
                        children: <Widget>[
                          Icon(Icons.timer),
                          /* Positioned(
                            right: 0,
                            child: new Container(
                              padding: EdgeInsets.all(1),
                              decoration: new BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              constraints: BoxConstraints(
                                minWidth: 12,
                                minHeight: 12,
                              ),
                              /*  child: new Text(
                                '${Hive.box("counter").get("counter")}',
                                style: new TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                ),
                                textAlign: TextAlign.center,
                              ), */
                            ),
                          ) */
                        ],
                      )
                    : Icon(Icons.timer),
              ),
              BottomNavigationBarItem(icon: Icon(Icons.person)),
            ],
            activeColor: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }
}

class HomeScreenPage extends StatelessWidget {
  const HomeScreenPage({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: BlocProvider(
        create: (context) {
          HomeBloc bloc = HomeBloc();
          bloc.add(GetCategories());
          return bloc;
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            HomeHeader(
              child: Column(
                children: [
                  OfferCarousal(),
                  BlocConsumer<HomeBloc, HomeState>(
                    listener: (context, state) {
                      if (state is HomeFail) {
                        if (state.msg.startsWith('Unauthorised')) {
                          Navigator.pushReplacementNamed(
                              context, SignInScreen.id);
                        }
                      }
                    },
                    builder: (context, state) {
                      if (state is HomeLoading) {
                        return Container(
                          color: Colors.white,
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(state.msg ?? 'Loading..'),
                              CircularProgressIndicator(),
                            ],
                          ),
                        );
                      } else if (state is PartCategoryReady) {
                        List<CategorySubscriberList> categoryList =
                            state.categoryList;
                        return Column(
                          children: [
                            ReadySubscribersCategoriesList(
                              categoryList: categoryList,
                            ),
                            CircularProgressIndicator(),
                          ],
                        );
                      } else if (state is CategorySuccess) {
                        List<CategorySubscriberList> categoryList =
                            state.categoryList;
                        return ReadySubscribersCategoriesList(
                          categoryList: categoryList,
                        );
                      } else {
                        return Text('Underminedstate');
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OfferCarousal extends StatelessWidget {
  OfferCarousal({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance.collection("offers").snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }
        if (snapshot.connectionState == ConnectionState.done ||
            snapshot.connectionState == ConnectionState.active) {
          return SizedBox(
            height: 200.0,
            width: MediaQuery.of(context).size.width - 20,
            child: Carousel(
              onImageTap: (index) {
                logger.i('tapped image is at index $index');
              },
              dotBgColor: Colors.transparent,
              images: snapshot.data.documents.map((DocumentSnapshot offer) {
                return ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  child: CachedNetworkImage(
                    imageUrl: offer.data["imgUrl"].toString(),
                    height: 200,
                    progressIndicatorBuilder: (context, url, progress) =>
                        ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 20,
                        maxWidth: 20,
                      ),
                      child: CircularProgressIndicator(),
                    ),
                    fit: BoxFit.fill,
                  ),
                );
              }).toList(),
            ),
          );
        }
        return Text("loading");
      },
    );
  }
}

class ReadySubscribersCategoriesList extends StatelessWidget {
  const ReadySubscribersCategoriesList({
    Key key,
    @required this.categoryList,
  }) : super(key: key);

  final List<CategorySubscriberList> categoryList;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: categoryList.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        color: Colors.white,
        child: CategoryBox(categoryList[index]),
      ),
    );
  }
}

class CategoryBox extends StatelessWidget {
  const CategoryBox(
    this.categorySubscriberList, {
    Key key,
  }) : super(key: key);

  final CategorySubscriberList categorySubscriberList;

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
                categorySubscriberList.categoryName,
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
        categorySubscriberList.subscribers.length != 0
            ? ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 250),
                child: Container(
                  child: ListView.builder(
                    itemCount: categorySubscriberList.subscribers.length,
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return SubscriberBox(
                        categorySubscriberList.subscribers[index],
                      );
                    },
                  ),
                ),
              )
            : Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                alignment: Alignment.centerLeft,
                child: Text('Coming soon'),
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
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          SubscriberScreen.id,
          arguments: subscriber,
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(borderRadius),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: borderRadius,
                topRight: borderRadius,
              ),
              child: ValueListenableBuilder(
                valueListenable: Hive.box('user').listenable(
                  keys: ['accessToken'],
                ),
                builder: (context, box, widget) => CachedNetworkImage(
                  imageUrl: subscriber.imgURL,
                  fit: BoxFit.cover,
                  httpHeaders: {
                    HttpHeaders.authorizationHeader:
                        bearerToken(box.get('accessToken'))
                  },
                  placeholder: (context, url) {
                    return SizedBox(
                      width: 230,
                      height: 180,
                      child: Shimmer.fromColors(
                        baseColor: Colors.red,
                        highlightColor: Colors.yellow,
                        child: Container(),
                      ),
                    );
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
                  bottomLeft: borderRadius,
                  bottomRight: borderRadius,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Marquee(
                    directionMarguee: DirectionMarguee.oneDirection,
                    child: Text(
                      subscriber.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.subtitle1.copyWith(
                            fontStyle: GoogleFonts.nunito().fontStyle,
                            fontFamily: GoogleFonts.nunito().fontFamily,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  Text(
                    subscriber.shortAddress,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: Theme.of(context)
                        .textTheme
                        .subtitle2
                        .copyWith(color: Colors.grey),
                  ),
                  SubscriberRating(subscriber: subscriber)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SubscriberRating extends StatelessWidget {
  const SubscriberRating({
    Key key,
    @required this.subscriber,
  }) : super(key: key);

  final Subscriber subscriber;

  @override
  Widget build(BuildContext context) {
    return Opacity(
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
            '${subscriber.rating}/5.0',
            style: TextStyle(
              fontSize: 11,
            ),
          )
        ],
      ),
    );
  }
}

class HomeHeader extends StatelessWidget {
  final Widget child;
  const HomeHeader({Key key, @required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Theme.of(context).primaryColor,
          child: Column(
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
              // const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.only(top: 30),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: borderRadius,
                    topRight: borderRadius,
                  ),
                ),
                child: child,
              ),
            ],
          ),
        ),
        // Positioned(top: 80, child: SearchBox()),
      ],
    );
  }
}
