import 'dart:convert';

import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 3)
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
  @HiveField(10)
  String password;
  @HiveField(11)
  String idToken;
  @HiveField(12)
  String gender;

  UserData(
      {this.id,
      this.name,
      this.isUser,
      this.accessToken,
      this.refreshToken,
      this.email,
      this.phone,
      this.expiry,
      this.fcmToken,
      this.isGuest,
      this.password,
      this.idToken,
      this.gender});

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
        id: json["id"],
        name: json["name"],
        accessToken: json["accessToken"],
        refreshToken: json["refreshToken"],
        email: json['email'],
        phone: json['phone'],
      );

  Map<String, dynamic> toJson() => <String, String>{
        "id": id,
        "name": name,
        "accessToken": accessToken,
        "refreshToken": refreshToken,
        "email": email,
        "phone": phone,
      };

  Map<String, dynamic> toCompleteJson() => {
        "id": id != null ? id : "null",
        "name": name != null ? name : "null",
        "isUser": isUser != null ? isUser : "null",
        "email": email != null ? email : "null",
        "phone": phone != null ? phone : "null",
        "expiry": expiry != null ? expiry : "null",
        "fcmToken": fcmToken != null ? fcmToken : "null",
        "isGuest": isGuest != null ? isGuest : "null",
        "idToken": idToken != null ? idToken : "null",
        "gender": gender != null ? gender : "null",
      };
}

void updateUserData(UserData updated) {
  UserData old = Hive.box("users").get("this");
  if (old != null) {
    if (updated.id != null) old.id = updated.id;
    if (updated.name != null) old.name = updated.name;
    if (updated.isUser != null) old.isUser = updated.isUser;
    if (updated.accessToken != null) old.accessToken = updated.accessToken;
    if (updated.refreshToken != null) old.refreshToken = updated.refreshToken;
    if (updated.email != null) old.email = updated.email;
    if (updated.phone != null) old.phone = updated.phone;
    if (updated.expiry != null) old.expiry = updated.expiry;
    if (updated.fcmToken != null) old.fcmToken = updated.fcmToken;
    if (updated.isGuest != null) old.isGuest = updated.isGuest;
    if (updated.password != null) old.password = updated.password;
    if (updated.idToken != null) old.idToken = updated.idToken;
    old.save();
  } else {
    old = updated;
    Hive.box("users").put("this", old);
  }
}

String getAccessTokenFromStorage() {
  UserData user = Hive.box("users").get("this");
  return user.accessToken;
}

UserData getUserDataFromStorage() {
  UserData user = Hive.box("users").get("this");
  if (user == null) {
    user = UserData();
    updateUserData(user);
    return getUserDataFromStorage();
  }
  return user;
}

Future<bool> isUserDataInStorage() async {
  if (!(await Hive.boxExists("users"))) {
    return false;
  } else {
    return true;
  }
}

UserData userDataFromJson(String str) => UserData.fromJson(json.decode(str));

String userDataToJson(UserData data) => json.encode(data.toJson());
