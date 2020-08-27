import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:qme/api/app_exceptions.dart';
import 'package:qme/api/base_helper.dart';
import 'package:qme/model/appointment.dart';
import 'package:qme/model/reception.dart';
import 'package:qme/model/slot.dart';
import 'package:qme/model/subscriber.dart';
import 'package:qme/model/user.dart';
import 'package:qme/repository/appointment.dart';
import 'package:qme/repository/user.dart';
import 'package:qme/utilities/logger.dart';

class AppointmentBloc with ChangeNotifier {
  String _accessToken;
  Subscriber subscriber;
  Reception reception;
  Slot slot;
  UserRepository _userRepository;
  AppointmentRepository _appointmentRepository;
  UserData _userData;

  StreamController _userController;
  StreamController _appointmentController;

  StreamSink<ApiResponse<Appointment>> get appointmentSink =>
      _appointmentController.sink;
  StreamSink<ApiResponse<UserData>> get userSink => _userController.sink;

  Stream<ApiResponse<Appointment>> get appointmentStream =>
      _appointmentController.stream;
  Stream<ApiResponse<UserData>> get userStream => _userController.stream;

  AppointmentBloc({
    @required this.subscriber,
    @required this.slot,
    @required this.reception,
  }) {
    _userRepository = UserRepository();
    _appointmentRepository = AppointmentRepository();
    _appointmentController = StreamController<ApiResponse<Appointment>>();
    _userController = StreamController<ApiResponse<UserData>>();
    fetchUserProfile();
  }

  book({@required String note}) async {
    appointmentSink.add(ApiResponse.loading('Fetching appointment details'));
    _accessToken =
        _accessToken == null ? await getAccessTokenFromStorage() : _accessToken;
    try {
      final response = await _appointmentRepository.book(
        counterId: reception.id,
        subscriberId: subscriber.id,
        startTime: slot.startTime,
        endTime: slot.endTime,
        note: note,
        accessToken: _accessToken,
      );
      final _appointment =
          Appointment(slot: slot, otp: response["slot"]["otp"]);

      appointmentSink.add(ApiResponse.completed(_appointment));
    } catch (e) {
      logger.e(e.toString());
      appointmentSink.add(ApiResponse.error(e.toString()));
      return e.toString();
    }
  }

  fetchUserProfile() async {
    userSink.add(ApiResponse.loading('Fetching data'));

    try {
      _accessToken = _accessToken == null
          ? await getAccessTokenFromStorage()
          : _accessToken;
      logger.d('Access token $_accessToken');
      _userData = await _userRepository.fetchProfile(_accessToken);
      userSink.add(ApiResponse.completed(_userData));
    } on UnauthorisedException catch (e) {
      logger.e(e.toString() + '\nAccess token : $_accessToken');
      return;
    } catch (e) {
      userSink.add(ApiResponse.error(e.toString()));
      logger.e(e.toString());
    }
    return _userData;
  }

  @override
  void dispose() {
    _userController?.close();
    _appointmentController?.close();
    super.dispose();
  }
}
