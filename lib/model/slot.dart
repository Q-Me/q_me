import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class Slot extends Equatable {
  Slot({
    @required this.startTime,
    @required this.endTime,
    this.done = 0,
    this.upcoming = 0,
    this.customersInSlot,
    this.booked = false,
  });

  final DateTime startTime;
  final DateTime endTime;
  int customersInSlot;
  int done;
  int upcoming;
  bool booked;

  @override
  List get props =>
      [startTime, endTime, customersInSlot, done, upcoming, booked];

  Duration get duration => endTime.difference(startTime);
  bool get availableForBooking =>
      customersInSlot - upcoming - done > 0 && !booked ? true : false;

  factory Slot.fromJson(Map<String, dynamic> json) => Slot(
        startTime: DateTime.parse(json["starttime"]),
        endTime: DateTime.parse(json["endtime"]),
      );

  Map<String, dynamic> toJson() => {
        "starttime": startTime.toIso8601String(),
        "endtime": endTime.toIso8601String(),
        "cust_per_slot": customersInSlot,
        "upcoming": upcoming,
        "done": done,
        "booked": booked,
        "availableForBooking": availableForBooking,
      };
}
