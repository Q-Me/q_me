import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'appointment.dart';

// ignore: must_be_immutable
class Slot extends Equatable {
  Slot({
    @required this.startTime,
    @required this.endTime,
    this.booked,
    this.customersInSlot,
  });
  List<Appointment> appointments = [];
  Duration get duration => endTime.difference(startTime);
  void addAppointment(Appointment appointment) {
    appointments.add(appointment);
  }

  final DateTime startTime;
  final DateTime endTime;
  int booked;
  int customersInSlot;

  factory Slot.fromJson(Map<String, dynamic> json) => Slot(
        startTime: DateTime.parse(json["starttime"]),
        endTime: DateTime.parse(json["endtime"]),
      );

  Map<String, dynamic> toJson() => {
        "starttime": startTime.toIso8601String(),
        "endtime": endTime.toIso8601String(),
        "cust_per_slot": customersInSlot,
        "booked": booked,
      };

  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
