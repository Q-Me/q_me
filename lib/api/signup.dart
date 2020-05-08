import 'package:http/http.dart' as http;
import 'dart:convert';
import 'kAPI.dart';
import 'dart:developer';
import 'dart:core';

Future<String> signUp(String firstName, String lastName, String email,
    String password, String phone) async {
  final req = {
    "name": "$firstName|$lastName",
    "email": email,
    "phone": phone,
    "password": password
  };
  final response = await http.post(
    baseURL + '/user/signup',
    headers: {"Content-type": "application/json"},
    body: jsonEncode(req),
  );
  final decodedJSON = jsonDecode(response.body);
  log('$decodedJSON');
  if (response.statusCode == 200) {
    return decodedJSON['msg'];
  } else {
    return decodedJSON['error'];
  }
}
