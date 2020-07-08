import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qme/api/base_helper.dart';
import 'package:qme/bloc/subscribersHome.dart';
import 'package:qme/model/subscriber.dart';
import 'package:qme/widgets/categories.dart';
import 'package:qme/widgets/listItem.dart';

import '../widgets/error.dart';
import '../widgets/headerHome.dart';
import '../widgets/loader.dart';

class HomeScreen extends StatefulWidget {
  static const id = '/home';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SubscribersBloc _bloc;
  bool _enabled;
  @override
  void initState() {
    _bloc = SubscribersBloc();
    _enabled = true;
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
                  Header(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
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
                        child: Text(
                          'Saloons in Patna',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.w800),
                        ),
                      ),
                      StreamBuilder<ApiResponse<List<Subscriber>>>(
                          stream: _bloc.subscribersListStream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              switch (snapshot.data.status) {
                                case Status.LOADING:
                                  return ShimmerListLoader(_enabled);
                                  break;
                                case Status.COMPLETED:
                                  _enabled = false;
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
                                        return SubscriberListItem(
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
//              '${DateTime.now().add(Duration(
//                    days: index,
//                  )).weekday}', // TODO: Display which weekday
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
