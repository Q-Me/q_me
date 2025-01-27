import 'package:flutter/material.dart';

class Error extends StatelessWidget {
  final String errorMessage, buttonLabel;

  final Function onRetryPressed;

  const Error(
      {Key key,
      this.errorMessage,
      this.onRetryPressed,
      this.buttonLabel = 'Retry'})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.lightGreen,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
          RaisedButton(
            color: Colors.lightGreen,
            child: Text(buttonLabel, style: TextStyle(color: Colors.white)),
            onPressed: onRetryPressed,
          )
        ],
      ),
    );
  }
}
