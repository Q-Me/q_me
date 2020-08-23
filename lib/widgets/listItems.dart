import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class ListItemBooked extends StatelessWidget {
  const ListItemBooked({
    Key key,
    @required this.name,
    @required this.location,
    @required this.slot,
    @required this.otp,
  }) : super(key: key);

  final String name;
  final String location;
  final DateTime slot;
  final String otp;

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
              onTap: () {},
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
  }) : super(key: key);

  final String name;
  final String location;
  final DateTime slot;
  final double rating;

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
                              "You have not been rated yet",
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
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: FaIcon(FontAwesomeIcons.angleRight),
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
        TimeAndDateItem(icon: FontAwesomeIcons.calendarAlt, description: "${DateFormat.yMMMMEEEEd().format(slot)}"),
        TimeAndDateItem(icon: FontAwesomeIcons.clock, description: "${DateFormat.jm().format(slot)}"),
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
