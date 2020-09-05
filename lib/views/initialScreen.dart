import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:qme/views/introSlider.dart';

class InitialScreen extends StatefulWidget {
  static const id = '/initilScreen';
  @override
  _InitialScreenState createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  @override
  Widget build(BuildContext context) {
    double cWidth = MediaQuery.of(context).size.width;
    double cHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          SvgPicture.asset(
            'assets/temp/getStarted.svg',
            fit: BoxFit.fitWidth,
          ),
          Positioned(
            bottom: 200,
            left: 100,
            right: 100,
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
                // side: BorderSide(color: Colors.blue[900]),
              ),
              color: Theme.of(context).primaryColor,
              textColor: Colors.white,
              padding: EdgeInsets.all(cWidth * 0.05),
              onPressed: () {
                Navigator.pushNamed(context, IntroScreen.id);
              },
              child: Text(
                "Get Started!",
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
