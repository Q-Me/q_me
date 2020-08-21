part of 'bookingslist_bloc.dart';

abstract class BookingslistState extends Equatable {
  const BookingslistState();

  @override
  List<Object> get props => [];
}

class BookingslistInitial extends BookingslistState {}

class BookingsListLoading extends BookingslistState {}

class BookingsListSuccess extends BookingslistState {
  final List<Appointment> appointment;

  BookingsListSuccess(this.appointment) : assert(appointment != null);

  @override
  List<Object> get props => [appointment];
}

class BookingsListFailure extends BookingslistState {}
