import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:qme/repository/appointment.dart';
import 'package:qme/utilities/logger.dart';

part 'cancel_event.dart';
part 'cancel_state.dart';

class CancelBloc extends Bloc<CancelEvent, CancelState> {
  final AppointmentRepository appointmentRepository;
  CancelBloc({@required this.appointmentRepository})
      : assert(appointmentRepository != null),
        super(CancelInitial());

  @override
  Stream<CancelState> mapEventToState(
    CancelEvent event,
  ) async* {
    if (event is CancelRequestedEvent) {
      yield* _mapCancelRequestEventToState(event);
    }
  }

  Stream<CancelState> _mapCancelRequestEventToState(
      CancelRequestedEvent event) async* {
    yield CancelLoadInProgress();
    try {
      final bookingResponse = await appointmentRepository.cancel(
          counterId: event.counterId, accessToken: event.accessToken);
      final msg = bookingResponse["msg"];
      logger.i(msg);
      var box = await Hive.openBox("appointment");
      box.put("appointment", false);
      yield CancelSuccess(msg);
    } catch (error) {
      logger.e(error);
      yield CancelLoadFailure();
    }
  }
}
