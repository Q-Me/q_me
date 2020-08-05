part of 'booking_bloc.dart';

abstract class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object> get props => [];
}

class BookingInitial extends BookingState {}

class BookingLoadInProgress extends BookingState {}

class BookingLoadSuccess extends BookingState {
  final msg;
  final Appointment details;
  BookingLoadSuccess(this.msg, this.details)
      : assert(details != null && msg != null);

  @override
  List<Object> get props => [msg, details];
}

class BookingLoadFailure extends BookingState {}

class BookingDone extends BookingState {}
