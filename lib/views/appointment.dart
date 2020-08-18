import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qme/bloc/appointment.dart';
import 'package:qme/bloc/booking_bloc.dart';
import 'package:qme/model/reception.dart';
import 'package:qme/model/slot.dart';
import 'package:qme/model/subscriber.dart';
import 'package:qme/repository/appointment.dart';
import 'package:qme/views/success.dart';

String notes;

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
  Subscriber get subscriber => widget.subscriber;
  Reception get reception => widget.reception;
  Slot get slot => widget.slot;
  double get h => MediaQuery.of(context).size.height;
  double get w => MediaQuery.of(context).size.width;
  String note = 'Add notes like requirements';
  int otp;
  AppointmentBloc _appointmentBloc;
  AppointmentRepository appointmentRepository;
  bool cancel = false;

  @override
  void initState() {
    _appointmentBloc = AppointmentBloc(
      slot: slot,
      subscriber: subscriber,
      reception: reception,
    );
    appointmentRepository = AppointmentRepository();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_appointmentBloc == null) {
      _appointmentBloc = AppointmentBloc(
        slot: slot,
        subscriber: subscriber,
        reception: reception,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider(
        create: (context) =>
            BookingBloc(appointmentRepository: appointmentRepository),
        child: Scaffold(
          appBar: AppBar(
            leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Align(
                  child: FaIcon(
                FontAwesomeIcons.arrowLeft,
                color: Colors.black,
              ),
              alignment: Alignment.center,),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              "Slot",
              style: TextStyle(color: Colors.black),
            ),
          ),
          body: BlocListener<BookingBloc, BookingState>(
            listener: (context, state) {
              if (state is BookingLoadInProgress) {
                showSnackbar(context, "loading", null);
              } else if (state is BookingLoadSuccess) {
                showSnackbar(context, "success", state.details.otp);
              } else if (state is BookingLoadFailure) {
                showSnackbar(context, "failure", null);
              }
            },
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        alignment: Alignment.centerLeft,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            FaIcon(
                              FontAwesomeIcons.solidCalendar,
                              size: 100,
                              color: Colors.grey,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                "${slot.startTime.day}",
                                style: TextStyle(fontSize: 50),
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        alignment: Alignment.bottomLeft,
                        height: 100,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "${weekDay(slot.startTime.weekday)}",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 20),
                            ),
                            Text(
                              "${slot.startTime.month}, ${slot.startTime.year}",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                              ),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Container(
                          alignment: Alignment.bottomRight,
                          height: 100,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FaIcon(
                                FontAwesomeIcons.clock,
                                size: 50,
                                color: Colors.grey,
                              ),
                              Text(
                                  "${slot.startTime.hour}:${slot.startTime.minute}",
                                  style: TextStyle(fontSize: 30)),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                Container(
                    padding: EdgeInsets.fromLTRB(30, 0, 0, 10),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Appointment for",
                      style: TextStyle(fontSize: 25),
                    )),
                Card(
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                        width: double.infinity,
                        alignment: Alignment.topLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _listItem("Name", "${subscriber.name}"),
                            _listItem("Phone No", "${subscriber.phone}"),
                          ],
                        )),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: BlocBuilder<BookingBloc, BookingState>(
                    builder: (context, state) {
                      return RaisedButton(
                        onPressed: () {
                          BlocProvider.of<BookingBloc>(context)
                              .add(BookingRequested(
                            subscriber.id,
                            note,
                            reception.id,
                            slot.startTime,
                            slot.endTime,
                          ));
                        },
                        color: Theme.of(context).primaryColor,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 20),
                          child: Text(
                            "Book Appointment",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _listItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: TextStyle(color: Colors.grey),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            value,
            style: TextStyle(fontSize: 20),
          ),
        ),
        Divider(
          thickness: 3,
        ),
      ],
    );
  }

  String weekDay(int weekday) {
    dynamic dayData = {
      "1": "Mon",
      "2": "Tue",
      "3": "Wed",
      "4": "Thur",
      "5": "Fri",
      "6": "Sat",
      "7": "Sun"
    };
    print(dayData);
    return dayData[weekday.toString()];
  }

  void showSnackbar(BuildContext context, String state, dynamic value) {
    if (state == "loading") {
      Scaffold.of(context).showSnackBar(SnackBar(
          content: Row(
        children: [
          FaIcon(FontAwesomeIcons.locationArrow),
          SizedBox(
            width: 15,
          ),
          Text("Booking your appointment.....")
        ],
      )));
    } else if (state == "success") {
      Navigator.pushReplacementNamed(
        context,
        BookingSuccess.id,
        arguments: value,
      );
    } else if (state == "failure") {
      Scaffold.of(context).showSnackBar(SnackBar(
          content: Row(
        children: [
          FaIcon(FontAwesomeIcons.timesCircle),
          SizedBox(
            width: 15,
          ),
          Text("Oops, that wasn't supposed to happen...")
        ],
      )));
    }
  }
}
