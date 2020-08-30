class Review {
  Review({
    this.counterId,
    this.custName,
    this.subscriberId,
    this.review,
    this.rating,
  });

  String counterId;
  String custName;
  String subscriberId;
  String review;
  double rating;

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        counterId: json["counter_id"],
        custName: json["cust_name"],
        subscriberId: json["subscriber_id"],
        review: json["review"],
        rating:
            json["rating"] is int ? json["rating"].toDouble() : json["rating"],
      );

  Map<String, dynamic> toJson() => {
        "counter_id": counterId,
        "cust_name": custName,
        "subscriber_id": subscriberId,
        "review": review,
        "rating": rating,
      };
}
