import 'package:calendar_strip/calendar_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:qme/bloc/slotview_bloc.dart';
import 'package:qme/model/reception.dart';
import 'package:qme/model/slot.dart';
import 'package:qme/utilities/logger.dart';
import 'package:qme/widgets/calenderStrip.dart';
import 'package:intl/intl.dart';

class SlotViewArguments {
  final String subscriberId;

  SlotViewArguments({@required this.subscriberId})
      : assert(subscriberId != null);
}

class SlotView extends StatefulWidget {
  static const id = '/slotView';
  final SlotViewArguments args;

  const SlotView(this.args);

  @override
  _SlotViewState createState() => _SlotViewState();
}

class _SlotViewState extends State<SlotView> {
  String get subscriberId => widget.args.subscriberId;
  Reception selectedReception;
  DateTime selectedDate;
  Slot selectedSlot;

  bool backArrowEnabled = false;

  double get h => MediaQuery.of(context).size.height;
  double get w => MediaQuery.of(context).size.width;
  @override
  void initState() {
    selectedDate = DateTime.now();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
            subscriberId: subscriberId,
            selectedDate: selectedDate,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlocListener(
                listener: (context,state) => CalendarStrip(
                  startDate: DateTime.now(),
                  endDate: DateTime.now().add(Duration(days: 7)),
                  onDateSelected: (date) {
                    logger.d('Selected date ${date.toString()}');
                    SlotViewBloc bloc =
                        BlocProvider.of<SlotViewBloc>(context);
                    bloc.add(DatedReceptionsRequested(date: selectedDate));
                  },
                  selectedDate: selectedDate,
                  dateTileBuilder: dateTileBuilder,
                  iconColor: Colors.black87,
                  monthNameWidget: monthNameWidget,
                  markedDates: [],
                ),
              ),
              Row(
                children: [
                  SizedBox(width: 20),
                  Text(
                    'Available times',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  Spacer(),
                  Opacity(
                    opacity: backArrowEnabled ? 1 : 0,
                    child: Icon(Icons.arrow_back_ios, color: Colors.grey),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_forward_ios, color: Colors.grey),
                ],
              ),
              BlocConsumer<SlotViewBloc, SlotViewState>(
                builder: (context, state) {
                  if (state is SlotViewLoading ||
                      state is SlotViewStateInitial) {
                    return CircularProgressIndicator();
                  } else if (state is SlotViewLoadSuccess) {
                    List<Reception> receptions = state.response;
                    List<Widget> boxesOfSlot = [];

                    for (Reception reception in receptions) {
                      boxesOfSlot.addAll(reception.slotList.map(
                        (e) {
                          return GestureDetector(
                            onTap: () {
                              selectedSlot = e;
                            },
                            child: SlotBox(
                              slot: e,
                              selected: selectedSlot == e,
                            ),
                          );
                        },
                      ).toList());
                    }

                    return Container(
                      height: h / 3 - 20,
                      width: w,
                      decoration: BoxDecoration(
                        color: Color(0xfff7f6f6),
                      ),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 20,
                          childAspectRatio: .68,
                        ),
                        padding: EdgeInsets.fromLTRB(20, 10, 10, 10),
                        scrollDirection: Axis.horizontal,
                        controller: ScrollController(),
                        itemCount: boxesOfSlot.length,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          return boxesOfSlot[index];
                        },
                      ),
                    );
                  } else if (state is SlotViewLoadFail) {
                    return Text(state.message);
                  }
                  return Center(child: Text('Undetermined state'));
                },
                listener: (context, state) {
                  BlocProvider.of<SlotViewBloc>(context)
                      .add(DatedReceptionsRequested(date: selectedDate));
                },
              ),
              Padding(
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
                    FieldValue(label: 'Full Name', text: 'Piyush Chauhan'),
                    FieldValue(label: 'Contact No.', text: '+91 9673582517'),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: RaisedButton(
                  onPressed: () {
                    logger.d('Hello');
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width - 100,
                    child: Center(child: Text('Book Appointment')),
                  ),
                ),
              ),
            ],
          ),
        ),
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
    @required this.text,
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
          borderSide: BorderSide(color: Colors.green),
        ),
        focusColor: Colors.lightBlue,
        enabled: false,
      ),
    );
  }
}

class SlotSelectionBox extends StatefulWidget {
  @override
  _SlotSelectionBoxState createState() => _SlotSelectionBoxState();
}

class _SlotSelectionBoxState extends State<SlotSelectionBox> {
  bool backArrowEnabled;
  List<Slot> slots;
  Slot selectedSlot;

  @override
  void initState() {
    backArrowEnabled = false;
    final start = DateTime(2020, 8, 16, 10);
    slots = List.generate(
      19,
      (index) => Slot(
        startTime: start.add(Duration(hours: index)),
        endTime: start.add(Duration(hours: index + 1)),
      ),
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(),
      child: Column(
        children: [],
      ),
    );
  }
}

class SlotBox extends StatelessWidget {
  final bool selected;
  final Slot slot;

  SlotBox({this.selected = false, this.slot});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text(
          DateFormat.jm().format(slot.startTime),
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ),
      decoration: BoxDecoration(
        color: selected ? Theme.of(context).accentColor : Colors.white,
        borderRadius: BorderRadius.circular(5),
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
