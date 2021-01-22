import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:qme/api/app_exceptions.dart';
import 'package:qme/model/appointment.dart';
import 'package:qme/model/user.dart';
import 'package:qme/repository/appointment.dart';
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
    } else if (event is CancelRequested) {
      yield* _mapCancelRequestedEventToState(event);
    }
  }

  Stream<BookingslistState> _mapBookingsRequestedEventToState(
      BookingsListRequested event) async* {
    yield BookingsListLoading();
    List<String> statusList = [];
    if (event.statusRequired != null && event.statusRequired.length != 0) {
      statusList = event.statusRequired;
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
      if (response.length != 0) {
        // logger.i(response[response.length - 1].counterId);
      }
      log("${response.toString()}");
      yield BookingsListSuccess(response);
    } on UnauthorisedException catch (e) {
      // Box box = await hive.openbox("user");

      if (e.toMap()['error'] == 'Forbidden Access' &&
          getUserDataFromStorage().isGuest) {
        yield BookingsListSuccess([]);
      } else {
        yield BookingsListFailure(e.toString());
      }
    } catch (e) {
      logger.e(e);
      yield BookingsListFailure(e.toString());
    }
  }

  Stream<BookingslistState> _mapCancelRequestedEventToState(
      CancelRequested event) async* {
    yield BookingsListLoading();
    try {
      final cancelResponse = await AppointmentRepository()
          .cancel(counterId: event.counterId, accessToken: event.accessToken);
      final msg = cancelResponse["msg"];
      logger.i(msg);
      final List<Appointment> response = await UserRepository()
          .fetchAppointments(
              ["CANCELLED", "UPCOMING", "CANCELLED BY SUBSCRIBER", "DONE"]);

      // logger.i(response[response.length - 1].rating);
      yield BookingsListSuccess(response);
    } catch (e) {
      logger.e("${e.toString()}");
      yield BookingsListFailure(e.toString());
    }
  }
}
