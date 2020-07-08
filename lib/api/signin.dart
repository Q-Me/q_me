import 'dart:async';
import 'package:http/http.dart' as http;
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
