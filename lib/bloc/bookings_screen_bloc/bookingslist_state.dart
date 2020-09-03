part of 'bookingslist_bloc.dart';

abstract class BookingslistState extends Equatable {
  const BookingslistState();

  @override
  List<Object> get props => [];
}

class BookingslistInitial extends BookingslistState {}

class BookingsListLoading extends BookingslistState {}

class BookingsListSuccess extends BookingslistState {
  final List<Appointment> appointmentsList;

  BookingsListSuccess(this.appointmentsList) : assert(appointmentsList != null);

  @override
  List<Object> get props => [appointmentsList];
}

class BookingsListFailure extends BookingslistState {
  final String errorMessage;

  BookingsListFailure(this.errorMessage);
  @override
  List<Object> get props => [errorMessage];
}
