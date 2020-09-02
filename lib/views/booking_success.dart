import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:qme/widgets/button.dart';

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
          SizedBox(
            height: 15,
          ),
          ThemedSolidButton(
              text: "Nice!",
              buttonFunction: () {
                Navigator.pop(context);
              })
        ],
      ),
    ));
  }
}
