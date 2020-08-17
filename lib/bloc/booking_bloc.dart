import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:qme/api/app_exceptions.dart';
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
        super(BookingInitial(false));
  var message;
  Appointment detail;
  @override
  Stream<BookingState> mapEventToState(BookingEvent event) async* {
    if (event is BookingRequested) {
      yield* _mapBookingRequested(event);
    } else if (event is BookingRefreshRequested) {
      yield* _mapBookingRefreshRequested(event);
    } else if (event is CancelRequested) {
      yield* _mapCancelRequestEventToState(event);
    }
  }

  Stream<BookingState> _mapBookingRequested(BookingRequested event) async* {
    yield BookingLoadInProgress();
    bool slotAvailable = true;
    var booking;
    logger.i("counter: ${event.counterId}, startTime: ${event.startTime}");
    try {
      booking = await appointmentRepository.checkSlot(
          counterId: event.counterId,
          status: "ALL");
      final detail =
          Appointment.fromMap(booking["slots"][(booking["slots"].length) - 1]);
      // if (detail.slot)
      if (detail.slotStatus == "UPCOMING") {
        slotAvailable = false;
      }
    } on RangeError catch (e) {
      logger.i(e);
      slotAvailable = true;
    } catch (e) {
      logger.e(e);
      yield BookingLoadFailure();
    }

    if (slotAvailable == true) {
      try {
        final bookingResponse = await appointmentRepository.book(
            counterId: event.counterId,
            subscriberId: event.subscriberId,
            startTime: event.startTime,
            endTime: event.endTime,
            note: event.note,);
        logger.i(bookingResponse);
        final msg = bookingResponse["msg"];
        final details = Appointment.fromMap(bookingResponse["slot"]);
        message = msg;
        detail = details;
        logger.i(msg, details);
        yield BookingLoadSuccess(msg, details);
      } catch (error) {
        logger.e(error);
        yield BookingLoadFailure();
      }
    } else {
      final detail =
          Appointment.fromMap(booking["slots"][(booking["slots"].length) - 1]);
      yield BookingDone(detail);
    }
  }

  Stream<BookingState> _mapBookingRefreshRequested(
      BookingRefreshRequested event) async* {
    yield BookingInitial(false);
  }

  Stream<BookingState> _mapCancelRequestEventToState(
      CancelRequested event) async* {
    yield BookingLoadInProgress();
    try {
      final bookingResponse = await appointmentRepository.cancel(
          counterId: event.counterId, accessToken: event.accessToken);
      final msg = bookingResponse["msg"];
      logger.i(msg);
      yield BookingInitial(false);
    } catch (error) {
      logger.e(error);
      yield BookingInitial(true);
    }
  }
}
