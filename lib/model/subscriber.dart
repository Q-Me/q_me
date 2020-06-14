import 'dart:convert';

Subscribers subscribersFromJson(String str) =>
    Subscribers.fromJson(json.decode(str));

class Subscribers {
  Subscribers({
    this.list,
  });

  List<Subscriber> list;

  factory Subscribers.fromJson(Map<String, dynamic> json) => Subscribers(
        list: List<Subscriber>.from(
            json["subscriber"].map((x) => Subscriber.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "subscriber": List<dynamic>.from(list.map((x) => x.toJson())),
      };
}

class Subscriber {
  String id,
      name,
      description,
      address,
      email,
      phone,
      owner,
      imgURL,
      distance,
      category;
  double latitude, longitude;
  bool verified;

  Subscriber({
    this.id,
    this.name,
    this.description,
    this.owner,
    this.email,
    this.phone,
    this.address,
    this.imgURL,
    this.latitude,
    this.longitude,
    this.verified,
    this.category,
    this.distance,
  });

  factory Subscriber.fromJson(Map<String, dynamic> json) {
    String distance;
    if (json['distance'] != null) {
      distance = double.parse(json['distance']) > 1
          ? "${double.parse(json['distance'])} km"
          : "${double.parse(json['distance']) * 1000} m";
    }
    return Subscriber(
      id: json["id"],
      name: json["name"],
      owner: json["owner"],
      email: json["email"],
      phone: json["phone"],
      address: json["address"],
      imgURL: json["imgURL"],
      latitude: json["latitude"],
      longitude: json["longitude"],
      verified: json['verified'] == 1 ? true : false,
      description: json["description"],
      category: json["category"],
      distance: distance,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "owner": owner,
        "email": email,
        "phone": phone,
        "address": address,
        "imgURL": imgURL,
        "latitude": latitude,
        "longitude": longitude,
        "verified": verified == true ? "1" : "0",
        "distance": distance,
        "description": description,
        "category": category,
      };
}
