import 'package:flutter/material.dart';
import 'package:qme/model/reception.dart';
import 'package:qme/model/subscriber.dart';

class AppointmentScreen extends StatefulWidget {
  static const String id = '/appointment';
  final Subscriber subscriber;
  final Reception reception;

  AppointmentScreen({this.subscriber, this.reception});

  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Text('Subscriber: ${widget.subscriber.toJson()}\n'
              'Reception:${widget.reception.toJson()}'),
        ),
      ),
    );
  }
}
