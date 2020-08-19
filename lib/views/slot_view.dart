import 'package:calendar_strip/calendar_strip.dart';
import 'package:flutter/material.dart';
import 'package:qme/model/reception.dart';
import 'package:qme/model/slot.dart';
import 'package:qme/utilities/logger.dart';
import 'package:qme/widgets/calenderStrip.dart';

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

  onSelect(date) {
    logger.d('Selected date ${date.toString()}');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'Book a Slot',
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.headline4,
              ),
            ),
            CalendarStrip(
              startDate: DateTime.now(),
              endDate: DateTime.now().add(Duration(days: 7)),
              onDateSelected: onSelect,
              dateTileBuilder: dateTileBuilder,
              iconColor: Colors.black87,
              monthNameWidget: monthNameWidget,
              markedDates: [],
            ),
            SlotSelectionBox(),
          ],
        ),
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
      9,
      (index) => Slot(
        startTime: start.add(Duration(hours: index)),
        endTime: start.add(Duration(hours: index + 1)),
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(),
      child: Column(
        children: [
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
          Text(
            'Appointment for',
            style: Theme.of(context).textTheme.subtitle1,
            textAlign: TextAlign.left,
          ),
          TextFormField(
            decoration: InputDecoration(
              labelStyle: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.green)),
              focusColor: Colors.lightBlue,
              labelText: "PHONE*",
            ),
            controller: TextEditingController(),
          ),
          RaisedButton(
            onPressed: () {
              logger.d('Hello');
            },
            child: Text('Book Appointment'),
          )
        ],
      ),
    );
  }
}
