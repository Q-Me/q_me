import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';

class SuccessScreenArguments {
  final String otp;

  SuccessScreenArguments({@required this.otp});
}

class BookingSuccess extends StatefulWidget {
  static const String id = "/bookingSuccess";
  BookingSuccess(this.args, {Key key}) : super(key: key);

  final SuccessScreenArguments args;

  @override
  _BookingSuccessState createState() => _BookingSuccessState();
}

class _BookingSuccessState extends State<BookingSuccess> {
  String get otp => widget.args.otp;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            child: FlareActor(
              "assets/blue-tick.flr",
              alignment: Alignment.center,
              fit: BoxFit.contain,
              animation: "Untitled",
            ),
          ),
          Text("Your booking has been confirmed"),
          SizedBox(
            height: 40,
          ),
          Text(
            "OTP",
            style: TextStyle(fontSize: 25),
          ),
          Text(
            "Here is your OTP",
            style: TextStyle(color: Colors.grey),
          ),
          Text(
            '$otp',
            style: TextStyle(
              fontSize: 42,
              letterSpacing: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              "Please try to reach 5 minutes before the scheduled time and show this OTP at the store.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          RaisedButton(
            splashColor: Colors.white,
            color: Theme.of(context).primaryColor,
            onPressed: () => Navigator.pop(context),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 25),
              child: Text(
                "Nice!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
          )
        ],
      ),
    ));
  }
}
