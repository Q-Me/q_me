import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:qme/model/appointment.dart';
import 'package:qme/repository/user.dart';
import 'package:qme/utilities/logger.dart';

part 'bookingslist_event.dart';
part 'bookingslist_state.dart';

class BookingslistBloc extends Bloc<BookingslistEvent, BookingslistState> {
  BookingslistBloc() : super(BookingslistInitial());

  @override
  Stream<BookingslistState> mapEventToState(
    BookingslistEvent event,
  ) async* {
    if (event is BookingsListRequested) {
      yield* _mapBookingsRequestedEventToState(event);
    }
  }

  Stream<BookingslistState> _mapBookingsRequestedEventToState(
      BookingsListRequested event) async* {
    yield BookingsListLoading();
    List<String> statusList = [];
    if (event.statusRequired != null) {
      statusList.add(event.statusRequired);
    } else {
      statusList = [
        "CANCELLED ",
        "UPCOMING",
        "CANCELLED BY SUBSCRIBER",
        "DONE"
      ];
    }
    try {
      final List<Appointment> response =
          await UserRepository().fetchAppointments(statusList);

      logger.i(response[response.length - 1].counterId);
      yield BookingsListSuccess(response);
    } catch (e) {
      logger.e(e);
      yield BookingsListFailure(e.toString());
    }
  }
}
