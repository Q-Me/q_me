import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:qme/api/base_helper.dart';
import 'package:qme/api/endpoints.dart';

import '../model/user.dart';
import 'kAPI.dart';

/* Future<Map> signInWithPassword(String phoneNumber, String password) async {
  // TODO refactor this into UserRepository (lib/repository/user.dart)
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
  // TODO refactor this into UserRepository (lib/repository/user.dart)

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
  // TODO refactor this into UserRepository (lib/repository/user.dart)

  ApiBaseHelper _helper = ApiBaseHelper();
  final UserData userData = await getUserDataFromStorage();
  var response = await http.post(
    baseURL + fcmUrl,
    body: {"token": fcmToken},
    headers: {'Authorization': 'Bearer ${userData.accessToken}'},
  );
  final decodedJSON = jsonDecode(response.body);
  if (response.statusCode == 200) {
    return {'status': 200};
  } else
    return {'status': response.statusCode, 'error': decodedJSON['error']};
}
 */