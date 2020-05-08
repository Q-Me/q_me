import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';
import '../model/user.dart';
import 'dart:core';
import 'kAPI.dart';

Future<Map> signIn(String email, String password) async {
  final response = await http.post(
    baseURL + '/user/login',
    headers: {"Content-type": "application/json"},
    body: jsonEncode(
      <String, String>{'email': email, 'password': password},
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
