import 'dart:convert';

import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 1)
class UserData extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String email;
  @HiveField(3)
  String phone;
  @HiveField(4)
  String accessToken;
  @HiveField(5)
  String refreshToken;
  @HiveField(6)
  bool isUser;
  @HiveField(7)
  String fcmToken;
  @HiveField(8)
  bool isGuest;
  @HiveField(9)
  DateTime expiry;

  UserData({
    this.id,
    this.name,
    this.isUser,
    this.accessToken,
    this.refreshToken,
    this.email,
    this.phone,
  });

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
        id: json["id"],
        name: json["name"],
        accessToken: json["accessToken"],
        refreshToken: json["refreshToken"],
        email: json['email'],
        phone: json['phone'],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "accessToken": accessToken,
        "refreshToken": refreshToken,
        "email": email,
        "phone": phone,
      };
}

void storeUserData(UserData userData) =>
    Hive.box("users").put("this", userData);

String getAccessTokenFromStorage() {
  UserData user = Hive.box("users").get("this");
  return user.accessToken;
}

UserData getUserDataFromStorage() {
  UserData user = Hive.box("users").get("this");
  return user;
}

UserData userDataFromJson(String str) => UserData.fromJson(json.decode(str));

String userDataToJson(UserData data) => json.encode(data.toJson());
