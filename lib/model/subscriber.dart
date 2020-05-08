import 'dart:convert';

Subscribers subscribersFromJson(String str) =>
    Subscribers.fromJson(json.decode(str));

class Subscribers {
  List<Subscriber> list;
  int totalResults;

  Subscribers(this.list);

  Subscribers.fromJson(Map<String, dynamic> json) {
    list = [];
    if (json['subscribe'] != null) {
      json['subscribe'].forEach((v) {
        list.add(Subscriber.fromJson(v));
      });
    }
  }
}

class Subscriber {
  String id;
  String name;
  String owner;
  String email;
  String phone;

  Subscriber({
    this.id,
    this.name,
    this.owner,
    this.email,
    this.phone,
  });

  factory Subscriber.fromJson(Map<String, dynamic> json) => Subscriber(
        id: json["id"],
        name: json["name"],
        owner: json["owner"],
        email: json["email"],
        phone: json["phone"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "owner": owner,
        "email": email,
        "phone": phone,
      };
}
