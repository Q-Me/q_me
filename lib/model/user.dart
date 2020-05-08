import 'dart:convert';
import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

class UserData {
  String id;
  String name;
  bool isUser;
  String accessToken;
  String refreshToken;

  UserData({
    this.id,
    this.name,
    this.isUser,
    this.accessToken,
    this.refreshToken,
  });

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
        id: json["id"],
        name: json["name"],
        isUser: json["isUser"],
        accessToken: json["accessToken"],
        refreshToken: json["refreshToken"],
      );

  /*factory UserData.fromStorage() async {
    Future<SharedPreferences> prefs = await SharedPreferences.getInstance();

    return UserData(
      id: prefs.getString('id') ?? null,
      name: prefs.getString('name') ?? null,
      accessToken: prefs.getString('name') ?? null,
      refreshToken: prefs.getString('refreshToken') ?? null,
      isUser: prefs.getBool('isUser') ?? null,
    );
  }*/

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "isUser": isUser,
        "accessToken": accessToken,
        "refreshToken": refreshToken,
      };
}

void storeUserData(UserData userData) async {
  // Set the user id, and other details are stored in local storage of the app
  SharedPreferences prefs = await SharedPreferences.getInstance();

  prefs.setString('id', userData.id);
  prefs.setString('name', userData.name);
  prefs.setString('accessToken', userData.accessToken);
  prefs.setString('refreshToken', userData.refreshToken);
  prefs.setBool('isUser', userData.isUser);

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
  bool isUser = prefs.getBool('isUser') ?? null;

  return UserData(
    id: id,
    name: name,
    accessToken: accessToken,
    refreshToken: refreshToken,
    isUser: isUser,
  );
}

UserData userDataFromJson(String str) => UserData.fromJson(json.decode(str));

String userDataToJson(UserData data) => json.encode(data.toJson());
