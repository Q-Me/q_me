import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarStrip extends StatefulWidget {
  CalendarStrip({
    Key key,
    this.onSelectDate,
  }) : super(key: key);
  final Function(DateTime) onSelectDate;
  @override
  _CalendarStripState createState() => _CalendarStripState();
}

class _CalendarStripState extends State<CalendarStrip> {
  DateTime _selectedDate = DateTime.now();
  StreamController<DateTime> _controller = StreamController<DateTime>();
  DateTime startDate = DateTime.now();
  int tracker = 0;

  Stream<DateTime> get selectedDateStream => _controller.stream;

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  void goBack() {
    tracker--;
    setState(() {
      startDate = startDate.add(Duration(days: -5));
    });
  }

  void goNext() {
    tracker++;
    setState(() {
      startDate = startDate.add(Duration(days: 5));
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity > 100) {
          goBack();
        } else if (details.primaryVelocity < -100) {
          goNext();
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: NotificationListener<OnClickDateTileNotification>(
          onNotification: (notification) {
            setState(() {
              _selectedDate = notification.selectedDate;
              _controller.add(notification.selectedDate);
              widget.onSelectDate(notification.selectedDate);
            });
            return true;
          },
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: tracker == 0
                        ? null
                        : () => goBack(),
                    icon: Icon(Icons.chevron_left),
                    padding: EdgeInsets.zero,
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                      child: Text(
                        DateFormat("MMMM").format(
                          startDate,
                        ),
                        style: TextStyle(fontSize: 19),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.chevron_right),
                    onPressed: tracker == 1 ? null : () => goNext(),
                  )
                ],
              ),
              DayTileList(
                number: 5,
                selected: _selectedDate,
                startDate: startDate,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DayTileList extends StatelessWidget {
  const DayTileList(
      {Key key,
      @required this.number,
      @required this.selected,
      @required this.startDate})
      : super(key: key);

  final int number;
  final DateTime selected;
  final DateTime startDate;

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];
    for (int i = 0; i < this.number; i++) {
      if (startDate.add(Duration(days: i)).compareTo(selected) == 0 ||
          (startDate.add(Duration(days: i)).month == selected.month &&
              startDate.add(Duration(days: i)).day == selected.day)) {
        widgets.add(
          Expanded(
            child: SlideFadeTransition(
              delay: 30 + (30 * i),
              id: startDate
                  .add(
                    Duration(days: i),
                  )
                  .toString(),
              child: DayTile(
                date: startDate.add(
                  Duration(days: i),
                ),
                selected: true,
                id: i,
              ),
            ),
          ),
        );
      } else {
        widgets.add(
          Expanded(
            child: SlideFadeTransition(
              delay: 30 + (30 * i),
              id: startDate
                  .add(
                    Duration(days: i),
                  )
                  .toString(),
              child: DayTile(
                date: startDate.add(
                  Duration(days: i),
                ),
                selected: false,
                id: i,
              ),
            ),
          ),
        );
      }
    }
    return Row(
      children: widgets,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    );
  }
}

class DayTile extends StatefulWidget {
  DayTile({
    Key key,
    @required this.date,
    @required this.selected,
    @required this.id,
  }) : super(key: key);

  final DateTime date;
  final bool selected;
  final int id;

  @override
  _DayTileState createState() => _DayTileState();
}

class _DayTileState extends State<DayTile> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: Material(
        borderRadius: BorderRadius.circular(10),
        color: this.widget.selected
            ? Theme.of(context).primaryColor
            : Theme.of(context).canvasColor,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            OnClickDateTileNotification(
              selectedIndex: widget.id,
              selectedDate: this.widget.date,
            ).dispatch(context);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
            child: Column(
              children: [
                Text(
                  widget.date.day.toString(),
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color:
                          this.widget.selected ? Colors.white : Colors.black),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                  child: Text(
                    DateFormat('EEE').format(widget.date),
                    style: TextStyle(
                        fontSize: 10,
                        color: this.widget.selected
                            ? Colors.white
                            : Colors.grey[400]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OnClickDateTileNotification extends Notification {
  final int selectedIndex;
  final DateTime selectedDate;

  OnClickDateTileNotification({
    @required this.selectedIndex,
    @required this.selectedDate,
  });
}

class SlideFadeTransition extends StatefulWidget {
  final Widget child;
  final int delay;
  final String id;
  final Curve curve;

  SlideFadeTransition(
      {@required this.child,
      @required this.id,
      @required this.delay,
      this.curve});

  @override
  SlideFadeTransitionState createState() => SlideFadeTransitionState();
}

class SlideFadeTransitionState extends State<SlideFadeTransition>
    with TickerProviderStateMixin {
  AnimationController _animController;
  Animation<Offset> _animOffset;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();

    _animController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    final _curve = CurvedAnimation(
        curve: widget.curve != null ? widget.curve : Curves.decelerate,
        parent: _animController);
    _animOffset =
        Tween<Offset>(begin: const Offset(0.0, 0.25), end: Offset.zero)
            .animate(_curve);

    if (widget.delay == null) {
      if (!_disposed) _animController.forward();
    } else {
      _animController.reset();
      Future.delayed(Duration(milliseconds: widget.delay), () {
        if (!_disposed) _animController.forward();
      });
    }
  }

  @override
  void didUpdateWidget(SlideFadeTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.id != oldWidget.id) {
      _animController.reset();
      Future.delayed(Duration(milliseconds: widget.delay), () {
        if (!_disposed) _animController.forward();
      });
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      child: SlideTransition(position: _animOffset, child: widget.child),
      opacity: _animController,
    );
  }
}
