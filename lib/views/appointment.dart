import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:qme/bloc/booking_bloc.dart';
import 'package:qme/model/reception.dart';
import 'package:qme/model/slot.dart';
import 'package:qme/model/subscriber.dart';
import 'package:qme/model/user.dart';
import 'package:qme/repository/appointment.dart';
import 'package:qme/services/analytics.dart';
import 'package:qme/utilities/logger.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:qme/views/booking_success.dart';
import 'package:qme/views/slot_view.dart';

class ApppointmentScreenArguments {
  final Subscriber subscriber;
  final Reception reception;
  final Slot slot;

  ApppointmentScreenArguments({this.subscriber, this.reception, this.slot});
}

class AppointmentScreen extends StatefulWidget {
  static const String id = '/appointment';
  final ApppointmentScreenArguments arg;

  AppointmentScreen(this.arg);

  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  Subscriber get subscriber => widget.arg.subscriber;
  Reception get reception => widget.arg.reception;
  Slot get slot => widget.arg.slot;
  double get h => MediaQuery.of(context).size.height;
  double get w => MediaQuery.of(context).size.width;
  int otp;
  AppointmentRepository appointmentRepository;
  bool cancel = false;
  TextEditingController editingController = new TextEditingController();

  @override
  void initState() {
    appointmentRepository = AppointmentRepository();
    super.initState();
  }

  void confirmationDialog(BuildContext primaryContext, String note) {
    showCupertinoDialog(
        context: primaryContext,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Confirm!"),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                onPressed: () {
                  logger.d("bookng");
                  primaryContext.read<AnalyticsService>().logEvent(
                    "Appointment Booked",
                    {
                      "User Id": primaryContext.read<UserData>().id,
                      "Partner Id": subscriber.id,
                      "Partner Name": subscriber.name,
                      "Reception Id": reception.id,
                      "Booking Date Time": DateTime.now().toString(),
                      "Slot Start Date Time": slot.startTime.toString(),
                    "Slot End Date Time": slot.endTime.toString(),
                    },
                  );
                  BlocProvider.of<BookingBloc>(primaryContext)
                      .add(BookingRequested(
                    subscriber.id,
                    note,
                    reception.id,
                    slot.startTime,
                    slot.endTime,
                  ));
                  Navigator.pop(context);
                },
                child: Text(
                  "Yes",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                color: Theme.of(context).primaryColor,
              ),
            ],
          );
        });
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
                alignment: Alignment.center,
              ),
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
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        FaIcon(FontAwesomeIcons.locationArrow),
                        SizedBox(
                          width: 15,
                        ),
                        Text("Booking your appointment.....")
                      ],
                    ),
                  ),
                );
              } else if (state is BookingLoadSuccess) {
                int previousVal = Hive.box("counter").get("counter");
                logger.i(previousVal);
                Hive.box("counter").put(
                  "counter",
                  previousVal + 1,
                );
                Navigator.pushReplacementNamed(
                  context,
                  BookingSuccess.id,
                  arguments: state.details.otp,
                );
              } else if (state is BookingLoadFailure) {
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        FaIcon(FontAwesomeIcons.timesCircle),
                        SizedBox(
                          width: 15,
                        ),
                        Text(state.message)
                      ],
                    ),
                  ),
                );
              }
            },
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        DateIcon(slot: slot),
                        Expanded(
                          flex: 3,
                          child: Container(
                            alignment: Alignment.bottomRight,
                            height: 150,
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
                                    "${DateFormat("jm").format(slot.startTime)}",
                                    style: TextStyle(fontSize: 25)),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: LongDateText(slot: slot),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(30, 10, 10, 10),
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Appointment at \n${subscriber.name}',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        Text(
                          subscriber.address,
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                      ],
                    ),
                  ),
                  Container(
                      width: double.infinity,
                      alignment: Alignment.topLeft,
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                      child: ValueListenableBuilder(
                        valueListenable: Hive.box('users').listenable(
                          keys: ["this"],
                        ),
                        builder: (context, box, widget) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppointmentForDetails(box: box),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12.0),
                              child: TextField(
                                onChanged: (value) {
                                  print(value);
                                },
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                                minLines: 1,
                                maxLines: 6,
                                controller: editingController,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.note_add),
                                  // labelText: "Note",
                                  hintText:
                                      "Please add a note for your stylist. You can include the service you wish.",
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      )),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: BlocBuilder<BookingBloc, BookingState>(
                      builder: (context, state) {
                        return RaisedButton(
                          onPressed: () {
                            confirmationDialog(context, editingController.text);
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
      ),
    );
  }

  @override
  void dispose() {
    editingController.dispose();
    super.dispose();
  }
}

class LongDateText extends StatelessWidget {
  const LongDateText({
    Key key,
    @required this.slot,
  }) : super(key: key);

  final Slot slot;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          "${DateFormat('E').format(slot.startTime)}",
          style: TextStyle(fontSize: 20),
        ),
        Text(
          "${DateFormat("MMMMEEEEd").format(slot.startTime)}",
          style: TextStyle(
            // color: Colors.grey,
            fontSize: 15,
          ),
        )
      ],
    );
  }
}

class DateIcon extends StatelessWidget {
  const DateIcon({
    Key key,
    @required this.slot,
  }) : super(key: key);

  final Slot slot;

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class ListItem extends StatelessWidget {
  const ListItem({
    Key key,
    @required this.title,
    @required this.value,
  }) : super(key: key);

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
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
}
