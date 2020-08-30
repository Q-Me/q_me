import 'dart:convert';

import 'package:qme/api/kAPI.dart';

Subscribers subscribersFromJson(String str) =>
    Subscribers.fromJson(json.decode(str));

class Subscribers {
  Subscribers({
    this.list,
  });

  List<Subscriber> list;

  factory Subscribers.fromJson(Map<String, dynamic> json) {
    return Subscribers(
      list: List<Subscriber>.from(json["subscriber"].map((x) {
        return Subscriber.fromJson(Map<String, dynamic>.from(x));
      })),
    );
  }

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
  List<String> displayImages, tags;
  int rating;

  Subscriber({
    this.id,
    this.name,
    this.description,
    this.owner,
    this.email,
    this.phone,
    this.address,
    this.longitude,
    this.latitude,
    this.category,
    this.imgURL,
    this.verified,
    this.distance,
    this.displayImages,
    this.tags,
    this.rating,
  });

  factory Subscriber.fromJson(Map<String, dynamic> json) {
    String distance;
    if (json['distance'] != null) {
      distance = double.parse(json['distance']) > 1
          ? "${double.parse(json['distance'])} km"
          : "${double.parse(json['distance']) * 1000} m";
    }
    final String imgUrl = '$baseURL/user/profileimage/${json["profileImage"]}';
    List<String> displayImages = [imgUrl];
    displayImages.addAll(
      List<String>.from(json["displayImages"])
          .map((imgName) => '$baseURL/user/displayimage/$imgName')
          .toList(),
    );
    return Subscriber(
      id: json["id"],
      name: json["name"],
      owner: json["owner"],
      email: json["email"],
      phone: json["phone"],
      address: json["address"],
      imgURL: imgUrl,
      latitude: json["latitude"] != null
          ? double.parse(json["latitude"].toString())
          : null,
      longitude: json["longitude"] != null
          ? double.parse(json["longitude"].toString())
          : null,
      verified: int.parse(json['verified'].toString()) == 1 ? true : false,
      description: json["description"] == null || json["description"] == "NULL"
          ? ""
          : json["description"],
      category: json["category"],
      distance: distance,
      displayImages: displayImages,
      // tags: json["tags"] != null ? List<String>.from(json["tags"]) : null,
      rating: json["rating"],
    );
  }
  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "owner": owner,
        "email": email,
        "phone": phone,
        "address": address,
        "profileImage": imgURL,
        "latitude": latitude,
        "longitude": longitude,
        "verified": verified == true ? 1 : 0,
        "distance": distance,
        "description": description,
        "category": category,
        "displayImages": [displayImages],
        "tags": [tags],
      };
}
