import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:qme/model/appointment.dart';
import 'package:qme/model/subscriber.dart';
import 'package:qme/model/user.dart';
import 'package:qme/repository/appointment.dart';
import 'package:qme/utilities/logger.dart';

part 'booking_event.dart';
part 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final AppointmentRepository appointmentRepository;
  BookingBloc({@required this.appointmentRepository})
      : assert(appointmentRepository != null),
        super(BookingInitial());
  var message;
  Appointment detail;
  @override
  Stream<BookingState> mapEventToState(BookingEvent event) async* {
    var box = await Hive.openBox("appointment");
    bool state = box.get("appointment");
    logger.i(state);
    logger.i(message);
    logger.i(detail);
    if (state == true && !(event is BookingRefreshRequested)) {
      yield* _mapBookingExists(event);
    }
    if (event is BookingRequested &&
        (box.get("appointment") == false ||
            !box.containsKey("appointment"))) {
      yield* _mapBookingRequested(event);
    } else if (event is BookingRefreshRequested) {
      yield* _mapBookingRefreshRequested(event);
    } 
  }

  Stream<BookingState> _mapBookingRequested(BookingRequested event) async* {
    yield BookingLoadInProgress();
    try {
      final bookingResponse = await appointmentRepository.book(
          counterId: event.counterId,
          subscriberId: event.subscriberId,
          startTime: event.startTime,
          endTime: event.endTime,
          note: event.note,
          accessToken: event.accessToken);
      final msg = bookingResponse["msg"];
      final details = Appointment.fromMap(bookingResponse["slot"]);
      message = msg;
      detail = details;
      logger.i(msg, details);
      var box = await Hive.openBox("appointment");
      box.put("appointment", true);
      yield BookingLoadSuccess(msg, details);
    } catch (error) {
      logger.e(error);
      yield BookingLoadFailure();
    }
  }

  Stream<BookingState> _mapBookingRefreshRequested(
      BookingRefreshRequested event) async* {
    yield BookingInitial();
  }

  Stream<BookingState> _mapBookingExists(BookingRequested event) async* {
    logger.i(message, detail);
    yield BookingDone();
  }
}
