import 'dart:convert';
import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

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
        isUser: json["isUser"],
        accessToken: json["accessToken"],
        refreshToken: json["refreshToken"],
        email: json['email'],
        phone: json['phone'],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "isUser": isUser,
        "accessToken": accessToken,
        "refreshToken": refreshToken,
        "email": email,
        "phone": phone,
      };
}

void storeUserData(UserData userData) async {
  // Set the user id, and other details are stored in local storage of the app
  SharedPreferences prefs = await SharedPreferences.getInstance();

  if (userData.id != null) prefs.setString('id', userData.id);
  if (userData.name != null) prefs.setString('name', userData.name);
  if (userData.accessToken != null)
    prefs.setString('accessToken', userData.accessToken);
  if (userData.refreshToken != null)
    prefs.setString('refreshToken', userData.refreshToken);
  if (userData.isUser != null) prefs.setBool('isUser', userData.isUser);
  if (userData.email != null) prefs.setString('isUser', userData.email);
  if (userData.phone != null) prefs.setString('isUser', userData.phone);

  log('Storing user data succeess');

  return;
}

Future<UserData> getUserDataFromStorage() async {
  // See if user id, and other details are stored in local storage of the app
  SharedPreferences prefs = await SharedPreferences.getInstance();

  String id = prefs.getString('id') ?? null;
  String name = prefs.getString('name') ?? null;
  String accessToken = prefs.getString('accessToken') ?? null;
  String refreshToken = prefs.getString('refreshToken') ?? null;
  String email = prefs.getString('email') ?? null;
  String phone = prefs.getString('phone') ?? null;
  bool isUser = prefs.getBool('isUser') ?? null;

  return UserData(
    id: id,
    name: name,
    accessToken: accessToken,
    refreshToken: refreshToken,
    isUser: isUser,
    email: email,
    phone: phone,
  );
}

UserData userDataFromJson(String str) => UserData.fromJson(json.decode(str));

String userDataToJson(UserData data) => json.encode(data.toJson());
