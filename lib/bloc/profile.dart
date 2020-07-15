import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';

import '../api/base_helper.dart';
import '../model/token.dart';
import '../model/user.dart';
import '../repository/token.dart';

class ProfileBloc extends ChangeNotifier {
  TokenRepository _tokenRepository;
  StreamController _tokensController;

  StreamSink<ApiResponse<List<QueueToken>>> get tokenListSink =>
      _tokensController.sink;

  Stream<ApiResponse<List<QueueToken>>> get tokenListStream =>
      _tokensController.stream;

  ProfileBloc() {
    _tokensController = StreamController<ApiResponse<List<QueueToken>>>();
    _tokenRepository = TokenRepository();
    fetchTokens(status: 'ALL');
  }

  accessToken() async {
    final UserData userData = await getUserDataFromStorage();
  }

  fetchTokens({@required String status}) async {
    tokenListSink.add(ApiResponse.loading('Fetching tokens..'));
    log('Fetching tokens of profile');
    try {
      final response = await _tokenRepository.getTokens(status: status);
      tokenListSink.add(
        ApiResponse.completed(
          Tokens.fromJson(response).tokenList,
        ),
      );
      log('Got tokens.');
    } catch (e) {
      tokenListSink.add(ApiResponse.error(e.toString()));
      log('Error in Profile BLoc : fetching tokens:' + e.toString());
    }
  }

  @override
  void dispose() {
    _tokensController.close();
    super.dispose();
  }
}
