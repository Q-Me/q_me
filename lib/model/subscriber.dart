import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:qme/api/kAPI.dart';
import 'package:meta/meta.dart';
import 'package:qme/utilities/logger.dart';

Subscriber subscriberFromJson(String str) =>
    Subscriber.fromJson(json.decode(str));

class Subscriber extends Equatable {
  String id, name, description, address, email, phone, owner, imgURL, category;
  double latitude, longitude, distance;

  bool verified;
  List<String> displayImages, tags;
  double rating;

  Subscriber({
    @required this.id,
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

  double get quantizedRating {
    final round = rating.round().toDouble();
    final lowerInt = rating.toInt().toDouble();
    if (round - lowerInt > 0.5) {
      return lowerInt + 0.5;
    } else {
      return lowerInt;
    }
  }

  String get shortAddress {
    final aList = address.split(",");
    if (aList.length >= 2)
      return aList.elementAt(aList.length - 2).trimLeft() +
          ', ' +
          aList.elementAt(aList.length - 1);
    else if (aList.length >= 1)
      return aList.elementAt(aList.length - 1);
    else
      return address;
  }

  factory Subscriber.fromJson(Map<String, dynamic> json) {
    // String distance;
    // if (json['distance'] != null) {
    //   print(json['distance'].runtimeType);
    //   distance = double.tryParse(json['distance']) > 1
    //       ? "${double.parse(json['distance'])} km"
    //       : "${double.parse(json['distance']) * 1000} m";
    // }
    // logger.d(json);
    final String imgUrl = '$baseURL/user/profileimage/${json["profileImage"]}';
    List<String> displayImages = [imgUrl];

    if (json['displayImages'] != null) {
      displayImages.addAll(List.from(json["displayImages"])
          .map((imgName) => '$baseURL/user/displayimage/$imgName')
          .toList());
    }
    // logger.d(displayImages.toString());
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
      distance: json["distance"],
      displayImages: displayImages,
      // tags: json["tags"] != null ? List<String>.from(json["tags"]) : null,
      rating: json["rating"] == null ? -1.0 : json["rating"].toDouble(),
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

  @override
  List<Object> get props => [id];
}

class CategorySubscriberList extends Equatable {
  final String categoryName;
  List<Subscriber> subscribers;

  CategorySubscriberList({
    @required this.categoryName,
    this.subscribers,
  });

  Map<String, dynamic> toJson() => {
        "category": categoryName,
        "subscribers": subscribers.map((e) => '{id:${e.id}}').toList(),
      };

  @override
  List<Object> get props => [categoryName, subscribers];
}
