import 'dart:convert';

import 'package:meta/meta.dart';

Reception receptionFromJson(String str) => Reception.fromJson(json.decode(str));

String receptionToJson(Reception data) => json.encode(data.toJson());

class Reception {
  Reception({
    @required this.receptionId,
    @required this.subscriberId,
    @required this.starttime,
    @required this.endtime,
    @required this.slot,
    @required this.custPerSlot,
    @required this.status,
  });

  final String receptionId;
  final String subscriberId;
  final DateTime starttime;
  final DateTime endtime;
  final int slot;
  final int custPerSlot;
  final String status;

  factory Reception.fromJson(Map<String, dynamic> json) => Reception(
        receptionId: json["id"],
        subscriberId: json["subscriber_id"],
        starttime: DateTime.parse(json["starttime"]).toLocal(),
        endtime: DateTime.parse(json["endtime"]).toLocal(),
        slot: json["slot"],
        custPerSlot: json["cust_per_slot"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "id": receptionId,
        "subscriber_id": subscriberId,
        "starttime": starttime.toIso8601String(),
        "endtime": endtime.toIso8601String(),
        "slot": slot,
        "cust_per_slot": custPerSlot,
        "status": status,
      };
}
