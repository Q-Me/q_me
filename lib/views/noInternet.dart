import 'package:flutter/material.dart';
import 'package:qme/utilities/logger.dart';

class NoInternetView extends StatefulWidget {
  static const String id = '/noInternet';

  @override
  _NoInternetViewState createState() => _NoInternetViewState();
}

class _NoInternetViewState extends State<NoInternetView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Stack(
        children: [
          Image.asset(
            'assets/images/NoConnection.png',
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.fill,
          ),
          ],
      ),
    );
  }
}
