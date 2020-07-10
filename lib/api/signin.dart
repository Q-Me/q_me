import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:qme/api/base_helper.dart';
import 'package:qme/api/endpoints.dart';
import 'dart:convert';
import 'dart:developer';
import '../model/user.dart';
import 'dart:core';
import 'kAPI.dart';

Future<Map> signInWithPassword(String phoneNumber, String password) async {
  final response = await http.post(
    baseURL + signInPasswordUrl,
    headers: {"Content-type": "application/json"},
    body: jsonEncode(
      <String, String>{'phone': phoneNumber, 'password': password},
    ),
  );

  final decodedJSON = jsonDecode(response.body);
  log('signin JSON = $decodedJSON');
  if (response.statusCode == 200) {
    storeUserData(userDataFromJson(response.body));
    return {'status': 200};
  } else
    // display this error(s) in snackBar
    return {'status': response.statusCode, 'error': decodedJSON['error']};
}
Future<Map> signInWithOtp(String idToken) async {
  final response = await http.post(
    baseURL + signInOtpUrl,
    headers: {"Content-type": "application/json"},
    body: jsonEncode(
      <String, String>{'token': idToken},
    ),
  );

  final decodedJSON = jsonDecode(response.body);
  log('signin JSON = $decodedJSON');
  if (response.statusCode == 200) {
    storeUserData(userDataFromJson(response.body));
    return {'status': 200};
  } else
    return {'status': response.statusCode, 'error': decodedJSON['error']};
}


Future<Map> fcmTokenSubmit(String fcmToken) async {
  ApiBaseHelper _helper = ApiBaseHelper();
  final UserData userData = await getUserDataFromStorage();
  print("userData.accessToken ${userData.accessToken}");
  print("fcm $fcmToken");
  var response = await http.post(
    baseURL + fcmUrl,
    body: {"token": fcmToken},
    headers: {'Authorization': 'Bearer ${userData.accessToken}'},  
  );
    print("response: ${response.statusCode} and ${response.body}");

  final decodedJSON = jsonDecode(response.body);
  if (response.statusCode == 200) {
    return {'status': 200};
  } else
    return {'status': response.statusCode, 'error': decodedJSON['error']};
}
