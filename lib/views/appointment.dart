import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qme/model/reception.dart';
import 'package:qme/model/slot.dart';
import 'package:qme/model/subscriber.dart';
import 'package:qme/model/user.dart';
import 'package:qme/repository/user.dart';
import 'package:qme/utilities/logger.dart';
import 'package:qme/widgets/button.dart';

class AppointmentScreen extends StatefulWidget {
  static const String id = '/appointment';
  final Subscriber subscriber;
  final Reception reception;
  final Slot slot;

  AppointmentScreen({this.subscriber, this.reception, this.slot});

  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  _AppointmentScreenState() {
    Future<UserData> user = UserRepository().fetchProfile();
  }
  Subscriber get subscriber => widget.subscriber;
  Reception get reception => widget.reception;
  Slot get slot => widget.slot;
  double get h => MediaQuery.of(context).size.height;
  double get w => MediaQuery.of(context).size.width;

  bool editing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Container(
                  child: Column(
                    children: <Widget>[
                      subscriber.imgURL != null
                          ? ClipRect(
                              child: CachedNetworkImage(
                                imageUrl: subscriber.imgURL,
                                placeholder: (context, url) =>
                                    CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                            )
                          : Container(),
                      Text(
                        subscriber.name,
                        style: Theme.of(context).textTheme.title,
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  padding: EdgeInsets.all(8),
                  child: Column(
                    children: <Widget>[
                      CustomerDetails(
                        name: 'Piyush ',
                        phone: 'ersgg',
                      ),
                      SizedBox(height: 20),
                      Column(
                        children: <Widget>[
                          Text(
                            'You have to reach at ${subscriber.name}, '
                            '${subscriber.address} on '
                            '${DateFormat("EEE, MMM d yyyy, KK:mm a").format(slot.startTime)}',
                          ),
                          Text(
                            'You OTP for the appointment is',
                            style:
                                Theme.of(context).textTheme.bodyText1.copyWith(
                                      fontSize: 20,
                                    ),
                          ),
                          Text(
                            '123456',
                            style: TextStyle(
                              fontSize: 42,
                              letterSpacing: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: ThemedSolidButton(
                                text: 'Confirm Appointment',
                                buttonFunction: () {
                                  logger.i('Button clicked');
                                }),
                          ),
                          SizedBox(width: 10),
                          // TODO button to add slot to wish list
                          WishListButton(added: false),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomerDetails extends StatelessWidget {
  const CustomerDetails({
    Key key,
    @required this.name,
    @required this.phone,
    this.note = '',
  }) : super(key: key);
  final String name, phone, note;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Customer Name:',
          style: Theme.of(context).textTheme.headline5,
        ),
        TextFormField(
          initialValue: name,
          style: Theme.of(context).textTheme.headline6,
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 10),
        Text(
          'Customer Phone:',
          style: Theme.of(context).textTheme.headline6,
        ),
        TextFormField(
          initialValue: phone,
          autovalidate: true,
          validator: (value) {
            if (value.length < 13) {
              return 'Make sure the phone number is of 10 digits';
            }
            return null;
          },
        ),
        Text(
          'Note:',
          style: Theme.of(context).textTheme.headline6,
        ),
        TextFormField(
          initialValue: note,
        ),
      ],
    );
  }
}

class WishListButton extends StatelessWidget {
  const WishListButton({
    Key key,
    this.added,
  }) : super(key: key);
  final bool added;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).accentColor,
            blurRadius: 10.0,
          ),
        ],
      ),
      child: CircleAvatar(
        backgroundColor: Colors.grey[100],
        radius: 20,
        child: GestureDetector(
          onTap: () {
            logger.i('Add to wish list button clicked');
          },
          child: added
              ? Icon(
                  Icons.favorite,
                  color: Colors.red,
                )
              : Icon(
                  Icons.favorite_border,
                ),
        ),
      ),
    );
  }
}
