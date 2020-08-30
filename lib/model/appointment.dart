// To parse this JSON data, do
//
//     final appointment = appointmentFromMap(jsonString);

import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:qme/model/slot.dart';

Appointment appointmentFromMap(String str) =>
    Appointment.fromMap(json.decode(str));

String appointmentToMap(Appointment data) => json.encode(data.toMap());

class Appointment extends Equatable {
  Appointment({
    this.subscriberName,
    this.longitude,
    this.latitude,
    this.phone,
    this.address,
    this.category,
    this.verified,
    this.profileImage,
    this.counterStartTime,
    this.counterEndTime,
    this.counterStatus,
    this.subscriberId,
    this.counterId,
    this.slot,
    this.slotStatus,
    this.note,
    this.otp,
    this.rating,
  });

  final String subscriberName;
  final double longitude;
  final double latitude;
  final String phone;
  final String address;
  final String category;
  final int verified;
  final String profileImage;
  final DateTime counterStartTime;
  final DateTime counterEndTime;
  final String counterStatus;
  final String subscriberId;
  final String counterId;
  final Slot slot;
  final String slotStatus;
  final String note;
  final otp;
  final rating;

  @override
  List<Object> get props => [
        subscriberName,
        longitude,
        latitude,
        phone,
        address,
        category,
        verified,
        profileImage,
        counterStartTime,
        counterEndTime,
        counterStatus,
        subscriberId,
        counterId,
        slot,
        slotStatus,
        note,
        otp,
      ];

  factory Appointment.fromMap(Map<String, dynamic> json) => Appointment(
        subscriberName: json["subscriber"] == null ? null : json["subscriber"],
        longitude:
            json["longitude"] == null ? null : json["longitude"].toDouble(),
        latitude: json["latitude"] == null ? null : json["latitude"].toDouble(),
        phone: json["phone"] == null ? null : json["phone"],
        address: json["address"] == null ? null : json["address"],
        category: json["category"] == null ? null : json["category"],
        verified: json["verified"] == null ? null : json["verified"],
        profileImage:
            json["profileImage"] == null ? null : json["profileImage"],
        counterStartTime: json["counter_starttime"] == null
            ? null
            : DateTime.parse(json["counter_starttime"]).toLocal(),
        counterEndTime: json["counter_endtime"] == null
            ? null
            : DateTime.parse(json["counter_endtime"]).toLocal(),
        counterStatus:
            json["counter_status"] == null ? null : json["counter_status"],
        subscriberId:
            json["subscriber_id"] == null ? null : json["subscriber_id"],
        counterId: json["counter_id"] == null ? null : json["counter_id"],
        slot: Slot(
          startTime: json["slot_starttime"] == null
              ? null
              : DateTime.parse(json["slot_starttime"]).toLocal(),
          endTime: json["slot_endtime"] == null
              ? null
              : DateTime.parse(json["slot_endtime"]).toLocal(),
        ),
        slotStatus: json["slot_status"] == null ? null : json["slot_status"],
        note: json["note"] == null ? null : json["note"],
        otp: json["otp"] == null ? null : json["otp"],
        rating: json["rating"] == null ? null : json["rating"],
      );

  Map<String, dynamic> toMap() => {
        "subscriber": subscriberName == null ? null : subscriberName,
        "longitude": longitude == null ? null : longitude,
        "latitude": latitude == null ? null : latitude,
        "phone": phone == null ? null : phone,
        "address": address == null ? null : address,
        "category": category == null ? null : category,
        "verified": verified == null ? null : verified,
        "profileImage": profileImage == null ? null : profileImage,
        "counter_starttime": counterStartTime == null
            ? null
            : counterStartTime.toIso8601String(),
        "counter_endtime":
            counterEndTime == null ? null : counterEndTime.toIso8601String(),
        "counter_status": counterStatus == null ? null : counterStatus,
        "subscriber_id": subscriberId == null ? null : subscriberId,
        "counter_id": counterId == null ? null : counterId,
        "slot_starttime":
            slot.startTime == null ? null : slot.startTime.toIso8601String(),
        "slot_endtime":
            slot.endTime == null ? null : slot.endTime.toIso8601String(),
        "slot_status": slotStatus == null ? null : slotStatus,
        "note": note == null ? null : note,
        "otp": otp == null ? null : otp,
        "rating": rating == null ? null : rating,
      };
}
