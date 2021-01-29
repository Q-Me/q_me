import 'dart:math';

import 'package:confetti/confetti.dart';
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
  ConfettiController _controller;
  String get otp => widget.args.otp;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(duration: Duration(seconds: 1));
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _controller.play(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
      // displayTarget: true,
      confettiController: _controller,
      blastDirectionality: BlastDirectionality.directional,
      blastDirection: pi/2,
      numberOfParticles: 30,
      shouldLoop: false, 
              ),
            ),
          ),
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
          // Text(
          //   "OTP",
          //   style: TextStyle(fontSize: 25),
          // ),
          // Text(
          //   "Here is your OTP",
          //   style: TextStyle(color: Colors.grey),
          // ),
          // Text(
          //   '$otp',
          //   style: TextStyle(
          //     fontSize: 42,
          //     letterSpacing: 12,
          //     fontWeight: FontWeight.w800,
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              "Please try to reach 5 minutes before the scheduled time",
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
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 25),
              child: Text(
                "Nice!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container()
          )
        ],
      ),
    ));
  }
}
