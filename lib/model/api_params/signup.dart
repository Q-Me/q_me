import 'package:flutter/material.dart';

class SignUpParams {
  final String name;
  final String email;
  final String phone;
  final String password;
  final String referral;
  final String idToken;

  SignUpParams({
    @required this.name,
    this.email,
    @required this.phone,
    @required this.password,
    this.referral,
    @required this.idToken,
  });

  Map<String, String> get json {
    var response = {
      "name": name,
      "phone": phone,
      "password": password,
    };
    if (email != null) {
      response.addAll({
        "email": email,
      });
    }
    if (referral != null) {
      response.addAll({
        "referral": referral,
      });
    }
    return response;
  }
}
