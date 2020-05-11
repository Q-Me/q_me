import 'dart:developer';

class QueueToken {
  int tokenNo, ahead;
  String subscriberId, userId, queueId, status;

  QueueToken({
    this.tokenNo = -1,
    this.status,
    this.subscriberId,
    this.ahead,
    this.userId,
    this.queueId,
  });

  factory QueueToken.fromJson(Map<String, dynamic> json) {
//    log('$json');
    return QueueToken(
        tokenNo: json["token_no"] ?? -1,
        status: json["status"],
        subscriberId: json["subscriber_id"],
        ahead: json["ahead"] ?? -1,
//        userId: json["ahead"] != null ? json["ahead"] : null,
        queueId: json["queue_id"]);
  }

  Map<String, dynamic> toJson() => {
        "token_no": tokenNo,
        "status": status,
        "subscriber_id": subscriberId,
        "ahead": ahead,
      };
}
