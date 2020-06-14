import 'dart:async';

import 'package:qme/api/base_helper.dart';

import '../model/subscriber.dart';
import '../model/user.dart';
import '../repository/token.dart';
import 'package:flutter/material.dart';

class ProfileBloc extends ChangeNotifier {
  String _accessToken;
  TokenRepository _tokenRepository;
  StreamController _tokensController;

  StreamSink<ApiResponse<>> 

}
