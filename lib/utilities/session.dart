import 'dart:convert';

import '../model/user.dart';

void setSession() async {
  final Map<String, dynamic> signInResponse = jsonDecode('''
  {
    "id": "Epq4hLrOt",
    "name": "Mr. B",
    "phone": "+919673582517",
    "isUser": true,
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IkVwcTRoTHJPdCIsIm5hbWUiOiJNci4gQiIsInBob25lIjoiKzkxOTY3MzU4MjUxNyIsImlzVXNlciI6dHJ1ZSwiaWF0IjoxNTkzOTQ0MDY2LCJleHAiOjE1OTQwMzA0NjZ9.BTGO9RmJVL6Z6Hj6p3flS2YYDqU_gukJtWZm4n8CFWw",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IkVwcTRoTHJPdCIsIm5hbWUiOiJNci4gQiIsInBob25lIjoiKzkxOTY3MzU4MjUxNyIsImlzVXNlciI6dHJ1ZSwiaWF0IjoxNTkzOTQ0MDY2fQ.HK8CNaSj2Ac6auPalP-R68_I2wrnKu2dUonJS9039gM"
}''');
  await storeUserData(UserData.fromJson(signInResponse));
}

void test() async {
  setSession();
  UserData userData = await getUserDataFromStorage();
  print(userData.toJson());
}
