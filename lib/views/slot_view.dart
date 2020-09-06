import 'package:calendar_strip/calendar_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:qme/bloc/slotview_bloc.dart';
import 'package:qme/model/reception.dart';
import 'package:qme/model/slot.dart';
import 'package:qme/model/subscriber.dart';
import 'package:qme/utilities/logger.dart';
import 'package:qme/views/appointment.dart';
import 'package:qme/views/home.dart';
import 'package:qme/widgets/calenderStrip.dart';
import 'package:intl/intl.dart';

class SlotViewArguments {
  final Subscriber subscriber;

  SlotViewArguments({@required this.subscriber}) : assert(subscriber != null);
}

class SlotView extends StatefulWidget {
  static const id = '/slotView';
  final SlotViewArguments args;

  const SlotView(this.args);

  @override
  _SlotViewState createState() => _SlotViewState();
}

class _SlotViewState extends State<SlotView> {
  String get subscriberId => widget.args.subscriber.id;
  Subscriber get subscriber => widget.args.subscriber;
  DateTime selectedDate;
  Slot selectedSlot;
  ScrollController gridScroll = ScrollController();
  bool backArrowEnabled = false;
  Box box = Hive.box("user");

  double get h => MediaQuery.of(context).size.height;
  double get w => MediaQuery.of(context).size.width;
  @override
  void initState() {
    selectedDate = DateTime.now();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Book a Slot',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: BlocProvider(
        create: (context) => SlotViewBloc(
          subscriber: subscriber,
          selectedDate: DateTime.now(),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 100,
                child: BlocBuilder<SlotViewBloc, SlotViewState>(
                  builder: (context, state) => CalendarStrip(
                    startDate: DateTime.now(),
                    endDate: DateTime.now().add(Duration(days: 7)),
                    onDateSelected: (date) {
                      logger.d('Selected date ${date.toString()}');
                      BlocProvider.of<SlotViewBloc>(context)
                          .add(DatedReceptionsRequested(date: date));
                    },
                    selectedDate:
                        BlocProvider.of<SlotViewBloc>(context).selectedDate,
                    dateTileBuilder: dateTileBuilder,
                    iconColor: Colors.black87,
                    monthNameWidget: monthNameWidget,
                    markedDates: [],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    SizedBox(width: 20),
                    Text(
                      'Available times',
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    Spacer(),
                    Icon(Icons.arrow_forward_ios, color: Colors.grey),
                    SizedBox(width: 10),
                  ],
                ),
              ),
              Container(
                height: h / 3 - 20,
                width: w,
                decoration: BoxDecoration(
                  color: Colors.black12,
                ),
                child: BlocConsumer<SlotViewBloc, SlotViewState>(
                  builder: (context, state) {
                    if (state is SlotViewLoading) {
                      return CircularProgressIndicator();
                    } else if (state is SlotViewStateInitial) {
                      logger.d(state);
                      BlocProvider.of<SlotViewBloc>(context)
                          .add(DatedReceptionsRequested(date: DateTime.now()));
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (state is NothingSelected ||
                        state is SelectedSlot ||
                        state is BookedSlot) {
                      List<Reception> receptions =
                          BlocProvider.of<SlotViewBloc>(context)
                              .datedReceptions;
                      if (receptions.length == 0) {
                        return Center(child: Text('Unavailable'));
                      } else if (receptions.length == 1) {}
                      List<Widget> boxesOfSlot = [];

                      for (Reception reception in receptions) {
                        boxesOfSlot.addAll(reception.slotList.map(
                          (e) {
                            Slot slot = e;
                            Color color;
                            if (slot.booked) {
                              color = Colors.green;
                            } else if (!slot.availableForBooking) {
                              color = Colors.red;
                            } else if (state is SelectedSlot &&
                                state.slot == slot) {
                              color = Theme.of(context).primaryColor;
                            } else if (!reception.availableForBooking) {
                              color = Colors.grey;
                            } else {
                              color = Colors.white;
                            }
                            return BlocBuilder<SlotViewBloc, SlotViewState>(
                              builder: (context, state) {
                                return GestureDetector(
                                  onTap: () {
                                    if (!reception.availableForBooking ||
                                        !e.availableForBooking) {
                                      return;
                                    }
                                    BlocProvider.of<SlotViewBloc>(context).add(
                                      SelectSlot(
                                        slot: e,
                                        reception: reception,
                                      ),
                                    );
                                  },
                                  child: SlotBox(
                                    slot: e,
                                    color: color,
                                  ),
                                );
                              },
                            );
                          },
                        ).toList());
                      }

                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 20,
                          childAspectRatio: .68,
                        ),
                        padding: EdgeInsets.fromLTRB(20, 10, 10, 10),
                        scrollDirection: Axis.horizontal,
                        controller: gridScroll,
                        itemCount: boxesOfSlot.length,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          return boxesOfSlot[index];
                        },
                      );
                    } else if (state is SlotViewLoadFail) {
                      return Text(state.message);
                    }
                    return Center(child: Text('Undetermined state'));
                  },
                  listener: (context, state) {},
                ),
              ),
              AppointmentForDetails(box: box),
              SizedBox(height: 20),
              ActionButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class AppointmentForDetails extends StatelessWidget {
  const AppointmentForDetails({
    Key key,
    @required this.box,
  }) : super(key: key);

  final Box box;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Text(
            'Appointment for',
            style: Theme.of(context).textTheme.subtitle1,
            textAlign: TextAlign.left,
          ),
          SizedBox(height: 10),
          FieldValue(
            label: 'Full Name',
            text: "${box.get("name")}",
          ),
          FieldValue(
            label: 'Contact No.',
            text: '${box.get("phone")}',
          ),
          // TODO FieldValue(label: 'Note'),
        ],
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  const ActionButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BlocBuilder<SlotViewBloc, SlotViewState>(
        builder: (context, state) {
          return RaisedButton(
            splashColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            onPressed: state is SelectedSlot || state is BookedSlot
                ? () {
                    if (state is BookedSlot) {
                      logger.d("pushing to homescreen");
                      Box index = Hive.box("index");
                      index.put("index", 1);
                      Navigator.pushNamed(
                        context,
                        HomeScreen.id,
                      );
                      return;
                    }
                    if (state is SelectedSlot) {
                      // Go to appointment view
                      Slot slot = state.slot;
                      Reception reception = state.reception;
                      Subscriber subscriber = state.subcriber;
                      Navigator.pushReplacementNamed(
                        context,
                        AppointmentScreen.id,
                        arguments: ApppointmentScreenArguments(
                          reception: reception,
                          slot: slot,
                          subscriber: subscriber,
                        ),
                      );
                    }
                  }
                : null,
            color: state is BookedSlot
                ? Colors.green
                : Theme.of(context).primaryColor,
            child: !(state is BookedSlot)
                ? Container(
                    width: MediaQuery.of(context).size.width - 100,
                    height: 60,
                    child: Center(
                      child: Text(
                        'Book Appointment',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                : Container(
                    width: MediaQuery.of(context).size.width - 100,
                    height: 60,
                    child: Center(
                      child: Text(
                        'Already Booked',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }
}

class FieldValue extends StatelessWidget {
  final String label;
  final String text;

  FieldValue({
    Key key,
    @required this.label,
    this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: TextEditingController(text: text),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        focusColor: Colors.lightBlue,
        enabled: text != null ? false : true,
      ),
    );
  }
}

class SlotBox extends StatelessWidget {
  final Slot slot;
  final Color color;

  SlotBox({@required this.slot, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text(
          DateFormat.jm().format(slot.startTime),
          style: TextStyle(
              color: color == Colors.white ? Colors.black : Colors.white),
        ),
      ),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0x29000000),
            offset: Offset(0, 2),
            blurRadius: 5,
            spreadRadius: 0,
          ),
        ],
      ),
    );
  }
}
