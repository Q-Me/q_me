import 'dart:collection';
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:ordered_set/comparing.dart';
import 'package:qme/controllers/slot_controller.dart';
import 'package:qme/model/slot.dart';
import 'package:qme/utilities/logger.dart';

Reception receptionFromJson(String str) => Reception.fromJson(json.decode(str));

String receptionToJson(Reception data) => json.encode(data.toJson());

class Reception extends Equatable {
  Reception({
    @required this.id,
    @required this.subscriberId,
    @required this.startTime,
    @required this.endTime,
    @required this.duration,
    @required this.custPerSlot,
    @required this.status,
    this.availableForBooking = true,
  }) {
    createSlots();
  }

  final String id;
  Slot bookedSlot;
  final String subscriberId;
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;
  final int custPerSlot;
  final String status;
  bool availableForBooking;
  SplayTreeSet<Slot> _slots =
      SplayTreeSet<Slot>(Comparing.on((slot) => slot.startTime));

  @override
  List<Object> get props => [
        id,
        subscriberId,
        startTime,
        endTime,
        duration,
        custPerSlot,
        status,
        _slots,
        availableForBooking
      ];

  List<Slot> get slotList => _slots.toList();

  addSlot(Slot slot) => _slots.add(slot);

  addSlotList(List<Slot> slots) {
    _slots.clear();
    _slots.addAll(slots);
  }

  List<Slot> createSlots() {
    addSlotList(createSlotsFromDuration(this));
    return slotList;
  }

  factory Reception.fromJson(Map<String, dynamic> json) {
    // Check if detailed reception is in the json
    if (json["counter"] == null) {
      return Reception(
        id: json["id"],
        subscriberId: json["subscriber_id"],
        startTime: DateTime.parse(json["starttime"]),
        endTime: DateTime.parse(json["endtime"]),
        duration: Duration(minutes: json["slot"]),
        custPerSlot: json["cust_per_slot"],
        status: json["status"],
      );
    } else {
      // Detailed reception needs to be created
      Reception reception = Reception.fromJson(json["counter"]);
      List<Slot> slots = reception.slotList;
      slots = overrideSlots(slots, createOverrideSlots(json));

      slots = modifyBookings(slots, json["slots_upcoming"]);
      slots = modifyDoneSlots(slots, json["slots_done"]);
      reception.addSlotList(slots);

      /*
      for (Slot slot in slots) {
        logger.d(slot.toJson());
      }
      */

      return reception;
    }
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "subscriber_id": subscriberId,
        "starttime": startTime.toIso8601String(),
        "endtime": endTime.toIso8601String(),
        "slot": duration,
        "cust_per_slot": custPerSlot,
        "status": status,
//        "slots": slotList,
      };
}
