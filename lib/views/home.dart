import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qme/api/base_helper.dart';
import 'dart:developer';
import 'package:qme/widgets/categories.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../bloc/subscriber.dart';
import '../model/subscriber.dart';
import './booking.dart';
import '../widgets/loader.dart';
import '../widgets/error.dart';

class HomeScreen extends StatefulWidget {
  static const id = '/home';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SubscribersBloc _bloc;

  @override
  void initState() {
    _bloc = SubscribersBloc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final offset = MediaQuery.of(context).size.width / 20;
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          physics: ScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: offset),
            child: ChangeNotifierProvider.value(
              value: _bloc,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
//                  SizedBox(width: offset),
                      GestureDetector(
                        onTap: () {
                          log('App drawer clicked');
                        },
                        child: Icon(Icons.menu, size: 45),
                      ),
                      Spacer(),
                      Container(
                        height: 80,
                        width: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(30),
                            bottomLeft: Radius.circular(30),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).primaryColor,
                              spreadRadius: 0,
                              blurRadius: 5,
                            ),
                          ],
                          color: Theme.of(context).primaryColor,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            SizedBox(height: 20),
                            GestureDetector(
                              onTap: () {
                                log('Profile button clicked');
                              },
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 25,
                                child: Icon(
                                  Icons.person,
                                  size: 40.0,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            SizedBox(height: 5),
                          ],
                        ),
                      ),
                      SizedBox(width: 20),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Hello!',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('Let\'s save some of your time and effort.'),
                      SizedBox(height: 10),
                      /*
                      TextFormField(
                        style: TextStyle(
                          fontSize: 18,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                          fillColor: Colors.black26,
                          suffixIcon: Icon(
                            Icons.search,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      */
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        child: Badges(),
                      ),
                      StreamBuilder<ApiResponse<List<Subscriber>>>(
                          stream: _bloc.subscribersListStream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              switch (snapshot.data.status) {
                                case Status.LOADING:
                                  return Loading(
                                      loadingMessage: snapshot.data.message);
                                  break;
                                case Status.COMPLETED:
                                  if (_bloc.subscriberList.length == 0) {
                                    return Text(
                                      'Sorry. We found nothing as per your search.',
                                      maxLines: 3,
                                      overflow: TextOverflow.clip,
                                      style: TextStyle(fontSize: 18),
                                    );
                                  } else {
                                    return ListView.builder(
                                      itemCount: _bloc.subscriberList.length,
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        return ListItem(
                                          subscriber:
                                              _bloc.subscriberList[index],
                                        );
                                      },
                                    );
                                  }
                                  break;
                                case Status.ERROR:
                                  return Error(
                                    errorMessage: snapshot.data.message,
                                    onRetryPressed: () =>
                                        _bloc.fetchSubscribersList(),
                                  );
                                  break;
                                default:
                                  return Text('Has data but it is invalid');
                              }
                            } else {
                              return Text('No snapshot data');
                            }
                          }),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Badges extends StatefulWidget {
  const Badges({
    Key key,
  }) : super(key: key);

  @override
  _BadgesState createState() => _BadgesState();
}

class _BadgesState extends State<Badges> {
  List<bool> pressedBadges;
  String selectedCategory;
  Map<String, dynamic> categoryMap = {
    'Saloon': 0,
    'Medical Store': 1,
    'Bank': 2,
    'Supermarket': 3,
    'Airport': 4
  };
  @override
  void initState() {
    pressedBadges = List.generate(categoryMap.keys.length, (index) => false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: <CategoryBadge>[
        CategoryBadge(
          iconPath: 'assets/icons/saloon.png',
          label: 'Saloon',
          pressed: pressedBadges[categoryMap['Saloon']],
        ),
        CategoryBadge(
          iconPath: 'assets/icons/medicine.png',
          label: 'Medical Store',
          pressed: pressedBadges[categoryMap['Medical Store']],
        ),
//        CategoryBadge(
//          icon: Icons.account_balance,
//          label: 'Bank',
//          pressed: pressedBadges[categoryMap['Bank']],
//        ),
        CategoryBadge(
          iconPath: 'assets/icons/airport.png',
          label: "Airport",
          pressed: pressedBadges[categoryMap['Airport']],
        ),
        CategoryBadge(
          icon: Icons.shopping_cart,
          label: 'Supermarket',
          pressed: pressedBadges[categoryMap['Supermarket']],
        ),
      ]
          .map((badge) => GestureDetector(
                onTap: () async {
                  setState(() {
                    pressedBadges = List.generate(
                        categoryMap.keys.length, (index) => false);
                    pressedBadges[categoryMap[badge.getCategory()]] = true;
                    selectedCategory = badge.getCategory();
                    log('Selected category: $selectedCategory');
                  });

                  await Provider.of<SubscribersBloc>(context, listen: false)
                      .setCategory(selectedCategory);
                },
                child: badge,
              ))
          .toList(),
    );
  }
}

class ListItem extends StatelessWidget {
  final Subscriber subscriber;
  ListItem({@required this.subscriber});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, BookingScreen.id, arguments: subscriber);
        },
        child: Row(
          children: <Widget>[
            Stack(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  child: CachedNetworkImage(
                    imageUrl: subscriber.imgURL ??
                        'https://dontwaitapp.co/img/bank1080.png',
                    height: 150,
                    width: 150,
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
//                      Image.asset('assets/temp/saloon1080.png'),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      margin: EdgeInsets.all(5),
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        'New',
                        style: TextStyle(color: Colors.white),
                      )),
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
                      visible: subscriber.distance != null,
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
