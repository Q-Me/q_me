import 'dart:convert';
import 'subscriber.dart';
import 'token.dart';

Queues queuesFromJson(String str) => Queues.fromJson(json.decode(str));

Duration durationFromString(String s) {
  List<int> parts = s.split(':').map(int.parse).toList();
  return Duration(hours: parts[0], minutes: parts[1]);
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
        startDateTime: DateTime.parse(json["start_date_time"]).toLocal(),
        endDateTime: DateTime.parse(json["end_date_time"]).toLocal(),
        maxAllowed: json["max_allowed"],
        avgTimeOnCounter: json["avg_time_on_counter"],
        status: json["status"],
        currentToken: json["current_token"],
        lastIssuedToken: json["last_issued_token"],
        lastUpdate: DateTime.parse(json["last_update"]).toLocal(),
        totalIssuedTokens: json["total_issued_tokens"],
        subscriber: json["subscriber"] != null
            ? Subscriber.fromJson(json["subscriber"])
            : Subscriber(),
        eta: json["ETA"] != null ? durationFromString(json["ETA"]) : Duration(),
        token: json["token"] != null
            ? QueueToken.fromJson(json["token"])
            : json["token"],
      );
  Map<String, dynamic> toJson() => {
        "queue_id": queueId,
        "start_date_time": startDateTime.toIso8601String(),
        "end_date_time": endDateTime.toIso8601String(),
        "max_allowed": maxAllowed,
        "avg_time_on_counter": avgTimeOnCounter,
        "status": status,
        "current_token": currentToken,
        "last_issued_token": lastIssuedToken,
        "last_update": lastUpdate.toIso8601String(),
        "total_issued_tokens": totalIssuedTokens,
        "subscriber": subscriber.toJson(),
        "ETA": eta,
        "token": token != null ? token.toJson() : null,
      };
}
