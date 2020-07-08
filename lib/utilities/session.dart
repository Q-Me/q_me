import 'dart:convert';

import '../model/user.dart';

void setSession() async {
  final Map<String, dynamic> signInResponse = jsonDecode('''
{
    "id": "Epq4hLrOt",
    "name": "Mr. B",
    "phone": "+919673582517",
    "isUser": true,
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IkVwcTRoTHJPdCIsIm5hbWUiOiJNci4gQiIsInBob25lIjoiKzkxOTY3MzU4MjUxNyIsImlzVXNlciI6dHJ1ZSwiaWF0IjoxNTk0MTI1MzQ3LCJleHAiOjE1OTQyMTE3NDd9.5AdVXYB0kM-nF-UoSHvY-sdDPO8HJT_WEMz82-qh4x8",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IkVwcTRoTHJPdCIsIm5hbWUiOiJNci4gQiIsInBob25lIjoiKzkxOTY3MzU4MjUxNyIsImlzVXNlciI6dHJ1ZSwiaWF0IjoxNTk0MTI1MzQ3fQ.qbddxXRH8XciDc7mTMpbYPRuRuYUmQDQCj5ELrFDOF8"
}''');
  await storeUserData(UserData.fromJson(signInResponse));
}

void test() async {
  setSession();
  UserData userData = await getUserDataFromStorage();
  print(userData.toJson());
}
