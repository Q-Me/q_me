import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:qme/utilities/logger.dart';

class UserData {
  String id, name, email, phone, accessToken, refreshToken;
  bool isUser;

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

Future<void> storeUserData(UserData userData) async {
  // Set the user id, and other details are stored in local storage of the app

  Box box = await Hive.openBox("user");

  if (userData.id != null) await box.put('id', userData.id);
  if (userData.name != null) await box.put('name', userData.name);
  if (userData.accessToken != null) {
    await box.put('accessToken', userData.accessToken);
    await box.put('expiry', DateTime.now().add(Duration(days: 1)).toString());
  }
  if (userData.refreshToken != null)
    await box.put('refreshToken', userData.refreshToken);
  if (userData.email != null) await box.put('isUser', userData.email);
  if (userData.phone != null) await box.put('isUser', userData.phone);

  logger.d('Storing user data success');

  return;
}

Future<String> getAccessTokenFromStorage() async {
  Box box = await Hive.openBox("user");
  String accessToken = await box.get('accessToken') ?? null;
  return accessToken;
}

Future<UserData> getUserDataFromStorage() async {
  // See if user id, and other details are stored in local storage of the app
  Box box = await Hive.openBox("user");

  String id = await await box.get('id') ?? null;
  String name = await box.get('name') ?? null;
  String accessToken = await box.get('accessToken') ?? null;
  String refreshToken = await box.get('refreshToken') ?? null;
  String email = await box.get('email') ?? null;
  String phone = await box.get('phone') ?? null;

  return UserData(
    id: id,
    name: name,
    accessToken: accessToken,
    refreshToken: refreshToken,
    email: email,
    phone: phone,
  );
}

UserData userDataFromJson(String str) => UserData.fromJson(json.decode(str));

String userDataToJson(UserData data) => json.encode(data.toJson());
