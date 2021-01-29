import 'package:flutter/material.dart';

class LoginWithPasswordParams {
  final String phone;
  final String password;

  LoginWithPasswordParams({
    @required this.phone,
    @required this.password,
  });

  Map<String, String> get json => {
        "phone": this.phone,
        "password": this.password,
      };
}

class LoginFirebase {
  final String idToken;

  LoginFirebase(this.idToken);
}
