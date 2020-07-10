import 'dart:collection';
import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:ordered_set/comparing.dart';
import 'package:qme/controllers/slot.dart';
import 'package:qme/model/slot.dart';

Reception receptionFromJson(String str) => Reception.fromJson(json.decode(str));

String receptionToJson(Reception data) => json.encode(data.toJson());

class Reception {
  Reception({
    @required this.receptionId,
    @required this.subscriberId,
    @required this.startTime,
    @required this.endTime,
    @required this.duration,
    @required this.custPerSlot,
    @required this.status,
  });

  final String receptionId;
  final String subscriberId;
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;
  final int custPerSlot;
  final String status;

  SplayTreeSet<Slot> _slots =
      SplayTreeSet<Slot>(Comparing.on((slot) => slot.startTime));

  List<Slot> get slotList => _slots.toList();

  addSlot(Slot slot) => _slots.add(slot);

  addSlotList(List<Slot> slots) => _slots.addAll(slots);

  List<Slot> createSlots() {
    addSlotList(createSlotsFromDuration(this));
    return slotList;
  }

  factory Reception.fromJson(Map<String, dynamic> json) => Reception(
        receptionId: json["id"],
        subscriberId: json["subscriber_id"],
        startTime: DateTime.parse(json["starttime"]).toLocal(),
        endTime: DateTime.parse(json["endtime"]).toLocal(),
        duration: Duration(minutes: json["slot"]),
        custPerSlot: json["cust_per_slot"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "id": receptionId,
        "subscriber_id": subscriberId,
        "starttime": startTime.toIso8601String(),
        "endtime": endTime.toIso8601String(),
        "slot": duration,
        "cust_per_slot": custPerSlot,
        "status": status,
//        "slots": slotList,
      };
}
