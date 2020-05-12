import 'dart:convert';

Subscribers subscribersFromJson(String str) =>
    Subscribers.fromJson(json.decode(str));

class Subscribers {
  List<Subscriber> list;
  int totalResults;

  Subscribers(this.list);

  Subscribers.fromJson(Map<String, dynamic> json) {
    list = [];
    final subs = json['subscriber'];
    if (subs != null) {
      subs.forEach((v) {
        list.add(Subscriber.fromJson(v));
      });
      totalResults = list.length;
    }
  }
}

class Subscriber {
  String id, name, address, email, phone, owner;

  Subscriber({
    this.id,
    this.name,
    this.owner,
    this.email,
    this.phone,
    this.address,
  });

  factory Subscriber.fromJson(Map<String, dynamic> json) => Subscriber(
        id: json["id"],
        name: json["name"],
        owner: json["owner"],
        email: json["email"],
        phone: json["phone"],
        address: json["address"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "owner": owner,
        "email": email,
        "phone": phone,
        "address": address
      };
}
