import 'dart:convert';

Tokens tokensFromJson(String str) => Tokens.fromJson(json.decode(str));

String tokensToJson(Tokens data) => json.encode(data.toJson());

class Tokens {
  Tokens({
    this.tokenList,
  });

  List<QueueToken> tokenList;

  factory Tokens.fromJson(Map<String, dynamic> json) => Tokens(
        tokenList: List<QueueToken>.from(
            json["token"].map((x) => QueueToken.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "token": List<dynamic>.from(tokenList.map((x) => x.toJson())),
      };
}

class QueueToken {
  QueueToken({
    this.subscriber,
    this.longitude,
    this.latitude,
    this.phone,
    this.address,
    this.category,
    this.verified,
    this.profileImage,
    this.startDateTime,
    this.endDateTime,
    this.currentToken,
    this.queueStatus,
    this.queueId,
    this.subscriberId,
    this.tokenNo,
    this.tokenStatus,
    this.note,
  });

  String subscriber;
  double longitude;
  double latitude;
  String phone;
  String address;
  String category;
  int verified;
  String profileImage;
  DateTime startDateTime;
  DateTime endDateTime;
  int currentToken;
  String queueStatus;
  String queueId;
  String subscriberId;
  int tokenNo;
  String tokenStatus;
  String note;

  factory QueueToken.fromJson(Map<String, dynamic> json) => QueueToken(
        subscriber: json["subscriber"],
        longitude: json["longitude"].toDouble(),
        latitude: json["latitude"].toDouble(),
        phone: json["phone"],
        address: json["address"],
        category: json["category"],
        verified: json["verified"],
        profileImage: json["profileImage"],
        startDateTime: DateTime.parse(json["start_date_time"]),
        endDateTime: DateTime.parse(json["end_date_time"]),
        currentToken: json["current_token"],
        queueStatus: json["queue_status"],
        queueId: json["queue_id"],
        subscriberId: json["subscriber_id"],
        tokenNo: json["token_no"],
        tokenStatus: json["token_status"],
        note: json["note"],
      );

  Map<String, dynamic> toJson() => {
        "subscriber": subscriber,
        "longitude": longitude,
        "latitude": latitude,
        "phone": phone,
        "address": address,
        "category": category,
        "verified": verified,
        "profileImage": profileImage,
        "start_date_time": startDateTime.toIso8601String(),
        "end_date_time": endDateTime.toIso8601String(),
        "current_token": currentToken,
        "queue_status": queueStatus,
        "queue_id": queueId,
        "subscriber_id": subscriberId,
        "token_no": tokenNo,
        "token_status": tokenStatus,
        "note": note,
      };
}
