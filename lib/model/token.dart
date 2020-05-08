class QueueToken {
  int tokenNo;
  String status;
  String subscriberId;
  int ahead;

  QueueToken({
    this.tokenNo,
    this.status,
    this.subscriberId,
    this.ahead,
  });

  factory QueueToken.fromJson(Map<String, dynamic> json) => QueueToken(
        tokenNo: json["token_no"],
        status: json["status"],
        subscriberId: json["subscriber_id"],
        ahead: json["ahead"],
      );

  Map<String, dynamic> toJson() => {
        "token_no": tokenNo,
        "status": status,
        "subscriber_id": subscriberId,
        "ahead": ahead,
      };
}
