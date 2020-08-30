import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:qme/bloc/booking_bloc.dart';
import 'package:qme/bloc/bookings_screen_bloc/bookingslist_bloc.dart';
import 'package:qme/model/user.dart';
import 'package:qme/repository/appointment.dart';
import 'package:qme/utilities/logger.dart';
import 'package:qme/views/review.dart';

class ListItemBooked extends StatelessWidget {
  const ListItemBooked({
    Key key,
    @required this.name,
    @required this.location,
    @required this.slot,
    @required this.otp,
    @required this.counterId,
    @required this.primaryContext,
  }) : super(key: key);

  final String name;
  final String location;
  final DateTime slot;
  final String otp;
  final String counterId;
  final BuildContext primaryContext;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Column(
            children: [
              Text(
                "$name",
                style: TextStyle(
                    fontFamily: "Avenir",
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                "$location",
                style: TextStyle(
                    fontFamily: "Avenir",
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        TimeAndDateItem(
            icon: FontAwesomeIcons.calendarAlt,
            description: "${DateFormat.yMMMMEEEEd().format(slot)}"),
        TimeAndDateItem(
            icon: FontAwesomeIcons.clock,
            description: "${DateFormat.jm().format(slot)}"),
        SizedBox(
          height: 20,
        ),
        Column(
          children: [
            Container(
              width: double.infinity,
              child: Center(
                child: Text(
                  "OTP",
                  style: TextStyle(
                      color: Theme.of(context).primaryColor, fontSize: 20),
                ),
              ),
            ),
            Text(
              '$otp',
              style: TextStyle(
                fontSize: 42,
                letterSpacing: 12,
                fontWeight: FontWeight.w800,
              ),
            )
          ],
        ),
        Center(
          child: Material(
            child: InkWell(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Whoa, Hold On..."),
                        content: Text(
                            "Do you really want to cancel your appointment?"),
                        actions: <Widget>[
                          new RaisedButton(
                            onPressed: () async {
                              BlocProvider.of<BookingslistBloc>(primaryContext)
                                  .add(
                                CancelRequested(
                                  counterId,
                                  await getAccessTokenFromStorage(),
                                ),
                              );
                              Navigator.pop(context);
                            },
                            child: Text("Yep, I'm sure"),
                            color: Colors.red[600],
                          ),
                          new RaisedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("No, I want my appointment"),
                            color: Colors.green[600],
                          )
                        ],
                      );
                    });
              },
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Text(
                  "Cancel this booking?",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ),
        Divider(
          thickness: 3,
        ),
      ],
    );
  }
}

class ListItemFinished extends StatelessWidget {
  const ListItemFinished({
    Key key,
    @required this.name,
    @required this.location,
    @required this.slot,
    @required this.rating,
    @required this.subscriberId,
    @required this.counterId,
    @required this.subscriberName,
    @required this.primaryContext,
  }) : super(key: key);

  final String name;
  final String location;
  final DateTime slot;
  final double rating;
  final String subscriberId;
  final String counterId;
  final String subscriberName;
  final BuildContext primaryContext;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Column(
            children: [
              Text(
                "$name",
                style: TextStyle(
                    fontFamily: "Avenir",
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                "$location",
                style: TextStyle(
                    fontFamily: "Avenir",
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        TimeAndDateItem(
            icon: FontAwesomeIcons.calendarAlt,
            description: "${DateFormat.yMMMMEEEEd().format(slot)}"),
        TimeAndDateItem(
            icon: FontAwesomeIcons.clock,
            description: "${DateFormat.jm().format(slot)}"),
        SizedBox(
          height: 20,
        ),
        Material(
          child: InkWell(
            onTap: () {},
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Your Review :",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: rating == null
                          ? Text(
                              "You have not rated yet",
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            )
                          : RatingBarIndicator(
                              itemSize: 30,
                              rating: rating,
                              itemBuilder: (BuildContext context, int index) =>
                                  FaIcon(
                                FontAwesomeIcons.solidStar,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        ReviewScreen.id,
                        arguments: ReviewScreenArguments(
                            counterId, subscriberId, name, subscriberName, slot),
                      );
                      BlocProvider.of<BookingslistBloc>(primaryContext)
                          .add(BookingsListRequested());
                    },
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: FaIcon(FontAwesomeIcons.angleRight),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        Divider(
          thickness: 3,
        ),
      ],
    );
  }
}

class ListItemCancelled extends StatelessWidget {
  const ListItemCancelled({
    Key key,
    @required this.name,
    @required this.location,
    @required this.slot,
  }) : super(key: key);

  final String name;
  final String location;
  final DateTime slot;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Column(
            children: [
              Text(
                "$name",
                style: TextStyle(
                    fontFamily: "Avenir",
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                "$location",
                style: TextStyle(
                    fontFamily: "Avenir",
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        TimeAndDateItem(
            icon: FontAwesomeIcons.calendarAlt,
            description: "${DateFormat.yMMMMEEEEd().format(slot)}"),
        TimeAndDateItem(
            icon: FontAwesomeIcons.clock,
            description: "${DateFormat.jm().format(slot)}"),
        SizedBox(
          height: 20,
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Text(
              "Cancelled",
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey,
              ),
            ),
          ),
        ),
        Divider(
          thickness: 3,
        ),
      ],
    );
  }
}

class TimeAndDateItem extends StatelessWidget {
  const TimeAndDateItem({
    Key key,
    @required this.icon,
    @required this.description,
  }) : super(key: key);

  final IconData icon;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.fromLTRB(60, 20, 20, 0),
      child: Row(
        children: [
          FaIcon(
            icon,
            size: 40,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
            child: Text(description, style: TextStyle(fontSize: 16)),
          )
        ],
      ),
    );
  }
}
