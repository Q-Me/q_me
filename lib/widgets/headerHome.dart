import 'dart:developer';

import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final String name;
  const Header({Key key, this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(
          'Hi $name...',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 45, width: 45),
        Spacer(),
        Container(
          height: 80,
          width: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(30),
              bottomLeft: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor,
                spreadRadius: 0,
                blurRadius: 5,
              ),
            ],
            color: Theme.of(context).primaryColor,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  log('Profile button clicked');
                },
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 25,
                  child: Icon(
                    Icons.person,
                    size: 40.0,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              SizedBox(height: 5),
            ],
          ),
        ),
        SizedBox(width: 20),
      ],
    );
  }
}
