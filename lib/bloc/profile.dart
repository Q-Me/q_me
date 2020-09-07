import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:qme/model/appointment.dart';
import 'package:qme/repository/user.dart';
import 'package:qme/utilities/logger.dart';

import '../api/base_helper.dart';
import '../model/token.dart';
import '../repository/token.dart';

class ProfileBloc extends ChangeNotifier {
  TokenRepository _tokenRepository;
  UserRepository _userRepository;
  StreamController _tokensController;
  StreamController _appointmentController;

  StreamSink<ApiResponse<List<QueueToken>>> get tokenListSink =>
      _tokensController.sink;

  StreamSink<ApiResponse<List<Appointment>>> get appointmentListSink =>
      _appointmentController.sink;

  Stream<ApiResponse<List<QueueToken>>> get tokenListStream =>
      _tokensController.stream;
  Stream<ApiResponse<List<Appointment>>> get appointmentListStream =>
      _appointmentController.stream;

  ProfileBloc() {
    _tokensController = StreamController<ApiResponse<List<QueueToken>>>();
    _appointmentController = StreamController<ApiResponse<List<Appointment>>>();

    _tokenRepository = TokenRepository();
    _userRepository = UserRepository();

    fetchTokens(status: 'ALL');
  }

  accessToken() async {
    // final UserData userData = await getUserDataFromStorage();
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

  fetchAppointments() async {
    appointmentListSink.add(ApiResponse.loading('Fetching you appointments'));
    try {
      final List<Appointment> _appointments = await _userRepository
          .fetchAppointments(
              ['UPCOMING', 'CANCELLED', 'CANCELLED BY SUBSCRIBER', 'DONE']);
      appointmentListSink.add(ApiResponse.completed(_appointments));
    } catch (e) {
      logger.e(e.toString());
      appointmentListSink.add(ApiResponse.error(e.toString()));
    }
  }

  @override
  void dispose() {
    _tokensController.close();
    _appointmentController.close();
    super.dispose();
  }
}
