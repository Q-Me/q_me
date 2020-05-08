import 'dart:convert';
import 'subscriber.dart';
import 'token.dart';

Queues queuesFromJson(String str) => Queues.fromJson(json.decode(str));

Duration durationFromString(String s) {
  int hours = 0;
  int minutes = 0;
  int micros;
  List<String> parts = s.split(':');
  if (parts.length > 2) {
    hours = int.parse(parts[parts.length - 3]);
  }
  if (parts.length > 1) {
    minutes = int.parse(parts[parts.length - 2]);
  }
  micros = (double.parse(parts[parts.length - 1]) * 1000000).round();
  return Duration(hours: hours, minutes: minutes, microseconds: micros);
}

class Queues {
  List<Queue> queue;

  Queues({this.queue});

  factory Queues.fromJson(Map<String, dynamic> json) => Queues(
        queue: List<Queue>.from(json["queue"].map((x) => Queue.fromJson(x))),
      );
}

class Queue {
  String queueId;
  DateTime startDateTime;
  DateTime endDateTime;
  int maxAllowed;
  int avgTimeOnCounter;
  String status;
  int currentToken;
  int lastIssuedToken;
  DateTime lastUpdate;
  int totalIssuedTokens;
  Subscriber subscriber;
  Duration eta;
  QueueToken token;

  Queue({
    this.queueId,
    this.startDateTime,
    this.endDateTime,
    this.maxAllowed,
    this.avgTimeOnCounter,
    this.status,
    this.currentToken,
    this.lastIssuedToken,
    this.lastUpdate,
    this.totalIssuedTokens,
    this.subscriber,
    this.eta,
    this.token,
  });

  factory Queue.fromJson(Map<String, dynamic> json) => Queue(
        queueId: json["queue_id"],
        startDateTime: DateTime.parse(json["start_date_time"]),
        endDateTime: DateTime.parse(json["end_date_time"]),
        maxAllowed: json["max_allowed"],
        avgTimeOnCounter: json["avg_time_on_counter"],
        status: json["status"],
        currentToken: json["current_token"],
        lastIssuedToken: json["last_issued_token"],
        lastUpdate: DateTime.parse(json["last_update"]),
        totalIssuedTokens: json["total_issued_tokens"],
        subscriber: Subscriber.fromJson(json["subscriber"]),
        eta: durationFromString(json["ETA"]),
        token: QueueToken.fromJson(json["token"]),
      );
}
