import 'package:http/http.dart' as http;
import '../model/subscriber.dart';
import '../model/user.dart';
import 'dart:convert';
import 'kAPI.dart';
import 'dart:core';

Future<Map> getAllSubscribers() async {
  UserData userData = await getUserDataFromStorage();
  final req = {"accessToken": userData.accessToken};

  final response = await http.post(
    baseURL + '/user/getallsubscriber',
    headers: {"Content-type": "application/json"},
    body: jsonEncode(req),
  );

  final decodedJson = jsonDecode(response.body);
  if (response.statusCode == 200) {
    return {'status': 200, 'data': Subscribers.fromJson(decodedJson)};
  } else {
    return {'status': response.statusCode, 'error': decodedJson};
  }
}
